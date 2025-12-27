//
//  CoursesView.swift
//  BakerApp
//
//  Created by Tala Aldhahri on 07/07/1447 AH.
//

import SwiftUI

struct CoursesView: View {
    
    @State private var searchText = ""
    
    let courses: [Course] =
    [Course(id: UUID(), title: "Babka Dough", level: .intermediate, duration: "2h", date: "19 Feb - 4:00", imageURL: "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=400&h=400")]
    
    var filteredCourses: [Course] {
        if searchText.isEmpty {
            return courses
        } else {
            return courses.filter {
                course in course.title.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        TabView{
            
            NavigationStack {
                ScrollView{
                    LazyVStack (spacing: 20 ){
                        ForEach(filteredCourses){
                            course in CourseCard(course: course)
                        }
                    }
                    .padding(.top)
                }
                .navigationTitle("Courses")
                .searchable(text: $searchText )
                .background(Color(UIColor.systemGray6))
            }
            
        }
    }
}

#Preview {
    CoursesView()
}
