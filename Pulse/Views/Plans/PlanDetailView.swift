import SwiftUI
import SwiftData

struct PlanDetailView: View {
    @Bindable var plan: Plan
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var editTitle = ""
    @State private var editNotes = ""

    var daysRemaining: Int {
        max(0, Calendar.current.dateComponents([.day], from: .now, to: plan.endDate).day ?? 0)
    }

    var progress: Double {
        let total = plan.endDate.timeIntervalSince(plan.startDate)
        let elapsed = Date.now.timeIntervalSince(plan.startDate)
        return max(0, min(elapsed / total, 1.0))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header card
                headerCard

                // Progress
                if !plan.isCompleted {
                    progressCard
                }

                // Notes
                if !plan.notes.isEmpty || isEditing {
                    notesCard
                }
            }
            .padding()
        }
        .navigationTitle(isEditing ? "Düzenle" : plan.planType)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isEditing {
                    Button("Kaydet") {
                        plan.title = editTitle
                        plan.notes = editNotes
                        isEditing = false
                    }
                    .fontWeight(.semibold)
                    .disabled(editTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                } else {
                    Menu {
                        Button { startEditing() } label: {
                            Label("Düzenle", systemImage: "pencil")
                        }
                        Button {
                            plan.isCompleted.toggle()
                        } label: {
                            Label(plan.isCompleted ? "Aktife Al" : "Tamamlandı İşaretle", systemImage: plan.isCompleted ? "arrow.uturn.left" : "checkmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }

    // MARK: - Header Card
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                typeBadge
                Spacer()
                if plan.isCompleted {
                    Label("Tamamlandı", systemImage: "checkmark.circle.fill")
                        .font(.caption).fontWeight(.medium)
                        .foregroundStyle(.green)
                }
            }

            if isEditing {
                TextField("Plan başlığı", text: $editTitle)
                    .font(.title3).fontWeight(.bold)
            } else {
                Text(plan.title)
                    .font(.title3).fontWeight(.bold)
            }

            HStack(spacing: 16) {
                Label(plan.startDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    .font(.caption).foregroundStyle(.secondary)
                Image(systemName: "arrow.right")
                    .font(.caption2).foregroundStyle(.secondary)
                Label(plan.endDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Progress Card
    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("İlerleme")
                    .font(.headline)
                Spacer()
                Text("\(daysRemaining) gün kaldı")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: progress)
                .tint(.blue)
            Text(String(format: "%%%.0f tamamlandı", progress * 100))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Notes Card
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notlar")
                .font(.headline)
            if isEditing {
                TextField("Açıklama...", text: $editNotes, axis: .vertical)
                    .lineLimit(3...8)
            } else {
                Text(plan.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var typeBadge: some View {
        Text(plan.planType)
            .font(.caption2).fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(plan.planType == "Haftalık" ? Color.blue : Color.purple)
            .clipShape(Capsule())
    }

    private func startEditing() {
        editTitle = plan.title
        editNotes = plan.notes
        isEditing = true
    }
}
