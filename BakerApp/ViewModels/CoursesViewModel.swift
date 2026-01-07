//
//  CoursesViewModel.swift
//  BakerApp
//
//  Created by Tala Aldhahri on 12/07/1447 AH.
//
import Foundation
import Combine

class CoursesViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var selectedCourse: Course? // For GET /course/:id
    @Published var isLoading = false // ⏳ Track loading state
    @Published var errorMessage: String? // ⚠️ Track errors
    
    var upcomingCourse: Course? {
        /**
        let now = Date()
        // Calculate 3 days from now (3 * 24 * 60 * 60 seconds)
        let threeDaysFromNow = now.addingTimeInterval(3 * 24 * 60 * 60)
        **/
        
        // DEBUG: Hardcode "Now" to be Dec 13, 2025
            let now: Date = {
                var components = DateComponents()
                components.year = 2025
                components.month = 12
                components.day = 13
                components.hour = 9 // Optional: Set time to 9:00 AM
                return Calendar.current.date(from: components) ?? Date()
            }()
            
            // Calculate 3 days from this new "fake now"
            let threeDaysFromNow = now.addingTimeInterval(3 * 24 * 60 * 60)
        
        // 1. Get the IDs of all courses the user has booked
        let bookedIDs = bookedCourses.compactMap { $0.fields.course_id }
        
        // 2. Find the actual Course objects from your main list that match those IDs
        let myCourses = courses.filter { bookedIDs.contains($0.id) }
        
        // 3. Filter: Keep only courses starting soon (Now < StartDate < 3 Days Later)
        let comingSoon = myCourses.filter { course in
            guard let start = course.startDate else { return false }
            return start >= now && start <= threeDaysFromNow
        }
        
        // 4. Sort by date and pick the first one
        return comingSoon.sorted {
            ($0.startDate ?? Date.distantFuture) < ($1.startDate ?? Date.distantFuture)
        }.first
    }
    
    @Published var bookedCourses: [BookingRecord] = []
    
    var popularCourses: [Course] {
        // 1. Tally up the votes
        var counts: [String: Int] = [:]
        
        for booking in bookedCourses {
            if let id = booking.fields.course_id {
                counts[id, default: 0] += 1
            }
        }
        
        // 2. Sort the IDs by popularity
        let sortedIDs = counts.sorted { $0.value > $1.value }.map { $0.key }
        
        // 3. Find the actual Course objects for ALL popular IDs first
        // compactMap automatically removes any courses that don't exist/were deleted
        let validPopularCourses = sortedIDs.compactMap { id in
            self.courses.first { $0.id == id }
        }
        
        // 4. Now take the top 3 of the VALID courses
        return Array(validPopularCourses.prefix(3))
    }

    func fetchCourses() {
        // Start loading
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
            print("🟡 [Courses] Start fetching list…")
        }

        let urlString = "\(APIConstants.baseURL)/course"
        guard let url = URL(string: urlString) else {
            print("❌ [Courses] Invalid URL: \(urlString)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(APIConstants.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ [Courses] Status Code: \(httpResponse.statusCode)")
            }

            if let data = data {
                let jsonString = String(data: data, encoding: .utf8)
                print("📄 [Courses] Raw Data: \(jsonString ?? "Empty")")
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Connection error: \(error.localizedDescription)"
                    print("❌ [Courses] Connection error: \(error.localizedDescription)")
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Server error: \(httpResponse.statusCode)"
                    print("❌ [Courses] Server error code: \(httpResponse.statusCode)")
                }
                return
            }

            guard let data = data else {
                print("❌ [Courses] No data returned")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(AirtableResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.courses = decodedResponse.records.map { record in
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
                    self.isLoading = false
                    print("🟢 [Courses] Decoded \(self.courses.count) courses")
                    self.courses.enumerated().forEach { idx, c in
                        print("   [\(idx)] \(c.title) • \(c.level.rawValue) • \(c.duration) • \(c.date)")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Failed to process data from the server."
                    print("❌ [Courses] Decoding failed: \(error)")
                }
            }
        }.resume()
    }

    // MARK: - GET /course/:id
    func fetchCourse(id: String) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
            self.selectedCourse = nil
            print("🟡 [Course Detail] Start fetching id=\(id)")
        }

        let urlString = "\(APIConstants.baseURL)/course/\(id)"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid URL."
                print("❌ [Course Detail] Invalid URL: \(urlString)")
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(APIConstants.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ [Course Detail] Status Code: \(httpResponse.statusCode)")
            }

            if let data = data {
                let jsonString = String(data: data, encoding: .utf8)
                print("📄 [Course Detail] Raw Data: \(jsonString ?? "Empty")")
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Connection error: \(error.localizedDescription)"
                    print("❌ [Course Detail] Connection error: \(error.localizedDescription)")
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Server error: \(httpResponse.statusCode)"
                    print("❌ [Course Detail] Server error code: \(httpResponse.statusCode)")
                }
                return
            }

            guard let data = data else {
                print("❌ [Course Detail] No data returned")
                return
            }

            do {
                if let singleRecord = try? JSONDecoder().decode(CourseRecord.self, from: data) {
                    let f = singleRecord.fields
                    let lvl = Self.normalizeLevel(f.level)
                    let start = Self.date(fromUnix: f.start_date)
                    let end = Self.date(fromUnix: f.end_date)
                    let durationText = Self.durationText(from: start, to: end) ?? (f.duration ?? "—")
                    let dateText = Self.dateText(from: start) ?? (f.date ?? "—")
                    let course = Course(
                        id: singleRecord.id,
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
                    DispatchQueue.main.async {
                        self.selectedCourse = course
                        self.isLoading = false
                        print("🟢 [Course Detail] Decoded single record: \(course.title)")
                    }
                } else {
                    let decodedResponse = try JSONDecoder().decode(AirtableResponse.self, from: data)
                    let first = decodedResponse.records.first
                    let course = first.map { record in
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
                    DispatchQueue.main.async {
                        self.selectedCourse = course
                        self.isLoading = false
                        if let c = course {
                            print("🟢 [Course Detail] Decoded from records: \(c.title)")
                        } else {
                            self.errorMessage = "Course not found."
                            print("⚠️ [Course Detail] Course not found in response")
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Failed to process data from the server."
                    print("❌ [Course Detail] Decoding failed: \(error)")
                }
            }
        }.resume()
    }
    //fetching all booked courses from bookingAPI (for popular courses)
    func fetchBookings() async{
        
        isLoading = true
        errorMessage = nil
        
            do {
                // Call the new API function we just wrote
                let bookings = try await BookingAPI.shared.fetchAllBookings()
                
                // update the published property
                self.bookedCourses = bookings
                self.isLoading = false
                
            } catch {
                self.isLoading = false
                self.errorMessage = "Failed to load bookings: \(error.localizedDescription)"
            }
    }
}

private extension CoursesViewModel {
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
