//
//  Profile.swift
//  BakerApp
//
//  Created by Haya almousa on 28/12/2025.
//

import SwiftUI
// استيراد SwiftUI لبناء الواجهة

struct BookingsProfileView: View {
    // شاشة تعرض بروفايل المستخدم مع قائمة حجوزاته

    @State private var username: String = "Ali Boholaiqa"
    // اسم المستخدم القابل للتعديل محليًا

    @State private var isEditing: Bool = false
    // حالة تحدد إن كان المستخدم يعدّل الاسم الآن

    @State private var bookedCourses: [BookedCourse] = []
    // قائمة الحجوزات (بيانات مؤقتة للعرض)

    var body: some View {
        // جسم الواجهة

        NavigationStack {
            // حاوية تنقل حديثة

            ScrollView {
                // محتوى قابل للتمرير

                VStack(spacing: 16) {
                    // ترتيب عمودي للعناصر مع مسافات

                    profileHeader
                    // قسم الهيدر: صورة/أيقونة + اسم + زر تعديل

                    bookedCoursesSection
                    // قسم الحجوزات: عنوان + قائمة أو حالة فارغة
                }
                .padding(.horizontal, 16)
                // حواف جانبية موحّدة

                .padding(.top, 12)
                // مسافة علوية بسيطة
            }
            .navigationTitle("Profile")
            // عنوان شريط التنقل

            .navigationBarTitleDisplayMode(.inline)
            // عرض العنوان بشكل مضغوط
        }
    }
    // نهاية body
}
// نهاية BookingsProfileView

private extension BookingsProfileView {
    // امتداد لكتابة الأجزاء الفرعية بشكل منظم

    var profileHeader: some View {
        // واجهة هيدر البروفايل

        HStack(spacing: 12) {
            // صف: أيقونة + اسم + زر

            ZStack {
                // تكديس عناصر صورة البروفايل

                Circle()
                    .fill(Color(.systemBrown).withAlphaComponent(0.25))
                    .frame(width: 44, height: 44)
                // دائرة خلفية بلون بني شفاف

                Image(systemName: "person")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.brown)
                // أيقونة شخص في الوسط

                VStack {
                    // لتثبيت علامة الإضافة بالأسفل

                    Spacer()
                    // دفع المحتوى للأسفل

                    HStack {
                        // صف لعلامة الإضافة

                        Circle()
                            .fill(Color(.systemBrown))
                            .frame(width: 18, height: 18)
                        // دائرة صغيرة للخلفية

                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                        // علامة + باللون الأبيض
                    }
                    Spacer()
                    // لإبقاء العلامة يسار-أسفل
                }
                .frame(width: 44, height: 44)
                // نفس حجم الدائرة الأساسية لضبط التموضع
            }

            if isEditing {
                // عند تفعيل وضع التعديل

                TextField("username", text: $username)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                // حقل نص لتعديل الاسم مع تنسيقات مناسبة
            } else {
                // عرض الاسم فقط بدون تعديل

                Text(username)
                    .font(.headline)
                // عرض الاسم بخط بارز
            }

            Spacer()
            // دفع زر التعديل لليمين

            Button(isEditing ? "Done" : "Edit") {
                // زر تبديل وضع التعديل

                isEditing.toggle()
                // قلب حالة التعديل
            }
            .font(.callout.weight(.semibold))
            // تنسيق نص الزر

            .foregroundStyle(.brown)
            // لون الزر
        }
        .padding(16)
        // حواف داخلية للكارد

        .background(Color(.systemBackground))
        // خلفية متوافقة مع الثيم

        .clipShape(RoundedRectangle(cornerRadius: 14))
        // زوايا ناعمة للكارد

