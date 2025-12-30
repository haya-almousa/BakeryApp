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

    private let currentUserEmail = "paris@hunt.com"
    // الإيميل الحالي (يوزر البروفايل)
    // لاحقًا ممكن يجي من شاشة تسجيل الدخول

    var body: some View {
        VStack(spacing: 16) {

            Text("Profile")
                .font(.title2)
                .fontWeight(.semibold)
            // عنوان الصفحة

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

            Spacer()
        }
        .padding()
        .onAppear {
            print("ProfileView appeared ✅")
            viewModel.loadProfile(email: currentUserEmail)
        }

            // أول ما تفتح الصفحة: ننادي API ونجيب بيانات البروفايل
        }
    }

