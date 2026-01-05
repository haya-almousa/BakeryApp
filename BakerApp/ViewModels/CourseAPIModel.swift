//
//  CourseAPIModel.swift
//  BakerApp
//
//  Created by Tala Aldhahri on 15/07/1447 AH.
//
import Foundation

struct AirtableResponse: Codable {
    let records: [CourseRecord]
}

struct CourseRecord: Codable {
    let id: String
    let fields: CourseFields
}

struct CourseFields: Codable {
    // أساسية
    let title: String?
    let level: String?
    let duration: String?
    let date: String?
    let image_url: String?
    
    // الحقول الجديدة من الـ API
    let description: String?
    let location_name: String?
    let location_latitude: Double?
    let location_longitude: Double?
    let chef_id: String?
    let start_date: Double?   // Unix seconds
    let end_date: Double?     // Unix seconds
}
