//
//  Profile.swift
//  BakerApp
//
//  Created by Haya almousa on 28/12/2025.
//

import SwiftUI
// نستورد SwiftUI لأن الواجهة مبنية بـ SwiftUI.
//hayafff
struct BookingsProfileView: View
// نعرّف View للشاشة.

{
    @State private var username: String = "Ali Boholaiqa"
    // @State لأن الاسم بيتغير من داخل نفس الشاشة (Editing).

    @State private var isEditing: Bool = false
    // حالة للتحكم: هل المستخدم الآن في وضع تعديل الاسم أم لا.

    @State private var bookedCourses: [BookedCourse] = []
    // بيانات مؤقتة للـ UI الآن (بعدها نربطها بـ API).
    
    var body: some View
    // body هو محتوى الواجهة.

    {
        NavigationStack
        // أحدث أسلوب للتنقل في SwiftUI (بديل NavigationView).

        {
            ScrollView
            // نخلي الشاشة قابلة للتمرير لأن قائمة الحجوزات قد تطول.

            {
                VStack(spacing: 16)
                // نرتّب العناصر عموديًا مع مسافة ثابتة.

                {
                    profileHeader
                    // الهيدر: صورة/أيقونة + اسم + زر Edit/Done.

                    bookedCoursesSection
                    // القسم: عنوان Booked courses + (قائمة أو Empty state).
                }
                .padding(.horizontal, 16)
                // حواف جانبية مطابقة لستايل iOS.
                
                .padding(.top, 12)
                // مسافة علوية بسيطة مثل التصميم.
            }
            .navigationTitle("Profile")
            // عنوان الشاشة في الـ Navigation bar.

            .navigationBarTitleDisplayMode(.inline)
            // عرض العنوان بشكل صغير (Inline) مثل الصور.
        }
    }
}

// MARK: - Subviews
// تقسيم الواجهة لأجزاء صغيرة: أنظف وأسهل للصيانة.

private extension BookingsProfileView
// نخلي الـ subviews داخل extension لتكون مرتبة.

{
    var profileHeader: some View
    // جزء الهيدر في أعلى الصفحة.

    {
        HStack(spacing: 12)
        // صف: أيقونة + اسم + زر.

        {
            ZStack
            // نستخدم ZStack لعمل دائرة + علامة (+) الصغيرة فوقها.

            {
                Circle()
                // دائرة للخلفية مثل صورة البروفايل.

                .fill(Color(.systemBrown).opacity(0.25))
                // لون قريب من التصميم وبأسلوب System Color.

                .frame(width: 44, height: 44)
                // حجم الأيقونة.

                Image(systemName: "person")
                // أيقونة شخص بدل صورة فعلية الآن.

                .font(.system(size: 20, weight: .semibold))
                // حجم ووزن مناسبين.
                
                .foregroundStyle(.brown)
                // نفس روح ألوان التطبيق.

                VStack
                // عمود لتثبيت علامة + بأسفل يسار الدائرة.

                {
                    Spacer()
                    // يدفع المحتوى للأسفل.

                    HStack
                    // صف لتثبيت + على اليسار.

                    {
                        Circle()
                        // دائرة صغيرة للخلفية.

                        .fill(Color(.systemBrown))
                        // لون العلامة.

                        .frame(width: 18, height: 18)
                        // حجم العلامة.

                        Image(systemName: "plus")
                        // رمز +.

                        .font(.system(size: 10, weight: .bold))
                        // حجم مناسب داخل الدائرة.

                        .foregroundStyle(.white)
                        // لون أبيض ليوضح.
                    }
                    Spacer()
                    // يخليها جهة اليسار.
                }
                .frame(width: 44, height: 44)
                // نفس إطار الصورة عشان مكانها مضبوط.
            }

            if isEditing
            // لو وضع التعديل شغال.

            {
                TextField("username", text: $username)
                // حقل لتعديل الاسم مرتبط بـ @State.

                .textInputAutocapitalization(.words)
                // يحسن تجربة إدخال الاسم.

                .disableAutocorrection(true)
                // نلغي التصحيح لأنه ممكن يخرّب الأسماء.

                .padding(.vertical, 10)
                // ارتفاع داخل الحقل.

                .padding(.horizontal, 12)
                // حواف داخلية.

                .background(Color(.systemGray6))
                // خلفية خفيفة مثل iOS.

                .clipShape(RoundedRectangle(cornerRadius: 10))
                // زوايا ناعمة.
            }
            else
            // لو عرض عادي بدون تعديل.

            {
                Text(username)
                // نعرض الاسم كنص.

                .font(.headline)
                // حجم عنوان صغير مثل التصميم.
            }

            Spacer()
            // يدفع زر Edit/Done لآخر يمين السطر.

            Button(isEditing ? "Done" : "Edit")
            // نفس الزر يتغير حسب الحالة.

            {
                isEditing.toggle()
                // تبديل وضع التعديل.
            }
            .font(.callout.weight(.semibold))
            // شكل الزر قريب من iOS.

            .foregroundStyle(.brown)
            // لون مطابق لتصميمكم.
        }
        .padding(16)
        // حواف داخل الكارد.

        .background(Color(.systemBackground))
        // خلفية كارد متوافقة مع لايت/دارك.

        .clipShape(RoundedRectangle(cornerRadius: 14))
        // كارد بحواف ناعمة.

        .overlay
        // إطار خفيف للكارد.

        {
            RoundedRectangle(cornerRadius: 14)
            // نفس شكل الكارد.

            .stroke(Color(.systemGray5), lineWidth: 1)
            // خط حدود بسيط.
        }
    }

    var bookedCoursesSection: some View
    // قسم الحجوزات.

    {
        VStack(alignment: .leading, spacing: 12)
        // عنوان ثم محتوى.

        {
            Text("Booked courses")
            // عنوان القسم.

            .font(.title3.weight(.bold))
            // نفس قوة العنوان في الصور تقريبًا.

            if bookedCourses.isEmpty
            // لو ما عند المستخدم حجوزات.

            {
                emptyState
                // نعرض Empty state (الصورة + النص).
            }
            else
            // لو فيه حجوزات.

            {
                VStack(spacing: 12)
                // قائمة كروت.

                {
                    ForEach(bookedCourses)
                    // نكرر عناصر الحجوزات.

                    { course in
                        BookedCourseCard(course: course)
                        // كارد لكل كورس.
                    }
                }
            }
        }
        .padding(.top, 4)
        // مسافة بسيطة فوق العنوان.
    }

    var emptyState: some View
    // واجهة حالة الفراغ.

    {
        VStack(spacing: 10)
        // عناصر فوق بعض.

        {
            Image("CoursesTab")
            // أيقونة بديلة—لو عندكم صورة الشوبنج/الرول نبدلها لاحقًا.

            .font(.system(size: 54))
            // حجم واضح.

            .foregroundStyle(Color(.systemGray3))
            // لون رمادي خفيف مثل التصميم.

            Text("You don't have any booked courses")
            // النص الموجود بالصورة.

            .font(.callout)
            // حجم مناسب.

            .foregroundStyle(Color(.systemGray2))
            // نفس درجة الرمادي.
        }
        .frame(maxWidth: .infinity)
        // يخليها تتمركز.
        
        .padding(.vertical, 28)
        // مساحة أعلى وأسفل مثل الصورة.
    }
}

