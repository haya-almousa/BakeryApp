//
//  BookingViewModel.swift
//  BakerApp
//
//  Created by Assistant on 04/01/2026.
//

import Foundation
import Combine

@MainActor
final class BookingViewModel: ObservableObject {
    @Published var bookings: [BookingRecord] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isPerformingAction: Bool = false
    @Published var lastCreatedBooking: BookingRecord?
    
    private let api = BookingAPI.shared
    let courseRecordId: String
    
    init(courseRecordId: String) {
        self.courseRecordId = courseRecordId
    }
    
    func load() {
        Task {
            await fetch()
        }
    }
    
    func fetch() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await api.fetchBookings(forCourseRecordId: courseRecordId)
            bookings = result
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to load bookings."
        }
    }
    
    func book(userEmail: String, seats: Int? = 1) {
        isPerformingAction = true
        errorMessage = nil
        Task {
            do {
                let created = try await api.createBooking(courseRecordId: courseRecordId, userEmail: userEmail, seats: seats)
                lastCreatedBooking = created
                // حدّث القائمة
                await fetch()
                isPerformingAction = false
                // أبلغ الشاشات الأخرى (مثل البروفايل) للتحديث
                NotificationCenter.default.post(name: Notification.Name("BookingDidChange"), object: nil)
            } catch {
                isPerformingAction = false
                errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to create booking."
            }
        }
    }
    
    func cancel(bookingRecordId: String) {
        isPerformingAction = true
        errorMessage = nil
        Task {
            do {
                try await api.deleteBooking(bookingRecordId: bookingRecordId)
                // حدّث القائمة
                await fetch()
                isPerformingAction = false
                // أبلغ الشاشات الأخرى (مثل البروفايل) للتحديث
                NotificationCenter.default.post(name: Notification.Name("BookingDidChange"), object: nil)
            } catch {
                isPerformingAction = false
                errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to cancel booking."
            }
        }
    }
    
    // مساعد لإيجاد حجز المستخدم الحالي (نقارنه بالإيميل لأن user_id = email)
    func bookingOfUser(id: String) -> BookingRecord? {
        bookings.first { $0.fields.user_id?.lowercased() == id.lowercased() }
    }
}

