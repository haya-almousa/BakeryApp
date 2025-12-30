//
//  UserAPI.swift
//  BakerApp
//
//  Created by Haya almousa on 29/12/2025.
//
import Foundation
// نستورد Foundation لأنه يحتوي أنواع الشبكات (URL, URLRequest, URLSession) و Decoders

// أخطاء واضحة للـ API
enum APIError: LocalizedError {
    // enum يمثل أنواع أخطاء ممكن تصير أثناء نداءات الشبكة وفك الـ JSON

    case invalidURL
    // خطأ يعني أن الرابط  غير صالح أو تم بناؤه بشكل خاطئ

    case invalidResponse
    // خطأ يعني أن الاستجابة ليست HTTPURLResponse أو غير متوقعة

    case httpStatus(Int)
    // خطأ يحمل كود حالة HTTP (مثل 401/403/500) لو كان خارج نطاق 200...299

    case decodingFailed
    // خطأ يعني فشلنا نفك الـ JSON إلى الموديلات (Codable)

    case message(String)
    // خطأ برسالة مخصصة نحددها نحن حسب الحالة

    var errorDescription: String? {
        // يوفّر وصف نصي للأخطاء لاستخدامه مباشرة في الواجهة

        switch self {
        case .invalidURL:
            return "الرابط غير صحيح."
            // رسالة مفهومة للمستخدم عند وجود مشكلة بالرابط
        case .invalidResponse:
            return "استجابة السيرفر غير صحيحة."
            // رسالة عند فشل تحويل الاستجابة إلى HTTPURLResponse
        case .httpStatus(let code):
            return "خطأ من السيرفر (Code: \(code))."
            // نعرض كود الحالة للمساعدة في التشخيص
        case .decodingFailed:
            return "فشل قراءة البيانات (Decoding)."
            // رسالة عند فشل JSONDecoder في فك البيانات
        case .message(let text):
            return text
            // نرجع النص المخصص كما هو
        }
    }
}
// نهاية تعريف الأخطاء

final class UserAPI {
    // كلاس مسؤول عن نداءات API المتعلقة بالمستخدمين (Users)
    // استخدمناه final لمنع الوراثة وتحسين الأداء القليل في الـ dispatch

    static let shared = UserAPI()
    // نمط Singleton: نسخة مشتركة وحيدة نستخدمها في كل مكان

    private init() {}
    // نجعل init خاص حتى نمنع إنشاء نسخ جديدة خارج shared

    // استخدام ثوابت موحّدة بدل القيم الصلبة داخل الملف
    private let baseURL = APIConstants.baseURL
    // رابط الأساس للـ API (مثلاً: https://api.airtable.com/v0/appXXXXX) مأخوذ من APIConstants

    private let token = APIConstants.token
    // التوكن الخاص بالمصادقة على Airtable مأخوذ من APIConstants (أسهل للإدارة بمكان واحد)

    // دالة مساعدة لبناء URLRequest نظيف
    private func makeRequest(path: String,
                             queryItems: [URLQueryItem] = [],
                             method: String = "GET") throws -> URLRequest {
        // تبني URLRequest موحّد مع الهيدر Authorization وتدعم الاستعلامات والطرق المختلفة

        guard var components = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
            // نتأكد أن baseURL صالح كبداية لبناء الرابط
        }
        components.path = components.path + "/" + path
        // نضيف المسار (اسم الجدول مثل "user") إلى المسار الحالي

        if !queryItems.isEmpty {
            components.queryItems = queryItems
            // نضيف استعلامات URL (مثل filterByFormula و pageSize) إذا كانت موجودة
        }

        guard let url = components.url else {
            throw APIError.invalidURL
            // نتأكد أن URL النهائي صالح بعد إضافة المسار والاستعلامات
        }

        var request = URLRequest(url: url)
        // ننشئ الطلب باستخدام الرابط النهائي

        request.httpMethod = method
        // نحدد طريقة HTTP (افتراضي GET، ويمكن تغييره)

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // نضيف ترويسة المصادقة لتمرير التوكن إلى Airtable

        return request
        // نرجّع الطلب الجاهز للاستخدام
    }

    // جلب جميع المستخدمين (عند الحاجة)
    func fetchUsers() async throws -> [AirtableRecord<UserFields>] {
        // دالة async ترجع مصفوفة سجلات Airtable تحتوي حقول المستخدمين

        let request = try makeRequest(path: "user")
        // نبني طلب GET على مسار جدول "user" بدون استعلامات إضافية

        let (data, response) = try await URLSession.shared.data(for: request)
        // ننفذ الطلب بشكل غير متزامن ونحصل على البيانات والاستجابة

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
            // نتحقق أن الاستجابة من نوع HTTPURLResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
            // نتحقق أن الكود ضمن نطاق النجاح وإلا نرمي خطأ بالكود
        }

        do {
            let decoded = try JSONDecoder().decode(AirtableListResponse<UserFields>.self, from: data)
            // نفك الـ JSON إلى AirtableListResponse<UserFields> الذي يحتوي على records

            return decoded.records
            // نرجّع السجلات (records) كقائمة من AirtableRecord<UserFields>
        } catch {
            throw APIError.decodingFailed
            // في حال فشل فك الـ JSON نرمي خطأ decodingFailed
        }
    }

    // جلب مستخدم واحد عبر الإيميل باستخدام فلترة Airtable (أفضل من تنزيل الكل)
    func fetchUser(byEmail email: String) async throws -> UserFields {
        // ترجع حقول مستخدم واحد يطابق الإيميل، باستخدام filterByFormula على السيرفر

        let lower = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        // نجهّز الإيميل بعد إزالة الفراغات وتحويله إلى lowercase لضمان تطابق غير حساس لحالة الأحرف

        let formula = "LOWER({email})='\(lower)'"
        // صيغة Airtable: نطبق LOWER على الحقل {email} ونقارنه بنسخة lowercase من الإيميل المدخل

        let query: [URLQueryItem] = [
            URLQueryItem(name: "filterByFormula", value: formula),
            // نرسل شرط الفلترة للسيرفر حتى يرجع فقط السجل المطابق

            URLQueryItem(name: "pageSize", value: "1")
            // نحدد حجم الصفحة 1 لأننا نريد أول سجل مطابق فقط لتقليل البيانات
        ]

        let request = try makeRequest(path: "user", queryItems: query)
        // نبني الطلب مع الاستعلامات الخاصة بالفلترة

        let (data, response) = try await URLSession.shared.data(for: request)
        // ننفذ الطلب ونستلم البيانات والاستجابة

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
            // نضمن أن الاستجابة HTTPURLResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
            // نتحقق من نجاح الكود وإلا نرميه كخطأ
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
