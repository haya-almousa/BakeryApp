//
//  SignInView.swift
//  BakerApp
//
//  Created by Haya almousa on 30/12/2025.
//

import SwiftUI

struct SignInView: View {

    @StateObject private var viewModel = SignInViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {

                // عنوان وشريط إغلاق
                HStack {
                    Spacer()
                    Text("Sign in")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 6)

                // حقول الإدخال
                VStack(alignment: .leading, spacing: 10) {
                    Text("Email")
                        .font(.headline)

                    TextField("Email", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                        .padding(14)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    Text("Password")
                        .font(.headline)
                        .padding(.top, 6)

                    HStack {
                        Group {
                            if viewModel.isPasswordVisible {
                                TextField("Password", text: $viewModel.password)
                            } else {
                                SecureField("Password", text: $viewModel.password)
                            }
                        }
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                        Button {
                            viewModel.isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: viewModel.isPasswordVisible ? "eye" : "eye.slash")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(14)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // زر الدخول
                Button {
                    viewModel.signIn()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.brown.opacity(0.85))
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Sign in")
                                .foregroundStyle(.white)
                                .font(.headline)
                                .padding(.vertical, 14)
                        }
                    }
                    .frame(height: 52)
                }
                .disabled(viewModel.isLoading)

                Spacer()
            }
            .padding(20)
            .navigationBarHidden(true)
        }
        .onChange(of: viewModel.isSignedIn) { _, signedIn in
            if signedIn {
                dismiss()
            }
        }
        .interactiveDismissDisabled(viewModel.isLoading)
    }
}

#Preview {
    SignInView()
}
