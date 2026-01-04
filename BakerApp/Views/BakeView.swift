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
 
    let courses: [Course] = [
        Course(id: UUID(), title: "Babka Dough", level: .intermediate, duration: "2h", date: "19 Feb - 4:00", image_url: "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=400&h=400"),
        Course(id: UUID(), title: "Cinnamon rolls", level: .beginner, duration: "2h", date: "19 Feb - 4:00", image_url: "https://images.unsplash.com/photo-1534620808146-d33bb39128b2?q=80&w=400"),
        Course(id: UUID(), title: "Japanese bread", level: .advanced, duration: "4h", date: "21 Feb - 09:00", image_url: "https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=400"),
        Course(id: UUID(), title: "Banana bread", level: .beginner, duration: "2h", date: "22 Feb - 14:00", image_url: "https://images.unsplash.com/photo-1598103442097-8b74394b95c6?q=80&w=400")
    ]
   
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
                        }
                        .padding(8)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
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
                                
                                LazyVStack(spacing: 8) {
                                    ForEach(courses) { course in
                                        NavigationLink {
                                            DetailsView(course: course)
                                        } label: {
                                            CourseCard(course: course)
                                        }
                                        .buttonStyle(.plain) // يحافظ على شكل الكارد بدون تلوين الرابط
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 100) // مساحة للتاب بار
                            }
                        }
                    }
                    .navigationTitle("Home Bakery")
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
