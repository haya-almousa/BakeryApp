//
//  CoursesView.swift
//  BakerApp
//
//  Created by Tala Aldhahri on 07/07/1447 AH.
//
import SwiftUI

struct CoursesView: View {
    
    @State private var selectedTab: Tab = .courses
    @State private var searchText = ""
    
    @StateObject var viewModel = CoursesViewModel()
    
    var filteredCourses: [Course] {
        if searchText.isEmpty {
            return viewModel.courses
        } else {
            return viewModel.courses.filter { course in
                course.title.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        ZStack {
            
            if selectedTab == .courses {
                NavigationStack {
                    VStack(spacing: 9) {
                        
                        Divider()
                        
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search", text: $searchText)
                        }
                        .padding(8)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        ScrollView {
                            
                            LazyVStack(spacing: 8) {
                                ForEach(filteredCourses) { course in
                                    NavigationLink{ //naviagtion link to each course details
                                        DetailsView(course: course, courseRecordId: course.id)
                                    } label: {
                                        CourseCard(course: course)
                                    }
                                        .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100) // space for the tab bar
                        }
                    }
                    .navigationTitle("Courses")
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color(UIColor.systemGray6))
                    .onAppear {
                            viewModel.fetchCourses()
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

#Preview {
    CoursesView()
}
