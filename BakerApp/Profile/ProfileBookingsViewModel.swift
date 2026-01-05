// ProfileBookingsViewModel.swift
import Foundation
import Combine

@MainActor
final class ProfileBookingsViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var bookedCourses: [BookedCourse] = []
    
    private let baseURL = APIConstants.baseURL
    private let token = APIConstants.token
    
    // مطابق للـ JSON (courseid, user_id, status)
    private struct BookingProfileFields: Codable {
        let courseid: String?
        let user_id: String?
        let status: String?
    }
    
    func load(email userEmail: String) {
        Task { await fetchAll(email: userEmail) }
    }
    
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
    
    private func fetchAll(email userEmail: String) async {
        isLoading = true
        errorMessage = nil
        bookedCourses = []
        name = ""
        email = userEmail
        
        print("🔵 [Profile] Start load for email=\(userEmail)")
        do {
            // 1) user record id + name
            let (userRecordId, userName) = try await fetchUserRecordIdAndName(byEmail: userEmail)
            self.name = userName ?? ""
            print("🟢 [Profile] userRecordId=\(userRecordId), name=\(self.name)")
            
            // 2) bookings of this user
            let bookings = try await fetchBookings(byUserRecordId: userRecordId)
            print("🟢 [Profile] bookings count=\(bookings.count)")
            let courseIds = Array(Set(bookings.compactMap { $0.fields.courseid }.filter { !$0.isEmpty }))
            print("🟢 [Profile] courseIds=\(courseIds)")
            guard !courseIds.isEmpty else {
                self.isLoading = false
                print("⚪️ [Profile] No courseIds for this user. Done.")
                return
            }
            
            // 3) fetch courses by record IDs (batch)
            let courses = try await fetchCourses(byRecordIds: courseIds)
            print("🟢 [Profile] fetched courses count=\(courses.count)")
            
            // 4) map to BookedCourse for UI
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
            print("🟢 [Profile] mapped bookedCourses=\(mapped.count)")
        } catch {
            self.isLoading = false
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            print("🔴 [Profile] Error: \(self.errorMessage ?? "unknown")")
        }
    }
    
    private func fetchUserRecordIdAndName(byEmail email: String) async throws -> (id: String, name: String?) {
        let lower = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let formula = "LOWER({email})='\(lower)'"
        let query: [URLQueryItem] = [
            URLQueryItem(name: "filterByFormula", value: formula),
            URLQueryItem(name: "pageSize", value: "1")
        ]
        let request = try makeRequest(path: "user", queryItems: query)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse {
            print("🔷 [Profile] fetchUser status=\(http.statusCode)")
        }
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(AirtableListResponse<UserFields>.self, from: data)
        guard let record = decoded.records.first else {
            throw NSError(domain: "UserNotFound", code: 404)
        }
        return (record.id, record.fields.name)
    }
    
    private func fetchBookings(byUserRecordId id: String) async throws -> [AirtableRecord<BookingProfileFields>] {
        let formula = "{user_id}='\(id)'"
        let query = [URLQueryItem(name: "filterByFormula", value: formula)]
        let request = try makeRequest(path: "booking", queryItems: query)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse {
            print("🔷 [Profile] fetchBookings status=\(http.statusCode)")
        }
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
        if let http = response as? HTTPURLResponse {
            print("🔷 [Profile] fetchCourses status=\(http.statusCode)")
        }
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(AirtableResponse.self, from: data)
        return decoded.records
    }
}
