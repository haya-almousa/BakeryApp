
import Foundation
import Combine

@MainActor
final class ProfileBookingsViewModel: ObservableObject {

    // MARK: - Published state
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var bookedCourses: [Course] = []   // نفس نموذج Bake
    
    // MARK: - API constants
    private let baseURL = APIConstants.baseURL
    private let token = APIConstants.token
    
    // شكل حقول جدول booking (مطابق للـ JSON المرسل)
    private struct BookingProfileFields: Codable {
        let courseid: String?
        let user_id: String?
        let status: String?
    }
    
    // MARK: - Public API
    func load(email userEmail: String) {
        Task { await fetchAll(email: userEmail) }
    }
    
    // MARK: - Networking helpers
    private func makeRequest(path: String, queryItems: [URLQueryItem] = []) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL) else { throw URLError(.badURL) }
        components.path = components.path + "/" + path
        if !queryItems.isEmpty { components.queryItems = queryItems }
        guard let url = components.url else { throw URLError(.badURL) }
        
        // CHANGE: Add cachePolicy to ignore local storage
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return req
    }
    
    // MARK: - Orchestration
    private func fetchAll(email userEmail: String) async {
        isLoading = true
        errorMessage = nil
        bookedCourses = []
        name = ""
        email = userEmail
        
        do {
            // 1) احصل على record id + الاسم للمستخدم عبر الإيميل
            let (userRecordId, userName) = try await fetchUserRecordIdAndName(byEmail: userEmail)
            self.name = userName ?? ""
            
            // 2) اجلب حجوزات هذا المستخدم مغطية الحالتين:
            //    - user_id = recId
            //    - user_id = email (مع lowercase)
            let allBookings = try await fetchBookings(email: userEmail, userRecordId: userRecordId)
            
            
            let activeBookings = allBookings.filter { rec in
                // Safely unwrap status, default to empty string if nil
                let status = rec.fields.status?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
                
                // Check if it contains "cancel" (covers "Cancelled", "Canceled", "User Cancelled", etc.)
                return !status.contains("cancel")
            }
            
            // استخرج course IDs وتخلّص من القيم الفارغة والمكررة
            let courseIds = Array(Set(
                activeBookings.compactMap { $0.fields.courseid?.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            ))
            
            guard !courseIds.isEmpty else {
                isLoading = false
                return
            }
            
            // 3) اجلب تفاصيل الكورسات دفعة واحدة
            let courseRecords = try await fetchCourses(byRecordIds: courseIds)
            
            // 4) حوّل النتائج إلى Course بنفس منطق شاشة Bake لضمان تطابق الشكل
            let mapped: [Course] = courseRecords.map { record in
                let f = record.fields
                let lvl = Self.normalizeLevel(f.level)
                let start = Self.date(fromUnix: f.start_date)
                let end = Self.date(fromUnix: f.end_date)
                let durationText = Self.durationText(from: start, to: end) ?? (f.duration ?? "—")
                let dateText = Self.dateText(from: start) ?? (f.date ?? "—")
                return Course(
                    id: record.id,
                    title: f.title ?? "Untitled",
                    level: lvl,
                    duration: durationText,
                    date: dateText,
                    image_url: f.image_url ?? "",
                    description: f.description ?? "",
                    locationName: f.location_name ?? "",
                    latitude: f.location_latitude,
                    longitude: f.location_longitude,
                    chefId: f.chef_id,
                    startDate: start,
                    endDate: end
                )
            }
            
            self.bookedCourses = mapped
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
    
    // MARK: - Individual fetches
    
    // ترجع (record id, name) للمستخدم عبر الإيميل
    private func fetchUserRecordIdAndName(byEmail email: String) async throws -> (id: String, name: String?) {
        let lower = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let formula = "LOWER({email})='\(lower)'"
        let query: [URLQueryItem] = [
            URLQueryItem(name: "filterByFormula", value: formula),
            URLQueryItem(name: "pageSize", value: "1")
        ]
        let request = try makeRequest(path: "user", queryItems: query)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(AirtableListResponse<UserFields>.self, from: data)
        guard let record = decoded.records.first else {
            return ("", nil)
        }
        return (record.id, record.fields.name)
    }
    
    // تبني فلترة تغطي الحالتين: user_id = recId أو user_id = email (lowercased)
    private func fetchBookings(email: String, userRecordId: String) async throws -> [AirtableRecord<BookingProfileFields>] {
        let lower = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let formula: String
        if userRecordId.isEmpty {
            formula = "LOWER({user_id})='\(lower)'"
        } else {
            formula = "OR(LOWER({user_id})='\(lower)', {user_id}='\(userRecordId)')"
        }
        let query = [URLQueryItem(name: "filterByFormula", value: formula)]
        let request = try makeRequest(path: "booking", queryItems: query)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(AirtableListResponse<BookingProfileFields>.self, from: data)
        return decoded.records
    }
    
    private func fetchCourses(byRecordIds ids: [String]) async throws -> [CourseRecord] {
        // OR(RECORD_ID()='id1', RECORD_ID()='id2', ...)
        let parts = ids.map { "RECORD_ID()='\($0)'" }
        let formula = "OR(\(parts.joined(separator: ", ")))"
        let query = [URLQueryItem(name: "filterByFormula", value: formula)]
        let request = try makeRequest(path: "course", queryItems: query)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(AirtableResponse.self, from: data)
        return decoded.records
    }
}

// MARK: - Formatting helpers (مطابقة لـ CoursesViewModel)
private extension ProfileBookingsViewModel {
    static func normalizeLevel(_ level: String?) -> CourseLevel {
        guard let level else { return .beginner }
        let lower = level.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch lower {
        case "beginner": return .beginner
        case "intermediate": return .intermediate
        case "advanced", "advance": return .advanced
        default: return .beginner
        }
    }
    
    static func date(fromUnix ts: Double?) -> Date? {
        guard let ts else { return nil }
        return Date(timeIntervalSince1970: ts)
    }
    
    static func durationText(from start: Date?, to end: Date?) -> String? {
        guard let start, let end, end > start else { return nil }
        let seconds = end.timeIntervalSince(start)
        let totalMinutes = Int(seconds / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    static func dateText(from start: Date?) -> String? {
        guard let start else { return nil }
        let df = DateFormatter()
        df.locale = Locale.current
        df.setLocalizedDateFormatFromTemplate("d MMM - h:mm a")
        return df.string(from: start)
    }
}
