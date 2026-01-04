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
                        return Course(
                            id: UUID(),
                            title: f.title ?? "Untitled",
                            level: CourseLevel(rawValue: (f.level ?? "Beginner")) ?? .beginner,
                            duration: f.duration ?? "—",
                            date: f.date ?? "—",
                            image_url: f.image_url ?? ""
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
                    let course = Course(
                        id: UUID(),
                        title: f.title ?? "Untitled",
                        level: CourseLevel(rawValue: (f.level ?? "Beginner")) ?? .beginner,
                        duration: f.duration ?? "—",
                        date: f.date ?? "—",
                        image_url: f.image_url ?? ""
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
                        return Course(
                            id: UUID(),
                            title: f.title ?? "Untitled",
                            level: CourseLevel(rawValue: (f.level ?? "Beginner")) ?? .beginner,
                            duration: f.duration ?? "—",
                            date: f.date ?? "—",
                            image_url: f.image_url ?? ""
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
}
