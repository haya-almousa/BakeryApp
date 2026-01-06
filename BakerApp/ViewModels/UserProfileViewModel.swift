//
//  UserProfileViewModel.swift
//  BakerApp
//
//  Created by Haya almousa on 29/12/2025.
//

import Foundation
// استيراد Foundation للأنواع الأساسية

import Combine
// استيراد Combine (لاستخدامه مستقبلاً إن لزم، رغم أننا نستخدم Concurrency)

@MainActor
// تنفيذ كل تحديثات الحالة على المسار الرئيسي

final class UserProfileViewModel: ObservableObject {
    // ViewModel يدير حالة شاشة البروفايل

    @Published var name: String = ""
    // اسم المستخدم المعروض

    @Published var email: String = ""
    // إيميل المستخدم المعروض

    @Published var isLoading: Bool = false
    // حالة تدل على وجود تحميل جارٍ

    @Published var errorMessage: String?
    // رسالة خطأ لعرضها عند الفشل

    private let api = UserAPI.shared
    // مرجع لخدمة الـ API (Singleton)

    private var loadTask: Task<Void, Never>?
    // الاحتفاظ بمهمة التحميل الحالية لإمكانية إلغائها عند بدء تحميل جديد

    func loadProfile(email userEmail: String) {
        // دالة لتحميل بيانات البروفايل حسب الإيميل

        let trimmedEmail = userEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        // تنظيف الإيميل من الفراغات

        guard !trimmedEmail.isEmpty else {
            // التحقق من أن الإيميل غير فارغ

            errorMessage = "Missing email."
            // ضبط رسالة خطأ مناسبة

            return
            // إيقاف التنفيذ
        }

        loadTask?.cancel()
        // إلغاء أي تحميل سابق قيد التنفيذ

        isLoading = true
        // بدء حالة التحميل

        errorMessage = nil
        // مسح أي أخطاء سابقة

        loadTask = Task { [weak self] in
            // إنشاء مهمة غير متزامنة لتحميل البيانات

            guard let self else { return }
            // التأكد من وجود self

            do {
                let user = try await api.fetchUser(byEmail: trimmedEmail)
                // استدعاء API لجلب المستخدم عبر الإيميل

                self.name = user.name ?? ""
                // حفظ الاسم (أو فارغ إذا غير موجود)

                self.email = user.email ?? trimmedEmail
                // حفظ الإيميل (أو المدخل إذا غير موجود)

                self.isLoading = false
                // إنهاء حالة التحميل
            } catch is CancellationError {
                // إذا تم إلغاء المهمة

                // تجاهل الإلغاء بدون تغيير الحالة
            } catch {
                // أي خطأ آخر

                self.isLoading = false
                // إنهاء حالة التحميل

                self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to load profile"
                // ضبط رسالة خطأ مقروءة للمستخدم
            }
        }
    }

    func reset() {
        // إعادة تعيين حالة الـ ViewModel (عند تسجيل الخروج)

        loadTask?.cancel()
        // إلغاء أي مهام جارية

        name = ""
        // مسح الاسم

        email = ""
        // مسح الإيميل

        isLoading = false
        // إيقاف حالة التحميل

        errorMessage = nil
        // مسح رسالة الخطأ
    }
}
// نهاية UserProfileViewModel

