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
    let title: String?
    let level: String?
    let duration: String?
    let date: String?
    let image_url: String?
}
