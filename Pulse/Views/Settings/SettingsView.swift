import SwiftUI

struct SettingsView: View {
    // Goals
    @AppStorage("dailyWaterGoal") private var dailyWaterGoal: Double = 2500
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal: Double = 2000
    @AppStorage("dailyExerciseGoal") private var dailyExerciseGoal: Double = 30

    // Profile (for BMR)
    @AppStorage("profileGender") private var profileGender: String = "male"
    @AppStorage("profileHeight") private var profileHeight: Double = 0
    @AppStorage("profileWeight") private var profileWeight: Double = 0
    @AppStorage("profileAge") private var profileAge: Int = 0
    @AppStorage("profileActivityLevel") private var profileActivityLevel: String = "moderate"

    // Notifications
    @AppStorage("waterReminderEnabled") private var waterReminderEnabled: Bool = false
    @AppStorage("waterReminderInterval") private var waterReminderInterval: Int = 60
    @AppStorage("habitReminderEnabled") private var habitReminderEnabled: Bool = false
    @AppStorage("morningSummaryEnabled") private var morningSummaryEnabled: Bool = false
    @AppStorage("morningSummaryHour") private var morningSummaryHour: Int = 8
    @AppStorage("morningSummaryMinute") private var morningSummaryMinute: Int = 0

    // Local state
    @State private var waterGoalInput: String = ""
    @State private var calorieGoalInput: String = ""
    @State private var exerciseGoalInput: String = ""
    @State private var heightInput: String = ""
    @State private var weightInput: String = ""
    @State private var ageInput: String = ""
    @State private var morningSummaryTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now
    @State private var showNotificationDeniedAlert = false
    @State private var showMorningSummaryDeniedAlert = false
    @State private var showBMRInfo = false

    @FocusState private var focusedField: Field?

    enum Field { case water, calorie, exercise, height, weight, age }

    let waterIntervalOptions: [(label: String, minutes: Int)] = [
        ("30 dakikada bir", 30),
        ("1 saatte bir", 60),
        ("2 saatte bir", 120)
    ]

    let activityOptions: [(label: String, sublabel: String, key: String, multiplier: Double)] = [
        ("Hareketsiz", "Masa başı, az hareket", "sedentary", 1.2),
        ("Az Hareketli", "Haftada 1-3 gün egzersiz", "light", 1.375),
        ("Orta Hareketli", "Haftada 3-5 gün egzersiz", "moderate", 1.55),
        ("Çok Hareketli", "Haftada 6-7 gün egzersiz", "active", 1.725),
        ("Ekstra Aktif", "Ağır antrenman veya fiziksel iş", "veryActive", 1.9)
    ]

