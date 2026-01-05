//
//  Profile.swift
//  BakerApp
//
//  Created by Haya almousa on 28/12/2025.
//

import SwiftUI

struct BookingsProfileView: View {
    // شاشة تعرض بروفايل المستخدم مع قائمة حجوزاته
    
    @AppStorage("currentUserEmail") private var currentUserEmail: String?
    @StateObject private var viewModel = ProfileBookingsViewModel()
    @State private var isEditing: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    profileHeader
                    bookedCoursesSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            // تحميل أولي أو عند تغيّر الإيميل
            .task(id: currentUserEmail) {
                if let email = currentUserEmail, !email.isEmpty {
                    viewModel.load(email: email)
                }
            }
            // سحب للتحديث
            .refreshable {
                if let email = currentUserEmail, !email.isEmpty {
                    viewModel.load(email: email)
                }
            }
            // تحديث تلقائي عند إشعار خارجي (مثلاً بعد إنشاء/إلغاء حجز)
            .onReceive(NotificationCenter.default.publisher(for: .bookingDidChange)) { _ in
                if let email = currentUserEmail, !email.isEmpty {
                    viewModel.load(email: email)
                }
            }
        }
    }
}

private extension BookingsProfileView {
    var profileHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(.systemBrown).opacity(0.25))
                    .frame(width: 44, height: 44)
                Image(systemName: "person")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.brown)
                VStack {
                    Spacer()
                    HStack {
                        Circle()
                            .fill(Color(.systemBrown))
                            .frame(width: 18, height: 18)
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
                .frame(width: 44, height: 44)
            }
            
            if isEditing {
                TextField("username", text: Binding(
                    get: { viewModel.name },
                    set: { viewModel.name = $0 }
                ))
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Text(viewModel.name.isEmpty ? (currentUserEmail ?? "User") : viewModel.name)
                    .font(.headline)
            }
            
            Spacer()
            
            Button(isEditing ? "Done" : "Edit") {
                isEditing.toggle()
            }
            .font(.callout.weight(.semibold))
            .foregroundStyle(.brown)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color(.systemGray5), lineWidth: 1)
        }
    }
    
    var bookedCoursesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Booked courses")
                .font(.title3.weight(.bold))
            
            if viewModel.isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Loading your bookings…")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.orange)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Button {
                        if let email = currentUserEmail, !email.isEmpty {
                            viewModel.load(email: email)
                        }
                    } label: {
                        Text("Try again")
                            .font(.callout.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.brown.opacity(0.1))
                            .foregroundStyle(.brown)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
            } else if viewModel.bookedCourses.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.bookedCourses) { course in
                        CourseCard(course: course) // نفس البطاقة المستخدمة في Bake
                    }
                }
            }
        }
        .padding(.top, 4)
    }
    
    var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar")
                .font(.system(size: 54))
                .foregroundStyle(Color(.systemGray3))
            Text("You don't have any booked courses")
                .font(.callout)
                .foregroundStyle(Color(.systemGray2))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }
}

#Preview {
    BookingsProfileView()
}
