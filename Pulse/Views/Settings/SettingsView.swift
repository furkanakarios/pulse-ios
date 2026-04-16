import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyWaterGoal") private var dailyWaterGoal: Double = 2500
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal: Double = 2000
    @AppStorage("dailyExerciseGoal") private var dailyExerciseGoal: Double = 30
    @AppStorage("waterReminderEnabled") private var waterReminderEnabled: Bool = false
    @AppStorage("waterReminderInterval") private var waterReminderInterval: Int = 60
    @AppStorage("habitReminderEnabled") private var habitReminderEnabled: Bool = false
    @AppStorage("morningSummaryEnabled") private var morningSummaryEnabled: Bool = false
    @AppStorage("morningSummaryHour") private var morningSummaryHour: Int = 8
    @AppStorage("morningSummaryMinute") private var morningSummaryMinute: Int = 0

    @State private var waterGoalInput: String = ""
    @State private var calorieGoalInput: String = ""
    @State private var exerciseGoalInput: String = ""
    @State private var morningSummaryTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now
    @State private var showNotificationDeniedAlert = false
    @State private var showMorningSummaryDeniedAlert = false

    let waterIntervalOptions: [(label: String, minutes: Int)] = [
        ("30 dakikada bir", 30),
        ("1 saatte bir", 60),
        ("2 saatte bir", 120)
    ]

    var body: some View {
        NavigationStack {
            Form {
                dailyGoalsSection
                notificationsSection
                appInfoSection
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { loadInputs() }
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
                Button("İptal", role: .cancel) {
                    waterReminderEnabled = false
                }
            } message: {
                Text("Bildirimlere izin vermek için Ayarlar > Pulse > Bildirimler bölümüne gidin.")
            }
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
            Text("Hedefler Dashboard ve ilgili ekranlarda kullanılır.")
        }
    }

    // MARK: - Notifications
    private var notificationsSection: some View {
        Section {
            // Su Hatırlatıcısı
            Toggle(isOn: Binding(
                get: { waterReminderEnabled },
                set: { newValue in toggleWaterReminder(newValue) }
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

            // Alışkanlık Hatırlatıcısı
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

            // Sabah Özeti
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
