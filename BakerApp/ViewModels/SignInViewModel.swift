//
//  SignInViewModel.swift
//  BakerApp
//
//  Created by Haya almousa on 30/12/2025.
//

import Foundation
import Combine
// نستورد Foundation لأننا بنستخدم URLSession و Codable و Error
// ونستورد Combine لأن ObservableObject و @Published موجودين فيه

@MainActor
// نخلي كل التحديثات على الـ UI state تصير على Main Thread

final class SignInViewModel: ObservableObject {
    // هذا ViewModel (طبقة المنطق) ويتوافق مع ObservableObject عشان SwiftUI يراقب التغييرات

    @Published var email: String = ""
    // نخزن إيميل المستخدم اللي يكتبه في الحقل

    @Published var password: String = ""
    // نخزن كلمة المرور اللي يكتبها المستخدم في الحقل

    @Published var isLoading: Bool = false
    // حالة تحميل (عشان نظهر Progress)

    @Published var errorMessage: String?
    // رسالة خطأ لو فشل الدخول أو صار خطأ بالشبكة

    @Published var isPasswordVisible: Bool = false
    // للتحكم بإظهار/إخفاء الباسوورد (عين )

    @Published var isSignedIn: Bool = false
    // إذا True يعني تم تسجيل الدخول بنجاح ونقدر نقفل الـ sheet

    private let api = UserAPI.shared
    // ننشئ API object عشان نجيب users من Airtable (Singleton)

    func signIn() {
        errorMessage = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }

        isLoading = true

        Task {
            do {
                let users = try await api.fetchUsers()
                let match = users.first { user in
                    let uEmail = (user.fields.email ?? "").lowercased()
                    let inputEmail = trimmedEmail.lowercased()
                    let uPass = user.fields.password ?? ""
                    return uEmail == inputEmail && uPass == trimmedPassword
                }

                guard match != nil else {
                    isLoading = false
                    errorMessage = "Invalid email or password."
                    return
                }

                isLoading = false
                isSignedIn = true
                UserDefaults.standard.set(trimmedEmail, forKey: "currentUserEmail")
            } catch {
                isLoading = false
                errorMessage = "Something went wrong. Try again."
            }
        }
    }
}
