import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HealthNote.date, order: .reverse) private var notes: [HealthNote]

    @State private var showAddNote = false
    @State private var searchText = ""

    private var filteredNotes: [HealthNote] {
        if searchText.isEmpty { return notes }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText) ||
            $0.source.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    emptyStateView
                } else {
                    notesList
                }
            }
            .navigationTitle("Sağlık Notları")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Not ara...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddNote) {
                AddNoteView()
            }
        }
    }

    // MARK: - Notes List
    private var notesList: some View {
        List {
            ForEach(filteredNotes) { note in
                NavigationLink(destination: NoteDetailView(note: note)) {
                    noteRow(note)
                }
            }
            .onDelete(perform: deleteNotes)
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Note Row
    private func noteRow(_ note: HealthNote) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(note.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Spacer()
                sourceTag(note.source)
            }
            Text(note.content)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Text(note.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Source Tag
    private func sourceTag(_ source: String) -> some View {
        Text(source)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
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

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "note.text")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("Henüz not yok")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Doktor ve diyetisyen tavsiyelerini\nburada saklayabilirsin.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                showAddNote = true
            } label: {
                Label("Not Ekle", systemImage: "plus")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.teal)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }

    // MARK: - Delete
    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredNotes[index])
        }
    }
}
