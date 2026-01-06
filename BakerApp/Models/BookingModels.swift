//
//  BookingModels.swift
//  BakerApp
//
//  Created by Assistant on 04/01/2026.
//

import Foundation

// 1. Structure for READING data (GET)
struct BookingFields: Codable {
    // We match the JSON types from your screenshot (String, not Array)
    let course_id: String?
    let user_id: String?
    let status: String?
    
    // CodingKeys map the JSON keys to our variables.
    // Since our variable names now match the JSON keys exactly,
    // we technically don't need this enum, but we keep it for safety.
    enum CodingKeys: String, CodingKey {
        case course_id = "courseid"
        case user_id = "user_id"
        case status = "status"
    }
}

// 2. Structure for SENDING data (POST)
struct CreateBookingRequest: Codable {
    let fields: CreateBookingFields
    
    struct CreateBookingFields: Codable {
        let courseid: String
        let user_id: String
        let status: String
        
        // No "seats" because your screenshot doesn't show a seats column.
    }
}

// Helpers
typealias BookingRecord = AirtableRecord<BookingFields>
typealias BookingListResponse = AirtableListResponse<BookingFields>
