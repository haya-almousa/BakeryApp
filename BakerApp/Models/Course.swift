//
//  Course.swift
//  BakerApp
//
//  Created by Haya almousa on 25/12/2025.
//

import Foundation
import SwiftUI

//we made it string and codable so that it van be translated easily the text from json into swift objects
enum CourseLevel: String, Codable{
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var themeColor: Color {
        switch self {
        case .beginner:
            return Color("LevelBeginner")
        case .intermediate:
            return Color("LevelIntermediate")
        case .advanced:
            return Color("LevelAdvanced")
        }
    }
}

struct Course: Identifiable, Codable {
    let id: UUID
    let title: String
    let level: CourseLevel
    let duration: String
    let date: String
    let imageURL: String
}
