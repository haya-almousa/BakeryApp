//
//  Profile.swift
//  BakerApp
//
//  Created by Haya almousa on 28/12/2025.
//

import SwiftUI

struct BookingsProfileView: View {
    // We watch this storage to know if we are logged in or not
    @AppStorage("currentUserEmail") private var currentUserEmail: String?
    
    @StateObject private var viewModel = ProfileBookingsViewModel()
    @State private var isEditing: Bool = false
    
    // 1. Add state to control the Sign In sheet
    @State private var showSignIn: Bool = false
    
    var body: some View {
        NavigationStack {
            // 2. Check login status
            if let email = currentUserEmail, !email.isEmpty {
                // LOGGED IN: Show the profile and bookings
                ScrollView {
                    VStack(spacing: 16) {
                        profileHeader
                        bookedCoursesSection
                        
                        // Optional: Add a Sign Out button here
                        Button("Sign Out", role: .destructive) {
                            currentUserEmail = nil
                            viewModel.bookedCourses = []
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    // This triggers every time the view becomes visible
                    if let email = currentUserEmail, !email.isEmpty {
                        viewModel.load(email: email)
                    }
                }
                .refreshable {
                     viewModel.load(email: email)
                }
            } else {
                // NOT LOGGED IN: Show the Sign In prompt
                signedOutView
            }
        }
        // 3. Add the sheet modifier to present SignInView
        .sheet(isPresented: $showSignIn) {
            SignInView()
        }
    }
}

private extension BookingsProfileView {
    
    // 4. Create the view for the "Not Logged In" state
    var signedOutView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            
            Text("Log in to view your bookings")
                .font(.headline)
            
            Button {
                showSignIn = true
            } label: {
                Text("Sign in")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.brown)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
    }

    var profileHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(.systemBrown).opacity(0.25))
                    .frame(width: 44, height: 44)
                Image(systemName: "person")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.brown)
            }
            
            if isEditing {
                TextField("username", text: Binding(
                    get: { viewModel.name },
                    set: { viewModel.name = $0 }
                ))
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .padding(10)
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
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            } else if viewModel.bookedCourses.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.bookedCourses) { course in
                        // Ensure DetailsView is available in your project
                        NavigationLink(destination: DetailsView(course: course, courseRecordId: course.id)) {
                             CourseCard(course: course)
                        }
                        .buttonStyle(.plain)
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
