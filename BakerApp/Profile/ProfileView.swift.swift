//
//  ProfileView.swift.swift
//  BakerApp
//
//  Created by Haya almousa on 29/12/2025.
//

import SwiftUI
import Combine
// نستخدم SwiftUI لبناء واجهة البروفايل

struct ProfileView: View {

    @StateObject private var viewModel = UserProfileViewModel()
    // StateObject عشان ViewModel يعيش مع الصفحة وما يعاد إنشاؤه

    @AppStorage("currentUserEmail") private var currentUserEmail: String?
    // استخدام AppStorage يربط الإيميل الحالي مباشرة مع UserDefaults بشكل تفاعلي

    @State private var showSignIn: Bool = false
    // نتحكم بإظهار شاشة تسجيل الدخول إذا ما فيه مستخدم

    var body: some View {
        VStack(spacing: 16) {

            Text("Profile")
                .font(.title2)
                .fontWeight(.semibold)
            // عنوان الصفحة

            if let email = currentUserEmail {
                // عندنا مستخدم مسجّل

                if viewModel.isLoading {
                    // حالة التحميل
                    ProgressView("Loading...")
                }
                else if let error = viewModel.errorMessage {
                    // حالة الخطأ
                    Text(error)
                        .foregroundColor(.red)
                }
                else {
                    // حالة النجاح (عرض البيانات)
                    VStack(alignment: .leading, spacing: 8) {

                        Text("Name: \(viewModel.name.isEmpty ? "—" : viewModel.name)")
                        // عرض الاسم أو شرطة لو فاضي

                        Text("Email: \(viewModel.email.isEmpty ? "—" : viewModel.email)")
                        // عرض الإيميل أو شرطة لو فاضي
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button(role: .destructive) {
                    // تسجيل خروج بسيط
                    currentUserEmail = nil
                    viewModel.reset()
                    showSignIn = true
                } label: {
                    Text("Sign out")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)

            } else {
                // ما فيه مستخدم — نعرض زر يفتح شاشة تسجيل الدخول
                VStack(spacing: 12) {
                    Text("You’re not signed in.")
                        .foregroundColor(.secondary)
                    Button {
                        showSignIn = true
                    } label: {
                        Text("Sign in")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            Spacer()
        }
        .padding()
        .task(id: currentUserEmail) {
            // كلما تغيّر الإيميل الحالي (تسجيل دخول/خروج)، حمّل البيانات أو أعرض شاشة الدخول
            if let email = currentUserEmail, !email.isEmpty {
                viewModel.loadProfile(email: email)
            } else {
                showSignIn = true
            }
        }
        .refreshable {
            // سحب للتحديث
            if let email = currentUserEmail, !email.isEmpty {
                viewModel.loadProfile(email: email)
            }
        }
        .sheet(isPresented: $showSignIn, onDismiss: {
            // بعد ما تقفل شاشة تسجيل الدخول، إذا صار عندنا إيميل نحمل البروفايل
            if let email = currentUserEmail, !email.isEmpty {
                viewModel.loadProfile(email: email)
            }
        }) {
            // نعرض شاشة تسجيل الدخول
            SignInView()
        }
    }
}
