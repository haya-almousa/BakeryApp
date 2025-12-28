//
//  Details.swift
//  BakerApp
//
//  Created by Farah Almozaini on 28/12/2025.
//

import SwiftUI
import MapKit

struct DetailsView: View {
    let course: Course
    @State private var showBookedAlert = false
    @State private var showSuccessCard = false
    @State private var isBooked = false
    @State private var showCancelAlert = false
    
    // MARK: - Map state
    // Apple Developer Academy (temporary location)
    private let locationName = "Apple Developer Academy"
    private let locationCoordinate = CLLocationCoordinate2D(latitude: 24.713551, longitude: 46.675297)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.713551, longitude: 46.675297),
        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
    )
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Top image
                        AsyncImage(url: URL(string: course.imageURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .fill(Color(.systemGray5))
                        }
                        .frame(height: 240)
                        .clipped()
                        
                        // Content card
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // Title
                            Text(course.title)
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.primary)
                            
                            // About the course
                            VStack(alignment: .leading, spacing: 8) {
                                Text("About the course:")
                                    .font(.headline)
                                
                                Text("""
                                Needless to say, you will learn new techniques, new ingredients, and new recipes when taking a baking class. Not only that, but baking also involves creating food presentations and plating.
                                """)
                                .font(.callout)
                                .foregroundColor(Color(.label))
                                .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            // Info grid
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .top) {
                                    // Left column
                                    VStack(alignment: .leading, spacing: 12) {
                                        labeledValue(label: "Chef", valueView:
                                            Text("Ali Boholaiqa")
                                                .foregroundColor(.primary)
                                        )
                                        
                                        labeledValue(label: "Level", valueView:
                                            Text(course.level.rawValue)
                                                .font(.caption.weight(.semibold))
                                                .padding(.vertical, 4)
                                                .padding(.horizontal, 10)
                                                .background(course.level.themeColor)
                                                .foregroundColor(.brown) // بديل مؤقت لـ .secondaryBrown
                                                .clipShape(Capsule())
                                        )
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // Right column
                                    VStack(alignment: .leading, spacing: 12) {
                                        labeledValue(label: "Duration", valueView:
                                            Text(course.duration)
                                                .foregroundColor(.primary)
                                        )
                                        
                                        labeledValue(label: "Date & time", valueView:
                                            Text(course.date)
                                                .foregroundColor(.primary)
                                        )
                                        
                                        labeledValue(label: "Location", valueView:
                                            Text(locationName)
                                                .foregroundColor(.primary)
                                        )
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        
                        // MARK: - Map block (temporary Apple Developer Academy)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location")
                                .font(.headline)
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 12) {
                                Map(coordinateRegion: $region, annotationItems: [MapPinItem(coordinate: locationCoordinate)]) { item in
                                    MapMarker(coordinate: item.coordinate, tint: .brown)
                                }
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(.systemGray5), lineWidth: 1)
                                )
                                
                                Button {
                                    openInMaps(at: locationCoordinate, named: locationName)
                                } label: {
                                    Label("Open in Maps", systemImage: "map")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.brown)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemGray6))
                                        )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 8)
                        
                        Spacer(minLength: 80) // مساحة فوق الزر
                    }
                }
                
                // Bottom fixed button
                VStack {
                    if isBooked {
                        // زر إلغاء الحجز
                        Button {
                            showCancelAlert = true
                        } label: {
                            Text("Cancel booking")
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(.systemBackground))
                                )
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.clear)
                    } else {
                        // زر الحجز
                        Button {
                            isBooked = true
                            // عرض كارد النجاح في المنتصف
                            showSuccessCard = true
                            // إخفاء تلقائي بعد 2 ثانية
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut) {
                                    showSuccessCard = false
                                }
                            }
                        } label: {
                            Text("Book a space")
                                .font(.headline)
                                .foregroundColor(.white) // بديل لـ whitesh
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.brown) // بديل لـ secondaryBrown
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.clear)
                    }
                }
                .background(Color(UIColor.systemGray6).ignoresSafeArea(edges: .bottom))
            }
            
            // Overlay: كارد النجاح الصغير في المنتصف
            if showSuccessCard {
                SuccessCard()
                    .transition(.scale.combined(with: .opacity))
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showSuccessCard = false
                        }
                    }
            }
        }
        .navigationTitle(course.title)
        .navigationBarTitleDisplayMode(.inline)
        // احتفظت بالـ Alert القديم لو حبيت تستخدمه لاحقًا (غير مستخدم الآن)
        .alert("Booked!", isPresented: $showBookedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your spot has been reserved.")
        }
        // Alert تأكيد إلغاء الحجز
        .alert("Cancel booking?", isPresented: $showCancelAlert) {
            Button("No", role: .cancel) { }
            Button("Yes", role: .destructive) {
                isBooked = false
            }
        } message: {
            Text("Do you want to cancel your booking")
        }
        .onAppear {
            // sync the region with the coordinate in case you pass different locations later
            region.center = locationCoordinate
        }
    }
    
    @ViewBuilder
    private func labeledValue<V: View>(label: String, valueView: V) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label + ":")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color(.secondaryLabel))
            valueView
                .font(.subheadline)
        }
    }
    
    // Open Apple Maps to this coordinate
    private func openInMaps(at coordinate: CLLocationCoordinate2D, named name: String) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        ])
    }
}

// Helper for Map annotations
private struct MapPinItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// الكارد الصغير (مثل الصورة)
private struct SuccessCard: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.brown, lineWidth: 3)
                    .frame(width: 56, height: 56)
                Image(systemName: "checkmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.brown)
            }
            
            Text("Successful")
                .font(.headline)
                .foregroundColor(.brown)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
    }
}

#Preview {
    NavigationStack {
        DetailsView(course: Course(
            id: UUID(),
            title: "Babka dough",
            level: .intermediate,
            duration: "2h",
            date: "15 Dec - 4:00 pm",
            imageURL: "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&h=800"
        ))
    }
}
