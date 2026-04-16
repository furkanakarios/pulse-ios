import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var note: HealthNote

    @State private var isEditing = false
    @State private var editTitle = ""
    @State private var editContent = ""
    @State private var editSource = ""

    let sourceOptions = ["Kişisel", "Doktor", "Diyetisyen", "Psikolog"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    sourceTag(note.source)
                    Spacer()
                    Text(note.date.formatted(date: .long, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if isEditing {
                    editingView
                } else {
                    readingView
                }
            }
            .padding()
        }
        .navigationTitle(isEditing ? "Düzenle" : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isEditing {
                    Button("Kaydet") {
                        note.title = editTitle
                        note.content = editContent
                        note.source = editSource
                        isEditing = false
                    }
                    .fontWeight(.semibold)
                    .disabled(editTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                } else {
                    Button("Düzenle") {
                        editTitle = note.title
                        editContent = note.content
                        editSource = note.source
                        isEditing = true
                    }
                }
            }
        }
    }

    // MARK: - Reading View
    private var readingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(note.title)
                .font(.title2)
                .fontWeight(.bold)
            Divider()
            Text(note.content)
                .font(.body)
                .lineSpacing(6)
        }
    }

    // MARK: - Editing View
    private var editingView: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Başlık", text: $editTitle)
                .font(.title2)
                .fontWeight(.bold)

            Picker("Kaynak", selection: $editSource) {
                ForEach(sourceOptions, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)

            Divider()

            TextField("İçerik...", text: $editContent, axis: .vertical)
                .font(.body)
                .lineSpacing(6)
                .lineLimit(10...)
        }
    }

    // MARK: - Source Tag
    private func sourceTag(_ source: String) -> some View {
        Text(source)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(sourceColor(source))
            .clipShape(Capsule())
    }

    private func sourceColor(_ source: String) -> Color {
        switch source {
        case "Doktor": return .blue
        case "Diyetisyen": return .green
        case "Psikolog": return .purple
        default: return .gray
        }
    }
}
