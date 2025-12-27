//
//  CustomTabBar.swift
//  BakerApp
//
//  Created by Tala Aldhahri on 07/07/1447 AH.
//

import SwiftUI

enum Tab {
    case bake, courses, profile
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack(){
            Spacer()
            
            tabButton(image: "BakeTab", label: "Bake", tab: .bake)
            
            Spacer()
            
            tabButton(image: "CoursesTab", label: "Courses", tab: .courses)
            
            Spacer()
            
            tabButton(image: "ProfileTab", label: "Profile", tab: .profile)
            
            Spacer()
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .shadow(radius: 1)
    }
    
    private func tabButton(image: String, label: String, tab: Tab) -> some View {
        Button(action: { selectedTab = tab}) {
            VStack(spacing: 4) {
                Image(image)
                    .renderingMode(.template)
                    .foregroundColor(selectedTab == tab ? .accentColor : .black)
                Text(label)
                    .font(.caption)
                    .foregroundColor(selectedTab == tab ? .accentColor : .black)
            }
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.courses))
}
