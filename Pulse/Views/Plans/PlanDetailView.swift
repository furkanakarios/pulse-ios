import SwiftUI
import SwiftData

struct PlanDetailView: View {
    @Bindable var plan: Plan
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var editTitle = ""
    @State private var editNotes = ""
    @State private var newItemText = ""
    @State private var showAddItem = false

    var daysRemaining: Int {
        max(0, Calendar.current.dateComponents([.day], from: .now, to: plan.endDate).day ?? 0)
    }

    var progress: Double {
        let total = plan.endDate.timeIntervalSince(plan.startDate)
        let elapsed = Date.now.timeIntervalSince(plan.startDate)
        return max(0, min(elapsed / total, 1.0))
    }

    private var sortedItems: [PlanItem] {
        plan.items.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                if !plan.isCompleted {
                    progressCard
                }
                itemsCard
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
                            Label(
                                plan.isCompleted ? "Aktife Al" : "Tamamlandı İşaretle",
                                systemImage: plan.isCompleted ? "arrow.uturn.left" : "checkmark.circle"
                            )
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
                Text("Zaman İlerlemesi")
                    .font(.headline)
                Spacer()
                Text("\(daysRemaining) gün kaldı")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: progress)
                .tint(.blue)
            Text(String(format: "%%%0.f tamamlandı", progress * 100))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Items Card
    private var itemsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Görevler")
                    .font(.headline)
                Spacer()
                if !plan.items.isEmpty {
                    Text("\(plan.completedItemsCount)/\(plan.items.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Button {
                    showAddItem = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title3)
                }
            }

            if !plan.items.isEmpty {
                ProgressView(value: plan.itemProgress)
                    .tint(.green)
            }

            if plan.items.isEmpty && !showAddItem {
                Text("Henüz görev eklenmedi.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ForEach(sortedItems) { item in
                    itemRow(item)
                }
                .onDelete { offsets in
                    for i in offsets { modelContext.delete(sortedItems[i]) }
                }
            }

            if showAddItem {
                addItemField
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func itemRow(_ item: PlanItem) -> some View {
        HStack(spacing: 12) {
            Button {
                item.isCompleted.toggle()
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Text(item.title)
                .font(.subheadline)
                .strikethrough(item.isCompleted, color: .secondary)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var addItemField: some View {
        HStack(spacing: 10) {
            Image(systemName: "circle")
                .font(.title3)
                .foregroundStyle(.secondary)

            TextField("Yeni görev...", text: $newItemText)
                .font(.subheadline)
                .onSubmit { saveNewItem() }

            if !newItemText.trimmingCharacters(in: .whitespaces).isEmpty {
                Button("Ekle") { saveNewItem() }
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }

            Button {
                showAddItem = false
                newItemText = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
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

    private func saveNewItem() {
        let text = newItemText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        let item = PlanItem(title: text, sortOrder: plan.items.count)
        modelContext.insert(item)
        plan.items.append(item)
        newItemText = ""
    }
}
