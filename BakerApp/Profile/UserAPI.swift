//
//  UserAPI.swift
//  BakerApp
//
//  Created by Haya almousa on 29/12/2025.
//

import Foundation
// نحتاج Foundation للشبكات و URLRequest و JSONDecoder

enum APIError: LocalizedError {
    // أنواع أخطاء واضحة بدل “Error” عام

    case invalidURL
    // لو الرابط غلط

    case invalidResponse
    // لو السيرفر رجع شيء مو متوقع

    case httpStatus(Int)
    // لو رجع Status Code مثل 401 أو 403

    case decodingFailed
    // لو فشلنا نفك JSON

    case message(String)
    // رسالة خطأ مخصصة

    var errorDescription: String? {
        // هذا يعطي وصف جاهز للعرض للمستخدم

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
    // كلاس مسؤول عن نداءات Users فقط (نظيف ومنفصل)

    static let shared = UserAPI()
    // Singleton عشان نستخدمه بسهولة بدون إنشاء كل مرة

    private init() {}
    // نخلي الإنشاء خاص لأننا نبي shared فقط

    private let baseURLString = "https://api.airtable.com/v0/appXMW3ZsAddTpClm/user"
    // رابط جدول user (مثل اللي عندك في Postman)

    private let token = "PUT_YOUR_TOKEN_HERE"
    // التوكن هنا (غيريها لتوكنكم)
    // الأفضل ما ينرفع Git… لكن لو تحدي تعليمي ومشترك: خليها هنا بمكان واحد وبدليها بسهولة

    func fetchUsers() async throws -> [AirtableRecord<UserFields>] {
        // دالة تجيب كل اليوزرز من Airtable

        guard let url = URL(string: baseURLString) else {
            // نتأكد الرابط صحيح

            throw APIError.invalidURL
            // لو غلط نرمي خطأ
        }

        var request = URLRequest(url: url)
        // نسوي Request

        request.httpMethod = "GET"
        // نوع الطلب GET

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // نحط Authorization Header بالطريقة الصحيحة

        let (data, response) = try await URLSession.shared.data(for: request)
        // ننفذ الطلب بشكل async ونستقبل data + response

        guard let http = response as? HTTPURLResponse else {
            // نتأكد الاستجابة HTTP

            throw APIError.invalidResponse
            // لو لا: خطأ
        }

        guard (200...299).contains(http.statusCode) else {
            // نتأكد الكود نجاح

            throw APIError.httpStatus(http.statusCode)
            // لو لا نرمي كود الخطأ
        }

        let decoder = JSONDecoder()
        // Decoder لفك JSON

        do {
            let decoded = try decoder.decode(AirtableListResponse<UserFields>.self, from: data)
            // نفك الاستجابة إلى ListResponse<UserFields>

            return decoded.records
            // نرجع records
        } catch {
            // لو فشل decoding

            throw APIError.decodingFailed
            // نرمي خطأ واضح
        }
    }
}