    var body: some View {
        NavigationStack {
            Form {
                profileSection
                dailyGoalsSection
                notificationsSection
                appInfoSection
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Bitti") { focusedField = nil }
                        .fontWeight(.semibold)
                }
            }
            .onAppear { loadInputs() }
            .alert("BMR Hesaplama", isPresented: $showBMRInfo) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text("Mifflin-St Jeor formülü kullanılarak bazal metabolizma hızınız (BMR) ve aktivite seviyenize göre günlük toplam enerji harcamanız (TDEE) hesaplanmıştır.")
            }
            .alert("Bildirim İzni Gerekli", isPresented: $showMorningSummaryDeniedAlert) {
                Button("Ayarlara Git") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("İptal", role: .cancel) { morningSummaryEnabled = false }
            } message: {
                Text("Bildirimlere izin vermek için Ayarlar > Pulse > Bildirimler bölümüne gidin.")
            }
            .alert("Bildirim İzni Gerekli", isPresented: $showNotificationDeniedAlert) {
                Button("Ayarlara Git") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("İptal", role: .cancel) { waterReminderEnabled = false }
            } message: {
                Text("Bildirimlere izin vermek için Ayarlar > Pulse > Bildirimler bölümüne gidin.")
            }
        }
    }

    // MARK: - Profile Section
    private var profileSection: some View {
        Section {
            Picker("Cinsiyet", selection: $profileGender) {
                Text("Erkek").tag("male")
                Text("Kadın").tag("female")
            }
            .onChange(of: profileGender) { autoUpdateCalorie() }

            HStack {
                Label("Boy", systemImage: "ruler")
                Spacer()
                TextField("170", text: $heightInput)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)
                    .focused($focusedField, equals: .height)
                    .onChange(of: heightInput) {
                        if let val = Double(heightInput), val > 0 {
                            profileHeight = val
                            autoUpdateCalorie()
                        }
                    }
                Text("cm").foregroundStyle(.secondary)
            }

            HStack {
                Label("Kilo", systemImage: "scalemass")
                Spacer()
                TextField("70", text: $weightInput)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)
                    .focused($focusedField, equals: .weight)
                    .onChange(of: weightInput) {
                        if let val = Double(weightInput), val > 0 {
                            profileWeight = val
                            autoUpdateCalorie()
                        }
                    }
                Text("kg").foregroundStyle(.secondary)
            }

            HStack {
                Label("Yaş", systemImage: "person")
                Spacer()
                TextField("25", text: $ageInput)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)
                    .focused($focusedField, equals: .age)
                    .onChange(of: ageInput) {
                        if let val = Int(ageInput), val > 0 {
                            profileAge = val
                            autoUpdateCalorie()
                        }
                    }
                Text("yaş").foregroundStyle(.secondary)
            }

            Picker("Aktivite Seviyesi", selection: $profileActivityLevel) {
                ForEach(activityOptions, id: \.key) { option in
                    Text(option.label).tag(option.key)
                }
            }
            .onChange(of: profileActivityLevel) { autoUpdateCalorie() }

            if let tdee = calculatedTDEE {
                HStack {
                    Label("Hesaplanan Hedef", systemImage: "sparkles")
                        .foregroundStyle(.orange)
                    Spacer()
                    Text("\(Int(tdee)) kcal")
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                    Button {
                        showBMRInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
            }

        } header: {
            Text("Profil")
        } footer: {
            Text("Boy, kilo ve yaşınıza göre günlük kalori hedefiniz otomatik hesaplanır.")
        }
    }

    // MARK: - Daily Goals
    private var dailyGoalsSection: some View {
        Section {
            HStack {
                Label("Su Hedefi", systemImage: "drop.fill")
                    .foregroundStyle(.blue)
                Spacer()
                TextField("2500", text: $waterGoalInput)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)
                    .focused($focusedField, equals: .water)
                    .onChange(of: waterGoalInput) {
                        if let val = Double(waterGoalInput), val > 0 {
                            dailyWaterGoal = val
                        }
                    }
                Text("ml").foregroundStyle(.secondary)
            }

            HStack {
                Label("Kalori Hedefi", systemImage: "fork.knife")
                    .foregroundStyle(.orange)
                Spacer()
                TextField("2000", text: $calorieGoalInput)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)
                    .focused($focusedField, equals: .calorie)
                    .onChange(of: calorieGoalInput) {
                        if let val = Double(calorieGoalInput), val > 0 {
                            dailyCalorieGoal = val
                        }
                    }
                Text("kcal").foregroundStyle(.secondary)
            }

            HStack {
                Label("Egzersiz Hedefi", systemImage: "figure.run")
                    .foregroundStyle(.green)
                Spacer()
                TextField("30", text: $exerciseGoalInput)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)
                    .focused($focusedField, equals: .exercise)
                    .onChange(of: exerciseGoalInput) {
                        if let val = Double(exerciseGoalInput), val > 0 {
                            dailyExerciseGoal = val
                        }
                    }
                Text("dk").foregroundStyle(.secondary)
            }
        } header: {
            Text("Günlük Hedefler")
        } footer: {
            Text("Kalori hedefini Profil bilgilerinizden otomatik doldurabilir veya kendiniz girebilirsiniz.")
        }
    }

    // MARK: - Notifications
    private var notificationsSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { waterReminderEnabled },
                set: { toggleWaterReminder($0) }
            )) {
                Label("Su Hatırlatıcısı", systemImage: "drop.fill")
                    .foregroundStyle(.blue)
            }
            .tint(.blue)

            if waterReminderEnabled {
                Picker("Hatırlatma Sıklığı", selection: $waterReminderInterval) {
                    ForEach(waterIntervalOptions, id: \.minutes) { option in
                        Text(option.label).tag(option.minutes)
                    }
                }
                .onChange(of: waterReminderInterval) {
                    NotificationService.shared.scheduleWaterReminder(intervalMinutes: waterReminderInterval)
                }
            }

            Toggle(isOn: $habitReminderEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Label("Alışkanlık Hatırlatıcısı", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.purple)
                    Text("Her alışkanlık için Alışkanlıklar ekranından saat ayarlayın.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .tint(.purple)

            Toggle(isOn: Binding(
                get: { morningSummaryEnabled },
                set: { toggleMorningSummary($0) }
            )) {
                Label("Sabah Özeti", systemImage: "sun.max.fill")
                    .foregroundStyle(.orange)
            }
            .tint(.orange)

            if morningSummaryEnabled {
                DatePicker("Saat", selection: $morningSummaryTime, displayedComponents: .hourAndMinute)
                    .onChange(of: morningSummaryTime) { scheduleMorningSummary() }
            }

        } header: {
            Text("Bildirimler")
        } footer: {
            Text("Sabah özeti her sabah günlük hedeflerini hatırlatır.")
        }
    }

    // MARK: - App Info
    private var appInfoSection: some View {
        Section("Uygulama") {
            HStack {
                Label("Versiyon", systemImage: "info.circle")
                Spacer()
                Text("1.0.0").foregroundStyle(.secondary)
            }
            HStack {
                Label("Geliştirici", systemImage: "person.circle")
                Spacer()
                Text("Furkan Akar").foregroundStyle(.secondary)
            }
            HStack {
                Label("Veri Depolama", systemImage: "internaldrive")
                Spacer()
                Text("Yerel (SwiftData)").foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - BMR / TDEE
    private var calculatedTDEE: Double? {
        guard profileHeight > 0, profileWeight > 0, profileAge > 0 else { return nil }
        // Mifflin-St Jeor
        let bmr: Double
        if profileGender == "male" {
            bmr = 10 * profileWeight + 6.25 * profileHeight - 5 * Double(profileAge) + 5
        } else {
            bmr = 10 * profileWeight + 6.25 * profileHeight - 5 * Double(profileAge) - 161
        }
        let multiplier = activityOptions.first { $0.key == profileActivityLevel }?.multiplier ?? 1.55
        return bmr * multiplier
    }

    private func autoUpdateCalorie() {
        guard let tdee = calculatedTDEE else { return }
        dailyCalorieGoal = tdee.rounded()
        calorieGoalInput = String(Int(tdee.rounded()))
    }

    // MARK: - Helpers
    private func toggleWaterReminder(_ enabled: Bool) {
        if enabled {
            Task {
                let status = await NotificationService.shared.authorizationStatus()
                switch status {
                case .authorized, .provisional:
                    waterReminderEnabled = true
                    NotificationService.shared.scheduleWaterReminder(intervalMinutes: waterReminderInterval)
                case .notDetermined:
                    let granted = await NotificationService.shared.requestAuthorization()
                    if granted {
                        waterReminderEnabled = true
                        NotificationService.shared.scheduleWaterReminder(intervalMinutes: waterReminderInterval)
                    } else {
                        waterReminderEnabled = false
                    }
                case .denied:
                    showNotificationDeniedAlert = true
                default:
                    waterReminderEnabled = false
                }
            }
        } else {
            waterReminderEnabled = false
            NotificationService.shared.cancelWaterReminder()
        }
    }

    private func loadInputs() {
        waterGoalInput = String(Int(dailyWaterGoal))
        calorieGoalInput = String(Int(dailyCalorieGoal))
        exerciseGoalInput = String(Int(dailyExerciseGoal))
        heightInput = profileHeight > 0 ? String(Int(profileHeight)) : ""
        weightInput = profileWeight > 0 ? String(Int(profileWeight)) : ""
        ageInput = profileAge > 0 ? String(profileAge) : ""
        morningSummaryTime = Calendar.current.date(
            bySettingHour: morningSummaryHour,
            minute: morningSummaryMinute,
            second: 0,
            of: .now
        ) ?? .now
    }

    private func toggleMorningSummary(_ enabled: Bool) {
        if enabled {
            Task {
                let status = await NotificationService.shared.authorizationStatus()
                switch status {
                case .authorized, .provisional:
                    morningSummaryEnabled = true
                    scheduleMorningSummary()
                case .notDetermined:
                    let granted = await NotificationService.shared.requestAuthorization()
                    if granted {
                        morningSummaryEnabled = true
                        scheduleMorningSummary()
                    } else {
                        morningSummaryEnabled = false
                    }
                case .denied:
                    showMorningSummaryDeniedAlert = true
                default:
                    morningSummaryEnabled = false
                }
            }
        } else {
            morningSummaryEnabled = false
            NotificationService.shared.cancelMorningSummary()
        }
    }

    private func scheduleMorningSummary() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: morningSummaryTime)
        let hour = components.hour ?? 8
        let minute = components.minute ?? 0
        morningSummaryHour = hour
        morningSummaryMinute = minute
        NotificationService.shared.scheduleMorningSummary(hour: hour, minute: minute)
    }
}

#Preview {
    SettingsView()
}
