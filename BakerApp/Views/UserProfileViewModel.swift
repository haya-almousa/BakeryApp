//
//  UserProfileViewModel.swift
//  BakerApp
//
//  Created by Haya almousa on 29/12/2025.
//

import Foundation
import Combine
// نحتاج Combine لـ ObservableObject و @Published

@MainActor
// نضمن أن أي تحديث للواجهة يتم على الـ Main Thread
final class UserProfileViewModel: ObservableObject {

    @Published var name: String = ""
    // الاسم اللي راح نعرضه في صفحة البروفايل

    @Published var email: String = ""
    // الإيميل اللي راح نعرضه في صفحة البروفايل

    @Published var isLoading: Bool = false
    // حالة التحميل (true أثناء جلب البيانات)

    @Published var errorMessage: String?
    // رسالة خطأ لو فشل الطلب

    private let api = UserAPI()
    // نستخدم UserAPI اللي سويناه بالخطوة السابقة

    func loadProfile(email userEmail: String) {
        // هذه الدالة تناديها الواجهة أول ما تفتح صفحة البروفايل
        print("loadProfile called with email:", email)

        isLoading = true
        // نبدأ التحميل

        errorMessage = nil
        // نمسح أي خطأ سابق

        Task {
            // نفتح Task عشان نستخدم async/await

            do {
                let user = try await api.fetchUser(byEmail: userEmail)
                // ننادي API ونجيب بيانات اليوزر بالإيميل

                name = user.name ?? ""
                // نخزن الاسم (ولو nil نخليه فاضي)

                email = user.email ?? userEmail
                // نخزن الإيميل (ولو ما رجع نخليه نفس المدخل)

                isLoading = false
                // نوقف التحميل بعد النجاح

            } catch {
                isLoading = false
                // نوقف التحميل

                errorMessage = "Failed to load profile"
                // رسالة خطأ بسيطة للعرض
            }
        }
    }
}
/* البروفايل”؟
 UserAPI: يجلب البيانات
 ViewModel: يقرر
 متى نعرض Loading
 متى نعرض Error
 متى نعرض Data
 View (بالخطوة الجاية): تعرض فقط*/
