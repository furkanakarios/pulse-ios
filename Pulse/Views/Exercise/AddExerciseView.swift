import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var activityType = ""
    @State private var duration = ""
    @State private var calories = ""
    @State private var notes = ""
    @State private var date = Date.now

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
            }
            .navigationTitle("Egzersiz Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        !activityType.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Int(duration) ?? 0) > 0
    }

    private func save() {
        let entry = ExerciseEntry(
            activityType: activityType.trimmingCharacters(in: .whitespaces),
            duration: Int(duration) ?? 0,
            calories: Double(calories) ?? 0,
            notes: notes.trimmingCharacters(in: .whitespaces),
            date: date
        )
        modelContext.insert(entry)
        dismiss()
    }
}

#Preview {
    AddExerciseView()
        .modelContainer(for: [ExerciseEntry.self], inMemory: true)
}
