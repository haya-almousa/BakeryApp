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
    
    // mock data
    let courses: [Course] = [
        Course(id: UUID(), title: "Babka Dough", level: .intermediate, duration: "2h", date: "19 Feb - 4:00", imageURL: "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=400&h=400"),
        Course(id: UUID(), title: "Sourdough Basics", level: .beginner, duration: "3h", date: "20 Feb - 10:00", imageURL: "https://images.unsplash.com/photo-1534620808146-d33bb39128b2?q=80&w=400"),
        Course(id: UUID(), title: "Rye Bread Mastery", level: .advanced, duration: "4h", date: "21 Feb - 09:00", imageURL: "https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=400"),
        Course(id: UUID(), title: "Focaccia Art", level: .beginner, duration: "2h", date: "22 Feb - 14:00", imageURL: "https://images.unsplash.com/photo-1598103442097-8b74394b95c6?q=80&w=400"),
        Course(id: UUID(), title: "Brioche Workshop", level: .intermediate, duration: "5h", date: "23 Feb - 11:00", imageURL: "https://images.unsplash.com/photo-1606312619070-d48b4c652a52?q=80&w=400"),
        Course(id: UUID(), title: "Gluten-Free Loaves", level: .beginner, duration: "3h", date: "24 Feb - 15:00", imageURL: "https://images.unsplash.com/photo-1544681280-d25a782adc9b?q=80&w=400"),
        Course(id: UUID(), title: "Ciabatta Techniques", level: .intermediate, duration: "3h", date: "25 Feb - 10:00", imageURL: "https://images.unsplash.com/photo-1534620808146-d33bb39128b2?q=80&w=400")
    ]
    
    
    var filteredCourses: [Course] {
        if searchText.isEmpty {
            return courses
        } else {
            return courses.filter { course in
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
                                    CourseCard(course: course)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100) // space for the tab bar
                        }
                    }
                    .navigationTitle("Courses")
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color(UIColor.systemGray6))
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
