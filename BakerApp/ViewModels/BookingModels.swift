//
//  BookingModels.swift
//  BakerApp
//
//  Created by Assistant on 04/01/2026.
//

import Foundation

// حقول جدول الحجز في Airtable
struct BookingFields: Codable {
    // Link to Course: مصفوفة من record IDs
    let course: [String]?
    // إيميل المستخدم الذي حجز
    let user_email: String?
    // عدد المقاعد (اختياري)
    let seats: Int?
}

// لإنشاء حجز جديد (Body)
struct CreateBookingRequest: Codable {
    let fields: CreateBookingFields
    
    struct CreateBookingFields: Codable {
        let course: [String]
        let user_email: String
        let seats: Int?
    }
}

// استجابة إنشاء عنصر واحد من Airtable
typealias BookingRecord = AirtableRecord<BookingFields>
typealias BookingListResponse = AirtableListResponse<BookingFields>