        .overlay {
            // إطار خفيف حول الكارد

            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color(.systemGray5), lineWidth: 1)
            // خط حدود خفيف
        }
    }
    // نهاية profileHeader

    var bookedCoursesSection: some View {
        // قسم يعرض عنوان الحجوزات ومحتواها

        VStack(alignment: .leading, spacing: 12) {
            // ترتيب عمودي بمحاذاة لليسار

            Text("Booked courses")
                .font(.title3.weight(.bold))
            // عنوان القسم

            if bookedCourses.isEmpty {
                // حالة لا توجد حجوزات

                emptyState
                // عرض حالة فارغة
            } else {
                // توجد حجوزات

                VStack(spacing: 12) {
                    // قائمة كروت الحجوزات

                    ForEach(bookedCourses) { course in
                        // تكرار لكل حجز

                        BookedCourseCard(course: course)
                        // كارد يعرض تفاصيل الحجز
                    }
                }
            }
        }
        .padding(.top, 4)
        // مسافة بسيطة فوق القسم
    }
    // نهاية bookedCoursesSection

    var emptyState: some View {
        // واجهة حالة عدم وجود حجوزات

        VStack(spacing: 10) {
            // ترتيب عمودي بعناصر متباعدة

            Image("CoursesTab")
                .font(.system(size: 54))
                .foregroundStyle(Color(.systemGray3))
            // أيقونة توضيحية

            Text("You don't have any booked courses")
                .font(.callout)
                .foregroundStyle(Color(.systemGray2))
            // نص يشرح الحالة
        }
        .frame(maxWidth: .infinity)
        // تمديد أفقي للتمركز

        .padding(.vertical, 28)
        // مسافة عمودية مناسبة
    }
    // نهاية emptyState
}
// نهاية الامتداد

struct BookedCourse: Identifiable {
    // نموذج مؤقت يمثل الحجز لعرضه في الواجهة

    let id: UUID = UUID()
    // معرّف فريد لكل عنصر

    let title: String
    // عنوان الكورس

    let level: String
    // مستوى الكورس

    let durationText: String
    // مدة الكورس بشكل نص

    let dateText: String
    // تاريخ/وقت الكورس بشكل نص

    let imageName: String
    // اسم الصورة في الأصول
}
// نهاية BookedCourse

struct BookedCourseCard: View {
    // كارد يعرض تفاصيل حجز واحد

    let course: BookedCourse
    // بيانات الحجز المعروضة

    var body: some View {
        // جسم الكارد

        HStack(spacing: 12) {
            // صورة يسار + تفاصيل يمين

            Image(course.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 78, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            // صورة مصغرة للكورس

            VStack(alignment: .leading, spacing: 6) {
                // تفاصيل نصية للكورس

                Text(course.title)
                    .font(.headline)
                // عنوان الكورس

                Text(course.level)
                    .font(.caption.weight(.semibold))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color(.systemBrown).withAlphaComponent(0.18))
                    .foregroundStyle(.brown)
                    .clipShape(Capsule())
                // شارة المستوى

                HStack(spacing: 10) {
                    // صف للمدة والتاريخ

                    Label(course.durationText, systemImage: "hourglass")
                    // مدة الكورس مع أيقونة

                    Label(course.dateText, systemImage: "calendar")
                    // تاريخ الكورس مع أيقونة
                }
                .font(.caption)
                // حجم خط صغير

                .foregroundStyle(Color(.secondaryLabel))
                // لون ثانوي للنصوص
            }

            Spacer()
            // دفع المحتوى لليسار
        }
        .padding(12)
        // حواف داخلية للكارد

        .background(Color(.systemBackground))
        // خلفية متوافقة مع الثيم

        .clipShape(RoundedRectangle(cornerRadius: 14))
        // زوايا ناعمة للكارد

        .overlay {
            // إطار خفيف للكارد

            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color(.systemGray5), lineWidth: 1)
            // حدود خفيفة
        }
    }
    // نهاية body
}
// نهاية BookedCourseCard

#Preview {
    // معاينة سريعة للشاشة داخل Xcode

    BookingsProfileView()
    // عرض شاشة البروفايل
}

