// ProfileBookingsViewModel.swift
import Foundation
import Combine

@MainActor
final class ProfileBookingsViewModel: ObservableObject {

    // MARK: - Published state
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var bookedCourses: [BookedCourse] = []
    
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
        var req = URLRequest(url: url)
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
            let bookings = try await fetchBookings(email: userEmail, userRecordId: userRecordId)
            
            // استخرج course IDs وتخلّص من القيم الفارغة والمكررة
            let courseIds = Array(Set(
                bookings.compactMap { $0.fields.courseid?.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
            ))
            
            guard !courseIds.isEmpty else {
                isLoading = false
                return
            }
            
            // 3) اجلب تفاصيل الكورسات دفعة واحدة
            let courses = try await fetchCourses(byRecordIds: courseIds)
            
            // 4) حوّل النتائج إلى BookedCourse لعرضها
            let mapped: [BookedCourse] = courses.map { rec in
                let f = rec.fields
                return BookedCourse(
                    id: UUID(),
                    title: f.title ?? "Untitled",
                    level: f.level ?? "Beginner",
                    durationText: f.duration ?? "—",
                    dateText: f.date ?? "—",
                    imageURL: f.image_url
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
            // إذا ما وجدنا المستخدم، نرجع id فارغ ونكمل فلترة الحجوزات بالإيميل فقط
            return ("", nil)
        }
        return (record.id, record.fields.name)
    }
    
    // تبني فلترة تغطي الحالتين: user_id = recId أو user_id = email (lowercased)
    private func fetchBookings(email: String, userRecordId: String) async throws -> [AirtableRecord<BookingProfileFields>] {
        let lower = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let formula: String
        if userRecordId.isEmpty {
            // لو ما قدرنا نجيب recId، فلترة بالإيميل فقط
            formula = "LOWER({user_id})='\(lower)'"
        } else {
            // غطّي الحالتين معًا
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
