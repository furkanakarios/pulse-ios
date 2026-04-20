import SwiftUI
import SwiftData
import HealthKit

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var activityType = ""
    @State private var duration = ""
    @State private var calories = ""
    @State private var notes = ""
    @State private var date = Date.now
    @State private var saveToHealthKit = false
    @State private var isSaving = false

    let suggestions = [
        "Koşu", "Yürüyüş", "Bisiklet", "Yüzme",
        "Yoga", "Ağırlık Antrenmanı", "HIIT", "Pilates"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Aktivite") {
                    TextField("Egzersiz türü", text: $activityType)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Button(suggestion) {
                                    activityType = suggestion
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(activityType == suggestion ? Color.green : Color(.secondarySystemBackground))
                                .foregroundStyle(activityType == suggestion ? .white : .primary)
                                .clipShape(Capsule())
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 0))
                }

                Section("Süre & Kalori") {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.green)
                            .frame(width: 24)
                        TextField("Süre", text: $duration)
                            .keyboardType(.numberPad)
                        Text("dakika")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Image(systemName: "flame")
                            .foregroundStyle(.orange)
                            .frame(width: 24)
                        TextField("Kalori (opsiyonel)", text: $calories)
                            .keyboardType(.numberPad)
                        Text("kcal")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Saat") {
                    DatePicker("Saat", selection: $date, displayedComponents: .hourAndMinute)
                }

                Section("Not (opsiyonel)") {
                    TextField("Notlar...", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }

                if HealthKitService.shared.isAvailable {
                    Section {
                        Toggle(isOn: $saveToHealthKit) {
                            Label("Apple Health'e Kaydet", systemImage: "heart.fill")
                                .foregroundStyle(.red)
                        }
                        .tint(.red)
                    } footer: {
                        Text("Antrenman Apple Health uygulamasına da kaydedilir.")
                    }
                }
            }
            .navigationTitle("Egzersiz Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        Task { await save() }
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid || isSaving)
                }
            }
        }
    }

    private var isValid: Bool {
        !activityType.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Int(duration) ?? 0) > 0
    }

    private func save() async {
        isSaving = true
        let durationMinutes = Int(duration) ?? 0
        let cal = Double(calories) ?? 0

        let entry = ExerciseEntry(
            activityType: activityType.trimmingCharacters(in: .whitespaces),
            duration: durationMinutes,
            calories: cal,
            notes: notes.trimmingCharacters(in: .whitespaces),
            date: date
        )
        modelContext.insert(entry)

        if saveToHealthKit {
            await HealthKitService.shared.requestAuthorization()
            let endDate = Calendar.current.date(byAdding: .minute, value: durationMinutes, to: date) ?? date
            _ = await HealthKitService.shared.saveWorkout(
                activityType: hkWorkoutType(for: activityType),
                start: date,
                end: endDate,
                calories: cal
            )
        }

        isSaving = false
        dismiss()
    }

    private func hkWorkoutType(for name: String) -> HKWorkoutActivityType {
        switch name.lowercased() {
        case let t where t.contains("koş") || t.contains("run"): return .running
        case let t where t.contains("yürü") || t.contains("walk"): return .walking
        case let t where t.contains("bisiklet") || t.contains("cycl"): return .cycling
        case let t where t.contains("yüz") || t.contains("swim"): return .swimming
        case let t where t.contains("yoga"): return .yoga
        case let t where t.contains("ağırlık") || t.contains("weight"): return .traditionalStrengthTraining
        case let t where t.contains("hiit"): return .highIntensityIntervalTraining
        case let t where t.contains("pilates"): return .pilates
        default: return .other
        }
    }
}

#Preview {
    AddExerciseView()
        .modelContainer(for: [ExerciseEntry.self], inMemory: true)
}
