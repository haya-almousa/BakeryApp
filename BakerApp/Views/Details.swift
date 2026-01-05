//
//  Details.swift
//  BakerApp
//
//  Created by Farah Almozaini on 28/12/2025.
//

import SwiftUI
import MapKit
import Combine

struct DetailsView: View {
    let course: Course
    @State private var showBookedAlert = false
    @State private var showSuccessCard = false
    @State private var isBooked = false
    @State private var showCancelAlert = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var myBookingRecordId: String?
    
    // جلب اسم الشيف عبر chef_id
    @StateObject private var chefVM = ChefViewModel()

    // MARK: - Map state
    private var locationName: String {
        course.locationName.isEmpty ? "Location" : course.locationName
    }
    private var locationCoordinate: CLLocationCoordinate2D {
        if let lat = course.latitude, let lon = course.longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            // Fallback: Apple Developer Academy (مؤقت)
            return CLLocationCoordinate2D(latitude: 24.713551, longitude: 46.675297)
        }
    }
    // iOS 17+ Map camera position (replaces MKCoordinateRegion binding)
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 24.713551, longitude: 46.675297),
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        )
    )
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Top image
                    AsyncImage(url: URL(string: course.image_url)) { image in
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
                            .foregroundColor(Color(.label))
                            
                            let aboutText = course.description.trimmingCharacters(in: .whitespacesAndNewlines)
                            Text(aboutText.isEmpty ? "—" : aboutText)
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
                                        Group {
                                            if chefVM.isLoading {
                                                ProgressView().scaleEffect(0.7)
                                            } else if let name = chefVM.name, !name.isEmpty {
                                                Text(name)
                                                    .foregroundColor(.primary)
                                            } else {
                                                Text("—")
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    )
                                    
                                    labeledValue(label: "Level", valueView:
                                        Text(course.level.rawValue)
                                            .font(.caption.weight(.semibold))
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 10)
                                            .background(course.level.themeColor)
                                            .foregroundColor(.white) // <-- تغيّر إلى أبيض
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
                    
                    // MARK: - Map block
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.headline)
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 12) {
                            // New iOS 17 Map API using MapContentBuilder
                            Map(position: $cameraPosition) {
                                // Single marker for the location
                                Marker(locationName, coordinate: locationCoordinate)
                                    .tint(.brown)
                            }
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(.systemGray5), lineWidth: 1)
                            )
                            .onAppear {
                                // اضبط الكاميرا بناءً على موقع الدورة
                                cameraPosition = .region(
                                    MKCoordinateRegion(
                                        center: locationCoordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                                    )
                                )
                            }
                            
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
                        
                        // زر الحجز أسفل الماب مباشرة (جزء من المحتوى)
                        VStack {
                            if isBooked {
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
                                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 4)
                            } else {
                                Button {
                                    isBooked = true
                                    showSuccessCard = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation(.easeInOut) {
                                            showSuccessCard = false
                                        }
                                    }
                                } label: {
                                    Text("Book a space")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.brown)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .padding(.bottom, 14)
                    }
                    .padding(.top, 4)
                    
                    // مسافة عامة إضافية قبل التاب بار
                    Spacer(minLength: 32)
                }
            }
            
            // Overlay: كارد النجاح الصغير في المنتصف
            if showSuccessCard {
                SuccessCard()
                    .transition(.scale .combined(with: .opacity))
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showSuccessCard = false
                        }
                    }
            }
        }
        .navigationTitle(course.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Booked!", isPresented: $showBookedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your spot has been reserved.")
        }
        .alert("Cancel booking?", isPresented: $showCancelAlert) {
            Button("No", role: .cancel) { }
            Button("Yes", role: .destructive) {
                isBooked = false
            }
        } message: {
            Text("Do you want to cancel your booking")
        }
        .task {
            await loadMyBookingState()
            // تحميل اسم الشيف إذا توفر chefId
            if let chefId = course.chefId, !chefId.isEmpty {
                await chefVM.load(chefId: chefId)
            }
        }
        // أزلنا safeAreaInset لأن الزر صار جزء من المحتوى تحت الماب
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
    
    // Temporary placeholder to fix build; replace with real logic using BookingViewModel/BookingAPI.
    private func loadMyBookingState() async {
        // TODO: Integrate with BookingViewModel once courseRecordId and user email are available.
        await MainActor.run {
            self.isBooked = false
            self.myBookingRecordId = nil
            self.errorMessage = nil
            self.isLoading = false
        }
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

// MARK: - Chef API models + VM (محلية داخل هذا الملف)
private struct ChefFields: Codable {
    let name: String?
}

@MainActor
private final class ChefViewModel: ObservableObject {
    @Published var name: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func load(chefId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            // نبني رابط Airtable: base/chef/{recordId}
            let baseURL = APIConstants.baseURL
            guard var components = URLComponents(string: baseURL) else {
                throw APIError.invalidURL
            }
            components.path = components.path + "/chef/\(chefId)"
            guard let url = components.url else {
                throw APIError.invalidURL
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(APIConstants.token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            guard (200...299).contains(http.statusCode) else {
                throw APIError.httpStatus(http.statusCode)
            }
            // نفك AirtableRecord<ChefFields>
            let record = try JSONDecoder().decode(AirtableRecord<ChefFields>.self, from: data)
            self.name = record.fields.name
            self.isLoading = false
        } catch is CancellationError {
            // تم الإلغاء
            isLoading = false
        } catch {
            isLoading = false
            // حاول استخدام LocalizedError إن وُجد
            if let err = error as? LocalizedError, let desc = err.errorDescription {
                errorMessage = desc
            } else {
                errorMessage = "Failed to load chef."
            }
            // فشل الجلب → ابقِ الاسم nil ليظهر "—"
        }
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
            image_url: "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&h=800",
            description: "Create a simple and delicious banana bread recipe in a hands-on session suitable for all ages.",
            locationName: "Ferriday",
            latitude: 31.63017,
            longitude: -91.55456,
            chefId: "recF8ocLPwiadavlP",
            startDate: Date(),
            endDate: Date().addingTimeInterval(7200)
        ))
    }
}
