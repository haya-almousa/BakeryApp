//
//  BookingAPI.swift
//  BakerApp
//
//  Created by Assistant on 04/01/2026.
//

import Foundation

enum BookingAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed
    case message(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .invalidResponse: return "Invalid server response."
        case .httpStatus(let code): return "Server error (Code: \(code))."
        case .decodingFailed: return "Failed to decode server data."
        case .message(let text): return text
        }
    }
}

final class BookingAPI {
    static let shared = BookingAPI()
    private init() {}
    
    private let baseURL = APIConstants.baseURL
    private let token = APIConstants.token
    
    private func makeRequest(path: String,
                             method: String = "GET",
                             queryItems: [URLQueryItem] = [],
                             body: Data? = nil) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL) else {
            throw BookingAPIError.invalidURL
        }
        components.path = components.path + "/" + path
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw BookingAPIError.invalidURL
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if let body {
            req.httpBody = body
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return req
    }
    
    // POST /booking
        func createBooking(courseRecordId: String,
                           userEmail: String,
                           seats: Int? = 1) async throws -> BookingRecord {
            
            // 1. We removed the brackets [] around courseRecordId
            // 2. We map 'userEmail' to 'user_id'
            // 3. We set a default 'status' of "Pending"
            let payload = CreateBookingRequest(
                fields: .init(
                    courseid: courseRecordId,
                    user_id: userEmail,
                    status: "Pending"
                )
            )
            
            let body = try JSONEncoder().encode(payload)
            let request = try makeRequest(path: "booking", method: "POST", body: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse else { throw BookingAPIError.invalidResponse }
            // Print error body if it fails, to help debugging
            if !(200...299).contains(http.statusCode) {
                let errorText = String(data: data, encoding: .utf8) ?? "No error details"
                print("❌ API Error \(http.statusCode): \(errorText)")
                throw BookingAPIError.httpStatus(http.statusCode)
            }
            
            do {
                let record = try JSONDecoder().decode(BookingRecord.self, from: data)
                return record
            } catch {
                throw BookingAPIError.decodingFailed
            }
        }
    // GET /course/:id/booking  ← نحققها بفلترة على جدول booking
    func fetchBookings(forCourseRecordId courseRecordId: String) async throws -> [BookingRecord] {
        // OLD FORMULA: "FIND('\(courseRecordId)', ARRAYJOIN({course}))"
        // NEW FORMULA: Since it's a text field, we can just check equality or search
        
        // Try this simple formula for text fields:
        let formula = "{courseid} = '\(courseRecordId)'"
        
        let query: [URLQueryItem] = [
            URLQueryItem(name: "filterByFormula", value: formula)
        ]
        
        let request = try makeRequest(path: "booking", queryItems: query)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw BookingAPIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw BookingAPIError.httpStatus(http.statusCode) }
        do {
            let decoded = try JSONDecoder().decode(BookingListResponse.self, from: data)
            return decoded.records
        } catch {
            throw BookingAPIError.decodingFailed
        }
    }
    
    // DELETE /booking/:id
    func deleteBooking(bookingRecordId: String) async throws {
        let request = try makeRequest(path: "booking/\(bookingRecordId)", method: "DELETE")
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw BookingAPIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw BookingAPIError.httpStatus(http.statusCode) }
    }
}
