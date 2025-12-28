//
//  Splash.swift
//  BakerApp
//
//  Created by Farah Almozaini on 28/12/2025.
//

import SwiftUI

struct SplashView: View {
    // مدة عرض السبلاش قبل الانتقال
    private let displayDuration: TimeInterval = 1.6
    // حالة للانتقال للواجهة الرئيسية
    @State private var isActive = false
    // أنيميشن بسيط
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0.0
    
    var body: some View {
        Group {
            if isActive {
                ContentView()
            } else {
                ZStack {
                    Color(.systemBackground).ignoresSafeArea()
                    
                    VStack(spacing: 12) {
                        // استبدلي هذا بـ Image("LogoBread") لو عندك لوجو في Assets
                        Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.brown, Color(.systemGray5))
                            .font(.system(size: 84, weight: .regular))
                            .padding(.bottom, 4)
                        
                        Text("Home Bakery")
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundColor(.brown)
                        
                        Text("Baked to Perfection")
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundColor(.brown.opacity(0.9))
                    }
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.6)) {
                            scale = 1.0
                            opacity = 1.0
                        }
                    }
                }
                .onAppear {
                    // الانتقال بعد مدة العرض
                    DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
