//
//  CourseCard.swift
//  BakerApp
//
//  Created by Tala Aldhahri on 07/07/1447 AH.
//
import SwiftUI

struct CourseCard: View {
    let course: Course
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: course.imageURL)){
                image in image.resizable()
                    .aspectRatio(contentMode:.fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 100, height:100)
            .cornerRadius(8)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.headline)
                
                //each course level
                Text(course.level.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(course.level.themeColor)
                    .foregroundColor(.secondaryBrown)
                    .cornerRadius(20)
                HStack(spacing: 4) {
                    Image(systemName: "hourglass")
                        .font(.caption)
                        .foregroundColor(.secondaryBrown)
                    
                    Text(course.duration)
                        .font(.caption)
                        .foregroundColor(.black)
                }
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondaryBrown)
                    
                    Text(course.date)
                        .font(.caption)
                        .foregroundColor(.black)
                }
                
        }
            Spacer()
            
           
        }
        
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y:2 )
        .padding()
    }
}

#Preview {
    CourseCard(course: Course(
        id: UUID(),
        title: "Babka Dough",
        level: .intermediate,
        duration: "2h",
        date: "19 Feb - 4:00",
        imageURL: "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=400&h=400"
    ))
}
