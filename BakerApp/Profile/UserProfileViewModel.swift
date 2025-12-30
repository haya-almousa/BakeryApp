//
//  UserProfileViewModel.swift
//  BakerApp
//
//  Created by Haya almousa on 29/12/2025.
//

import Foundation
import Combine

@MainActor
final class UserProfileViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let api = UserAPI.shared
    // استخدام Singleton

    func loadProfile(email userEmail: String) {
        // تحميل بيانات البروفايل
        let trimmedEmail = userEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Missing email."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let user = try await api.fetchUser(byEmail: trimmedEmail)
                name = user.name ?? ""
                email = user.email ?? trimmedEmail
                isLoading = false
            } catch {
                isLoading = false
                // عرض وصف الخطأ القادم من APIError إن وجد
                errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to load profile"
            }
        }
    }

    func reset() {
        // إعادة تعيين حالة العرض عند تسجيل الخروج
        name = ""
        email = ""
        isLoading = false
        errorMessage = nil
    }
}
