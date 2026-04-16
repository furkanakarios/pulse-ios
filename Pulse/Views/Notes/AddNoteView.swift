import SwiftUI
import SwiftData

struct AddNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var content = ""
    @State private var source = "Kişisel"

    let sourceOptions = ["Kişisel", "Doktor", "Diyetisyen", "Psikolog"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Başlık") {
                    TextField("Örn: Kan tahlili sonuçları", text: $title)
                }

                Section("Kaynak") {
                    Picker("Kaynak", selection: $source) {
                        ForEach(sourceOptions, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section("İçerik") {
                    TextField("Notunu buraya yaz...", text: $content, axis: .vertical)
                        .lineLimit(6...12)
                }
            }
            .navigationTitle("Yeni Not")
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
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func save() {
        let note = HealthNote(
            title: title.trimmingCharacters(in: .whitespaces),
            content: content.trimmingCharacters(in: .whitespaces),
            source: source
        )
        modelContext.insert(note)
        dismiss()
    }
}

#Preview {
    AddNoteView()
        .modelContainer(for: [HealthNote.self], inMemory: true)
}
