//
//  UserAPI.swift
//  BakerApp
//
//  Created by Haya almousa on 29/12/2025.
//

import Foundation
// نستخدم Foundation لأننا نحتاج URLSession و URL و JSONDecoder

enum UserAPIError: Error {
    case invalidURL
    // خطأ في تكوين الرابط

    case requestFailed(statusCode: Int)
    // السيرفر رجّع كود خطأ (غير 200–299)

    case decodingFailed
    // فشلنا نفك JSON
}

final class UserAPI {
    // هذا الكلاس مسؤول فقط عن API الخاص بالـ user

    func fetchUser(byEmail email: String) async throws -> UserFields {
        // دالة تجيب يوزر واحد بناءً على الإيميل (هذا هو البروفايل)

        var components = URLComponents(string: APIConstants.baseURL + "/user")
        // نبني رابط endpoint الأساسي: /user

        let formula = "({email}=\"\(email)\")"
        // filterByFormula: نطابق حقل email مع الإيميل المطلوب

        components?.queryItems = [
            URLQueryItem(name: "filterByFormula", value: formula),
            URLQueryItem(name: "maxRecords", value: "1")
        ]
        // نضيف الفلترة + نطلب سجل واحد فقط

        guard let url = components?.url else {
            throw UserAPIError.invalidURL
        }
        // نتأكد أن الرابط النهائي صحيح

        var request = URLRequest(url: url)
        // ننشئ request

        request.httpMethod = "GET"
        // نوع الطلب GET

        request.setValue(
            "Bearer \(APIConstants.token)",
            forHTTPHeaderField: "Authorization"
        )
        // نضيف Authorization header بالتوكن

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )
        // نحدد أننا نتوقع JSON

        let (data, response) = try await URLSession.shared.data(for: request)
        // ننفذ الطلب باستخدام async/await

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw UserAPIError.requestFailed(statusCode: status)
        }
        // نتأكد أن الاستجابة ناجحة

        let decoded = try JSONDecoder().decode(
            AirtableListResponse<UserFields>.self,
            from: data
        )
        // نفك JSON إلى موديلاتنا

        guard let user = decoded.records.first?.fields else {
            throw UserAPIError.decodingFailed
        }
        // نأخذ أول سجل مطابق للإيميل

        return user
        // نرجّع بيانات اليوزر
    }
}
/* للبروفايل
 يربط تطبيق بـ:
 GET /user
 filterByFormula (email)*/