// MARK: - Models (Temporary for UI)
// موديلات مؤقتة للـ UI. لاحقًا نبدلها بموديلات API.

struct BookedCourse: Identifiable
// نجعلها Identifiable عشان ForEach.

{
    let id: UUID = UUID()
    // معرّف محلي مؤقت للتمييز بين العناصر.

    let title: String
    // اسم الكورس.

    let level: String
    // مستوى الكورس (Beginner/Intermediate/Advanced).

    let durationText: String
    // مدة مثل "2h".

    let dateText: String
    // تاريخ مثل "19 Feb - 4:00".

    let imageName: String
    // اسم صورة محلية مؤقتة (أو لاحقًا URL).
}

// MARK: - Course Card
// كارد شكل الكورس المحجوز.

struct BookedCourseCard: View
// View منفصلة للكارد.

{
    let course: BookedCourse
    // نستقبل بيانات الكورس.

    var body: some View
    // محتوى الكارد.

    {
        HStack(spacing: 12)
        // صورة يسار + معلومات يمين.

        {
            Image(course.imageName)
            // صورة من Assets الآن (بعدها URL).

            .resizable()
            // عشان تتغير بالحجم.

            .scaledToFill()
            // تعبّي الإطار بدون فراغات.

            .frame(width: 78, height: 64)
            // حجم قريب من التصميم.

            .clipShape(RoundedRectangle(cornerRadius: 10))
            // زوايا ناعمة للصورة.

            VStack(alignment: .leading, spacing: 6)
            // تفاصيل الكورس.

            {
                Text(course.title)
                // عنوان الكورس.

                .font(.headline)
                // بارز.

                Text(course.level)
                // مستوى الكورس.

                .font(.caption.weight(.semibold))
                // أصغر ومميز.

                .padding(.vertical, 4)
                // حواف داخلية.

                .padding(.horizontal, 8)
                // حواف داخلية.

                .background(Color(.systemBrown).opacity(0.18))
                // خلفية خفيفة للـ badge.

                .foregroundStyle(.brown)
                // لون نص الـ badge.

                .clipShape(Capsule())
                // شكل كبسولة مثل التصميم.

                HStack(spacing: 10)
                // سطر المدة والتاريخ.

                {
                    Label(course.durationText, systemImage: "hourglass")
                    // مدة مع أيقونة.

                    Label(course.dateText, systemImage: "calendar")
                    // تاريخ مع أيقونة.
                }
                .font(.caption)
                // حجم صغير مثل التصميم.

                .foregroundStyle(Color(.secondaryLabel))
                // لون ثانوي مناسب.
            }

            Spacer()
            // يدفع المحتوى للبداية.
        }
        .padding(12)
        // حواف داخل الكارد.

        .background(Color(.systemBackground))
        // خلفية كارد.

        .clipShape(RoundedRectangle(cornerRadius: 14))
        // زوايا ناعمة.

        .overlay
        // إطار خفيف.

        {
            RoundedRectangle(cornerRadius: 14)
            // نفس شكل الكارد.

            .stroke(Color(.systemGray5), lineWidth: 1)
            // حدود خفيفة.
        }
    }
}

// MARK: - Preview
// معاينة للواجهة داخل Xcode.

#Preview
// ميزة Preview الحديثة.

{
    BookingsProfileView()
    // عرض الشاشة.
}

#Preview {
    BookingsProfileView()
}
