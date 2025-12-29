//
//  UserModels.swift
//  BakerApp
//
//  Created by Haya almousa on 29/12/2025.
//

import Foundation
// نستخدم Foundation لأننا بنفك JSON باستخدام Decodable

// يمثل الرد العام من Airtable: { "records": [ ... ] }
struct AirtableListResponse<T: Decodable>: Decodable {
    let records: [AirtableRecord<T>]
    // records: مصفوفة السجلات اللي ترجع من Airtable
}

// يمثل سجل واحد داخل records
struct AirtableRecord<T: Decodable>: Decodable, Identifiable {
    let id: String
    // id: المعرّف الفريد للسجل (مثل recK8Q...)

    let createdTime: String
    // createdTime: وقت إنشاء السجل كنص (كما يرجع من Airtable)

    let fields: T
    // fields: البيانات الفعلية للأعمدة (هنا: UserFields)
}

// يمثل أعمدة جدول user داخل Airtable
struct UserFields: Decodable {
    let name: String?
    // name: اسم المستخدم (اختياري لأنه ممكن يكون فاضي)

    let email: String?
    // email: الإيميل (اختياري)

    let password: String?
    // password: كلمة المرور (للتحدي فقط)
}
/* AirtableListResponse: لأن Airtable يرجّع البيانات داخل records.
 AirtableRecord: لأن كل عنصر فيه id + createdTime + fields.
 UserFields: لأن هذا هو جدول user اللي طلبوه منك للبروفايل.*/
