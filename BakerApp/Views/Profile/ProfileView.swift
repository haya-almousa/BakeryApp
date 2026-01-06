//
//  ProfileView.swift.swift
//  BakerApp
//
//  Created by Haya almousa on 29/12/2025.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject private var viewModel = UserProfileViewModel()
    @AppStorage("currentUserEmail") private var currentUserEmail: String?
    @State private var showSignIn: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Profile")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let email = currentUserEmail {
                content(email: email)
                signOutButton
            } else {
                signedOutView
            }
            
            Spacer()
        }
        .padding()
        .task(id: currentUserEmail) {
            if let email = currentUserEmail, !email.isEmpty {
                viewModel.loadProfile(email: email)
            } else {
                showSignIn = true
            }
        }
        .refreshable {
            if let email = currentUserEmail, !email.isEmpty {
                viewModel.loadProfile(email: email)
            }
        }
        .sheet(isPresented: $showSignIn, onDismiss: {
            if let email = currentUserEmail, !email.isEmpty {
                viewModel.loadProfile(email: email)
            }
        }) {
            SignInView()
        }
    }
    
    @ViewBuilder
    private func content(email: String) -> some View {
        // دالة تبني محتوى القسم الرئيسي حسب حالة الـ ViewModel
        
        if viewModel.isLoading {
            // حالة التحميل
            
            ProgressView("Loading...")
            // مؤشر تحميل مع نص
        } else if let error = viewModel.errorMessage {
            // حالة حدوث خطأ
            
            Text(error)
                .foregroundColor(.red)
            // عرض رسالة الخطأ باللون الأحمر
        } else {
            // حالة النجاح (عرض البيانات)
            
            VStack(alignment: .leading, spacing: 8) {
                // حاوية لعرض البيانات نصيًا
                
                Text("Name: \(viewModel.name.isEmpty ? "—" : viewModel.name)")
                // عرض الاسم أو شرطة إذا فاضي
                
                Text("Email: \(viewModel.email.isEmpty ? "—" : viewModel.email)")
                // عرض الإيميل أو شرطة إذا فاضي
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // تمديد العرض لليمين مع محاذاة لليسار
            
            .padding()
            // حواف داخلية للصندوق
            
            .background(.ultraThinMaterial)
            // خلفية ضبابية خفيفة ملائمة للثيم
            
            .clipShape(RoundedRectangle(cornerRadius: 16))
            // زوايا مستديرة للصندوق
        }
    }
    
    private var signOutButton: some View {
        Button(role: .destructive) {
            currentUserEmail = nil
            viewModel.reset()
            showSignIn = true
        } label: {
            Text("Sign out")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .padding(.top, 8)
    }
    
    private var signedOutView: some View {
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
}
    #Preview {
        NavigationView {
            ProfileView()
        }
    }
