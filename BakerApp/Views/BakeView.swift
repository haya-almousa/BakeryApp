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
                                        Text("Upcoming")
                                            .font(.headline)
                                            .padding(.horizontal)
                                        
                                        UpcomingCard()
                                            .padding(.horizontal)
                                        
                                        // Popular courses
                                        Text("Popular courses")
                                            .font(.headline)
                                            .padding(.horizontal)
                                        
                                        if filteredCourses.isEmpty {
                                            Text("No courses match your search.")
                                                .font(.callout)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal)
                                                .padding(.top, 8)
                                        } else {
                                            LazyVStack(spacing: 8) {
                                                ForEach(filteredCourses) { course in
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
                        // استدعِ مرة واحدة فقط
                        if viewModel.courses.isEmpty && !viewModel.isLoading {
                            viewModel.fetchCourses()
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
