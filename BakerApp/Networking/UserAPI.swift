//
//  UserAPI.swift
//  BakerApp
//
//  Created by Haya almousa on 29/12/2025.
//
import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed
    case message(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "الرابط غير صحيح."
        case .invalidResponse:
            return "استجابة السيرفر غير صحيحة."
        case .httpStatus(let code):
            return "خطأ من السيرفر (Code: \(code))."
        case .decodingFailed:
            return "فشل قراءة البيانات (Decoding)."
        case .message(let text):
            return text
        }
    }
}

final class UserAPI {
    static let shared = UserAPI()
    private init() {}
    private let baseURL = APIConstants.baseURL
    private let token = APIConstants.token
    private func makeRequest(path: String,
                             queryItems: [URLQueryItem] = [],
                             method: String = "GET") throws -> URLRequest {

        guard var components = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }
        components.path = components.path + "/" + path

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func fetchUsers() async throws -> [AirtableRecord<UserFields>] {

        let request = try makeRequest(path: "user")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }

        do {
            let decoded = try JSONDecoder().decode(AirtableListResponse<UserFields>.self, from: data)
            return decoded.records
        } catch {
            throw APIError.decodingFailed
        }
    }

    func fetchUser(byEmail email: String) async throws -> UserFields {
        let lower = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let formula = "LOWER({email})='\(lower)'"

        let query: [URLQueryItem] = [
            URLQueryItem(name: "filterByFormula", value: formula),
            URLQueryItem(name: "pageSize", value: "1")
        ]

        let request = try makeRequest(path: "user", queryItems: query)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }

        do {
            let decoded = try JSONDecoder().decode(AirtableListResponse<UserFields>.self, from: data)
            // نفك الاستجابة إلى AirtableListResponse<UserFields>

            guard let record = decoded.records.first else {
                throw APIError.message("User not found.")
                // إذا ما فيه أي نتيجة مطابقة نرمي خطأ برسالة واضحة
            }

            return record.fields
            // نرجّع الحقول (UserFields) للمستخدم المطابق
        } catch {
            throw APIError.decodingFailed
            // فشل في فك البيانات يرجع decodingFailed
        }
    }
}
// نهاية UserAPI
