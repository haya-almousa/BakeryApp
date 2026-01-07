//
//  UserModels.swift
//  BakerApp
//
//  Created by Haya almousa on 29/12/2025.

import Foundation

struct AirtableListResponse<T: Codable>: Codable {
    let records: [AirtableRecord<T>]
}

struct AirtableRecord<T: Codable>: Codable, Identifiable {
    let id: String
    let createdTime: String
    let fields: T
}

struct UserFields: Codable {
    let name: String?
    let email: String?
    let password: String?
}
