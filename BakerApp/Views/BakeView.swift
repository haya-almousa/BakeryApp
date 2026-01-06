//
//  Bake.swift
//  BakerApp
//
//  Created by Farah Almozaini on 28/12/2025.
//

import SwiftUI

struct BakeView: View {
    @State private var searchText = ""
    @State private var selectedTab: Tab = .bake
    @StateObject private var viewModel = CoursesViewModel()
    
    // تصفية حسب البحث
    private var filteredCourses: [Course] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return viewModel.courses }
        return viewModel.courses.filter { course in
            course.title.localizedCaseInsensitiveContains(q)
            || course.level.rawValue.localizedCaseInsensitiveContains(q)
            || course.duration.localizedCaseInsensitiveContains(q)
            || course.date.localizedCaseInsensitiveContains(q)
        }
    }
    
    var body: some View {
        ZStack {
            if selectedTab == .bake {
                NavigationStack {
                    VStack(spacing: 9) {
                        
                        Divider()
                        
                        // Search
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search", text: $searchText)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        }
                        .padding(8)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        // حالات التحميل/الخطأ/القائمة
                        Group {
                            if viewModel.isLoading {
                                VStack(spacing: 12) {
                                    ProgressView()
                                    Text("Loading courses…")
                                        .foregroundColor(.secondary)
                                        .font(.callout)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else if let error = viewModel.errorMessage {
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 28, weight: .semibold))
                                        .foregroundColor(.orange)
                                    Text(error)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                    Button {
                                        viewModel.fetchCourses()
                                    } label: {
                                        Text("Try again")
                                            .font(.callout.weight(.semibold))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(Color.brown.opacity(0.1))
                                            .foregroundColor(.brown)
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.horizontal, 24)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 16) {
                                        // Upcoming
                                        // 1. Header
                                        Text("Upcoming")
                                            .font(.title3)
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)

                                        // 2. Dynamic Card
                                        if let course = viewModel.upcomingCourse {
                                            HStack(spacing: 16) {
                                                // --- Date Box ---
                                                VStack {
                                                    // Extract Month (e.g., "Dec")
                                                    Text(course.startDate?.formatted(.dateTime.month()) ?? "")
                                                        .font(.caption)
                                                        .foregroundStyle(.gray)
                                                    
                                                    // Extract Day (e.g., "15")
                                                    Text(course.startDate?.formatted(.dateTime.day()) ?? "")
                                                        .font(.title2)
                                                        .bold()
                                                        .foregroundStyle(.black)
                                                }
                                                .frame(width: 50, height: 60)
                                                .background(Color.white)
                                                .cornerRadius(10)
                                                
                                                // --- Course Details ---
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(course.title)
                                                        .font(.headline)
                                                        .foregroundStyle(.black)
                                                    
                                                    HStack(spacing: 6) {
                                                        Image(systemName: "location.fill") // Or generic pin
                                                            .font(.caption2)
                                                        Text(course.locationName) // Or use course.level.rawValue
                                                            .font(.caption)
                                                    }
                                                    .foregroundStyle(.gray)
                                                    
                                                    HStack(spacing: 6) {
                                                        Image(systemName: "clock")
                                                            .font(.caption2)
                                                        
                                                        // Show formatted time (e.g. 4:00 PM)
                                                        if let date = course.startDate {
                                                            Text(date.formatted(date: .omitted, time: .shortened))
                                                                .font(.caption)
                                                        }
                                                    }
                                                    .foregroundStyle(.gray)
                                                }
                                                
                                                Spacer()
                                                
                                                // --- Bell Icon ---
                                                Image(systemName: "bell.fill")
                                                    .foregroundStyle(Color.orange) // Or your app's accent color
                                            }
                                            .padding()
                                            .background(Color(.systemGray6)) // Light gray background
                                            .cornerRadius(16)
                                            .padding(.horizontal)
                                            
                                        } else {
                                            // Optional: Show this if nothing is upcoming
                                            Text("No upcoming courses this week")
                                                .font(.subheadline)
                                                .foregroundStyle(.gray)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal)
                                        }
                                        // Popular courses
                                        Text("Popular courses")
                                            .font(.headline)
                                            .padding(.horizontal)
                                        
                                        if viewModel.popularCourses.isEmpty {
                                            Text("No courses match your search.")
                                                .font(.callout)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal)
                                                .padding(.top, 8)
                                        } else {
                                            LazyVStack(spacing: 8) {
                                                ForEach(viewModel.popularCourses) { course in
                                                    NavigationLink {
                                                        DetailsView(course: course, courseRecordId: course.id )
                                                    } label: {
                                                        CourseCard(course: course)
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                        
                                        Spacer(minLength: 0)
                                            .frame(height: 100) // مساحة للتاب بار
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("Home Bakery")
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color(UIColor.systemGray6))
                    .onAppear {
                        // Load Courses if missing
                        if viewModel.courses.isEmpty && !viewModel.isLoading {
                            viewModel.fetchCourses()
                        }
                        
                        // Load Bookings if missing
                        if viewModel.bookedCourses.isEmpty {
                            viewModel.fetchBookings()
                        }
                    }
                }
            } else {
                Color(UIColor.systemGray6)
                    .overlay(Text(selectedTab == .bake ? "Bake Screen" : "Profile Screen"))
            }
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

private struct UpcomingCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack {
                Text("Dec")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("15")
                    .font(.title2.bold())
                Spacer(minLength: 0)
            }
            .frame(width: 56, height: 72)
            .padding(8)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Babka dough")
                    .font(.headline)
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.secondaryBrown)
                        .font(.caption)
                    Text("Riyadh, Alnarjis")
                        .font(.caption)
                        .foregroundColor(.black)
                }
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .foregroundColor(.secondaryBrown)
                        .font(.caption)
                    Text("4:00 pm")
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    BakeView()
}
