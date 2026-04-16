import SwiftUI

struct SettingsView: View {
    @AppStorage("dailyWaterGoal") private var dailyWaterGoal: Double = 2500
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal: Double = 2000
    @AppStorage("dailyExerciseGoal") private var dailyExerciseGoal: Double = 30
    @AppStorage("waterReminderEnabled") private var waterReminderEnabled: Bool = false
    @AppStorage("habitReminderEnabled") private var habitReminderEnabled: Bool = false
    @AppStorage("morningSummaryEnabled") private var morningSummaryEnabled: Bool = false

    @State private var waterGoalInput: String = ""
    @State private var calorieGoalInput: String = ""
    @State private var exerciseGoalInput: String = ""

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
                Text("ml")
                    .foregroundStyle(.secondary)
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
                Text("kcal")
                    .foregroundStyle(.secondary)
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
                Text("dk")
                    .foregroundStyle(.secondary)
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
            Toggle(isOn: $waterReminderEnabled) {
                Label("Su Hatırlatıcısı", systemImage: "drop.fill")
                    .foregroundStyle(.blue)
            }
            .tint(.blue)

            Toggle(isOn: $habitReminderEnabled) {
                Label("Alışkanlık Hatırlatıcısı", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.purple)
            }
            .tint(.purple)

            Toggle(isOn: $morningSummaryEnabled) {
                Label("Sabah Özeti", systemImage: "sun.max.fill")
                    .foregroundStyle(.yellow)
            }
            .tint(.yellow)
        } header: {
            Text("Bildirimler")
        } footer: {
            Text("Bildirim detayları Phase 2'de aktive edilecek.")
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - App Info
    private var appInfoSection: some View {
        Section("Uygulama") {
            HStack {
                Label("Versiyon", systemImage: "info.circle")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("Geliştirici", systemImage: "person.circle")
                Spacer()
                Text("Furkan Akar")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("Veri Depolama", systemImage: "internaldrive")
                Spacer()
                Text("Yerel (SwiftData)")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func loadInputs() {
        waterGoalInput = String(Int(dailyWaterGoal))
        calorieGoalInput = String(Int(dailyCalorieGoal))
        exerciseGoalInput = String(Int(dailyExerciseGoal))
    }
}

#Preview {
    SettingsView()
}
