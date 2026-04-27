import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "checkmark.circle"
    @State private var selectedColor = "#007AFF"

    let iconOptions: [(label: String, icon: String)] = [
        ("Genel", "checkmark.circle"),
        ("Su", "drop.fill"),
        ("Uyku", "moon.fill"),
        ("Kitap", "book.fill"),
        ("Meditasyon", "brain.head.profile"),
        ("Egzersiz", "figure.run"),
        ("Beslenme", "fork.knife"),
        ("Vitamin", "pill.fill"),
        ("Günlük", "pencil"),
        ("Müzik", "music.note"),
        ("Yürüyüş", "figure.walk"),
        ("Nefes", "wind")
    ]

    let colorOptions: [String] = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#FF2D55", "#5AC8FA", "#FFCC00"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Alışkanlık Adı") {
                    TextField("Örn: Günde 8 bardak su iç", text: $name)
                }

                Section("İkon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(iconOptions, id: \.icon) { option in
                            Button {
                                selectedIcon = option.icon
                            } label: {
                                Image(systemName: option.icon)
                                    .font(.title3)
                                    .foregroundStyle(selectedIcon == option.icon ? .white : Color(hex: selectedColor))
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == option.icon ? Color(hex: selectedColor) : Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Renk") {
                    HStack(spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: color))
                                        .frame(width: 32, height: 32)
                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    HStack {
                        Image(systemName: selectedIcon)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                            .background(Color(hex: selectedColor))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(name.isEmpty ? "Alışkanlık Adı" : name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(name.isEmpty ? .secondary : .primary)
                            Text("0 günlük seri")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Önizleme")
                }
            }
            .navigationTitle("Yeni Alışkanlık")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                        .fontWeight(.semibold)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let habit = Habit(
            name: name.trimmingCharacters(in: .whitespaces),
            icon: selectedIcon,
            colorHex: selectedColor
        )
        modelContext.insert(habit)
        AchievementService.shared.evaluate(context: modelContext)
        dismiss()
    }
}

#Preview {
    AddHabitView()
        .modelContainer(for: [Habit.self], inMemory: true)
}
