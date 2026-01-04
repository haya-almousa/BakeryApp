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
    @Published var isLoading = false // ⏳ Track loading state
    @Published var errorMessage: String? // ⚠️ Track errors

    func fetchCourses() {
        // Start loading
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        let urlString = "\(APIConstants.baseURL)/course"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(APIConstants.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Print the raw response to the console
                if let httpResponse = response as? HTTPURLResponse {
                    print("✅ API Status Code: \(httpResponse.statusCode)")
                }

                if let data = data {
                    let jsonString = String(data: data, encoding: .utf8)
                    print("📄 Received Data: \(jsonString ?? "Empty")")
                }
            
            // 1. Handle Network/Connection Errors
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Connection error: \(error.localizedDescription)"
                }
                return
            }

            // 2. Handle HTTP Status Code Errors (e.g., 401 Unauthorized)
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Server error: \(httpResponse.statusCode)"
                }
                return
            }

            guard let data = data else { return }

            do {
                // 3. Decode the JSON
                let decodedResponse = try JSONDecoder().decode(AirtableResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.courses = decodedResponse.records.map { record in
                        Course(
                            id: UUID(),
                            title: record.fields.title,
                            level: CourseLevel(rawValue: record.fields.level) ?? .beginner,
                            duration: record.fields.duration,
                            date: record.fields.date,
                            image_url: record.fields.image_url
                        )
                    }
                    self.isLoading = false
                }
            } catch {
                // 4. Handle Decoding Errors
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Failed to process data from the server."
                    print("Decoding failed: \(error)")
                }
            }
        }.resume()
    }
}
