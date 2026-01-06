//
//  ContentView.swift
//  BakerApp
//
//  Created by Haya almousa on 25/12/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .bake

    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case .bake:
                    BakeView()
                case .courses:
                    CoursesView()
                case .profile:
                    // عرض شاشة البروفايل التي تحتوي على قائمة الحجوزات
                    BookingsProfileView()
                }
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
    ContentView()
}
