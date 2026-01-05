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
    // We need the Airtable Record ID (String) for the API.
    let courseRecordId: String
    
    // MARK: - Booking Logic
    // Initialize the ViewModel with the specific course ID
    @StateObject private var bookingVM: BookingViewModel
    
    // Retrieve the logged-in user's email.
    @AppStorage("userEmail") private var currentUserEmail: String = "paris@hunt.com"
    
    @State private var showBookedAlert = false
    @State private var showSuccessCard = false
    @State private var showCancelAlert = false
    
    // Check local booking state against API data
    private var isBooked: Bool {
        return bookingVM.bookingOfUser(id: currentUserEmail) != nil
    }
    
    // Chef ViewModel
    @StateObject private var chefVM = ChefViewModel()

    init(course: Course, courseRecordId: String) {
        self.course = course
        self.courseRecordId = courseRecordId
        // Initialize the StateObject with the course ID manually
        _bookingVM = StateObject(wrappedValue: BookingViewModel(courseRecordId: courseRecordId))
    }

    // MARK: - Map state
    private var locationName: String {
        course.locationName.isEmpty ? "Location" : course.locationName
    }
    
    private var locationCoordinate: CLLocationCoordinate2D {
        if let lat = course.latitude, let lon = course.longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            return CLLocationCoordinate2D(latitude: 24.713551, longitude: 46.675297)
        }
    }
    
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
                                            .foregroundColor(.white)
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
                            Map(position: $cameraPosition) {
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
                        
                        // Error Message Display
                        if let error = bookingVM.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                        }

                        // MARK: - Booking Buttons
                        VStack {
                            if bookingVM.isLoading && !bookingVM.isPerformingAction {
                                ProgressView().padding()
                            } else if isBooked {
                                // CANCEL BUTTON
                                Button {
                                    showCancelAlert = true
                                } label: {
                                    HStack {
                                        if bookingVM.isPerformingAction {
                                            ProgressView().tint(.red)
                                        }
                                        Text("Cancel booking")
                                            .font(.headline)
                                            .foregroundColor(.red)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color(.systemBackground))
                                    )
                                }
                                .disabled(bookingVM.isPerformingAction)
                                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 4)
                                
                            } else {
                                // BOOK BUTTON
                                Button {
                                    performBooking()
                                } label: {
                                    HStack {
                                        if bookingVM.isPerformingAction {
                                            ProgressView().tint(.white).padding(.trailing, 5)
                                        }
                                        Text("Book a space")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.brown)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                .disabled(bookingVM.isPerformingAction)
                                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .padding(.bottom, 14)
                    }
                    .padding(.top, 4)
                    
                    Spacer(minLength: 32)
                }
            }
            
            // Success Overlay
            if showSuccessCard {
                SuccessCard()
                    .transition(.scale.combined(with: .opacity))
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showSuccessCard = false
                        }
                    }
                    .zIndex(100)
            }
        }
        .navigationTitle(course.title)
        .navigationBarTitleDisplayMode(.inline)
        // MARK: - Alerts
        .alert("Booked!", isPresented: $showBookedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your spot has been reserved.")
        }
        .alert("Cancel booking?", isPresented: $showCancelAlert) {
            Button("No", role: .cancel) { }
            Button("Yes", role: .destructive) {
                performCancellation()
            }
        } message: {
            Text("Do you want to cancel your booking?")
        }
        // MARK: - View Tasks (Load Data)
        .task {
            await bookingVM.fetch()
            if let chefId = course.chefId, !chefId.isEmpty {
                await chefVM.load(chefId: chefId)
            }
        }
        // MARK: - State Changes (Correctly placed inside body)
        .onChange(of: bookingVM.lastCreatedBooking?.id) { newValue in
            if newValue != nil {
                showSuccessCard = true
                showBookedAlert = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut) {
                        showSuccessCard = false
                    }
                }
            }
        }
    } // End of body
    
    // MARK: - Action Functions
    
    private func performBooking() {
        guard !currentUserEmail.isEmpty else {
            print("❌ User email is missing")
            return
        }
        bookingVM.book(userEmail: currentUserEmail)
    }
    
    private func performCancellation() {
        guard let myBooking = bookingVM.bookingOfUser(id: currentUserEmail) else { return }
        bookingVM.cancel(bookingRecordId: myBooking.id)
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

// Helper structs
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

// Local Chef ViewModel
@MainActor
private final class ChefViewModel: ObservableObject {
    @Published var name: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func load(chefId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let baseURL = APIConstants.baseURL
            guard var components = URLComponents(string: baseURL) else { throw APIError.invalidURL }
            components.path = components.path + "/chef/\(chefId)"
            guard let url = components.url else { throw APIError.invalidURL }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(APIConstants.token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
            
            struct ChefFields: Codable { let name: String? }
            let record = try JSONDecoder().decode(AirtableRecord<ChefFields>.self, from: data)
            self.name = record.fields.name
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        DetailsView(
            course: Course(
                id: "rec1DauP3kw5Q76oo",
                title: "Babka dough",
                level: .intermediate,
                duration: "2h",
                date: "15 Dec - 4:00 pm",
                image_url: "https://example.com/image.jpg",
                description: "Description...",
                locationName: "Riyadh",
                latitude: 24.7136,
                longitude: 46.6753,
                chefId: "recF8ocLPwiadavlP",
                startDate: Date(),
                endDate: Date().addingTimeInterval(7200)
            ),
            courseRecordId: "rec1DauP3kw5Q76oo"
        )
    }
}
