//
//  UserModels.swift
//  BakerApp
//
//  Created by Haya almousa on 29/12/2025.
//تعريف المتغيرات

import Foundation
// نستورد Foundation عشان Codable و URL وأشياء الشبكات

struct AirtableListResponse<T: Codable>: Codable {
    // هذا Model يمثل استجابة Airtable الأساسية: { "records": [...] }

    let records: [AirtableRecord<T>]
    // مصفوفة فيها كل السجلات الراجعة من Airtable
}

struct AirtableRecord<T: Codable>: Codable, Identifiable {
    // يمثل عنصر واحد داخل records

    let id: String
    // id حق Airtable لكل record

    let createdTime: String
    // وقت الإنشاء (يرجع كـ String من Airtable)

    let fields: T
    // البيانات الفعلية داخل "fields" (نحدد نوعها حسب الجدول)
}

struct UserFields: Codable {
    // هذا يمثل شكل الحقول داخل جدول user في Airtable

    let name: String?
    // اسم المستخدم (اختياري لأن ممكن يكون فاضي)

    let email: String?
    // الإيميل (اختياري)

    let password: String?
    // الباسورد (اختياري)
}
