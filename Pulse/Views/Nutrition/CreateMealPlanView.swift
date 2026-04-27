import SwiftUI
import SwiftData

struct CreateMealPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var existingPlans: [MealPlan]

    @State private var planName = ""
    @State private var groups: [DraftGroup] = []
    @State private var showAddGroup = false
    @State private var newGroupName = ""
    @State private var newGroupTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now
    @State private var newGroupUseTime = false

    struct DraftGroup: Identifiable {
        let id = UUID()
        var name: String
        var scheduledTime: Date?
        var items: [DraftItem] = []
    }

    struct DraftItem: Identifiable {
        let id = UUID()
        var name: String
        var quantity: String
        var calories: String
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Program Adı") {
                    TextField("Örn: Diyetisyen Programı - Nisan", text: $planName)
                }

                Section {
                    ForEach($groups) { $group in
                        GroupRowView(group: $group)
                    }
                    .onDelete { offsets in
                        groups.remove(atOffsets: offsets)
                    }

                    Button {
                        showAddGroup = true
                    } label: {
                        Label("Öğün Grubu Ekle", systemImage: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                } header: {
                    Text("Öğün Grupları")
                } footer: {
                    Text("Her grubu sola kaydırarak silebilirsin.")
                        .font(.caption)
                }
            }
            .navigationTitle("Yeni Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                        .fontWeight(.semibold)
                        .disabled(planName.trimmingCharacters(in: .whitespaces).isEmpty || groups.isEmpty)
                }
            }
            .sheet(isPresented: $showAddGroup) {
                addGroupSheet
            }
        }
    }

    // MARK: - Add Group Sheet
    private var addGroupSheet: some View {
        NavigationStack {
            Form {
                Section("Öğün Adı") {
                    TextField("Örn: Sabah Kahvaltısı, Ara Öğün 1", text: $newGroupName)
                }
                Section {
                    Toggle("Saat Belirle", isOn: $newGroupUseTime)
                    if newGroupUseTime {
                        DatePicker("Saat", selection: $newGroupTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("Öğün Grubu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        resetGroupForm()
                        showAddGroup = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        let newGroup = DraftGroup(
                            name: newGroupName.trimmingCharacters(in: .whitespaces),
                            scheduledTime: newGroupUseTime ? newGroupTime : nil
                        )
                        groups.append(newGroup)
                        resetGroupForm()
                        showAddGroup = false
                    }
                    .fontWeight(.semibold)
                    .disabled(newGroupName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Save
    private func save() {
        for existing in existingPlans { existing.isActive = false }
        let plan = MealPlan(name: planName.trimmingCharacters(in: .whitespaces))
        modelContext.insert(plan)

        for (index, draftGroup) in groups.enumerated() {
            let group = MealGroup(
                name: draftGroup.name,
                scheduledTime: draftGroup.scheduledTime,
                order: index
            )
            group.plan = plan
            modelContext.insert(group)

            for (itemIndex, draftItem) in draftGroup.items.enumerated() {
                let item = MealItem(
                    name: draftItem.name.trimmingCharacters(in: .whitespaces),
                    quantity: draftItem.quantity.trimmingCharacters(in: .whitespaces),
                    calories: Double(draftItem.calories),
                    order: itemIndex
                )
                item.group = group
                modelContext.insert(item)
            }
        }

        dismiss()
    }

    private func resetGroupForm() {
        newGroupName = ""
        newGroupUseTime = false
        newGroupTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now
    }
}

// MARK: - Group Row (expandable, item eklenebilir)
struct GroupRowView: View {
    @Binding var group: CreateMealPlanView.DraftGroup
    @State private var isExpanded = true
    @State private var newItemName = ""
    @State private var newItemQty = ""
    @State private var newItemCal = ""
    @State private var isLookingUp = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(group.items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name).font(.subheadline)
                        if !item.quantity.isEmpty {
                            Text(item.quantity).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    if !item.calories.isEmpty {
                        Text("\(item.calories) kcal")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .onDelete { offsets in
                group.items.remove(atOffsets: offsets)
            }

            HStack(spacing: 8) {
                TextField("Yiyecek adı", text: $newItemName)
                    .font(.subheadline)
                TextField("Miktar", text: $newItemQty)
                    .font(.subheadline)
                    .frame(width: 70)
                HStack(spacing: 2) {
                    TextField("kcal", text: $newItemCal)
                        .font(.subheadline)
                        .keyboardType(.numberPad)
                        .frame(width: 44)
                    if isLookingUp {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 16)
                    } else if newItemCal.isEmpty && !newItemName.isEmpty {
                        Button {
                            lookupCalories()
                        } label: {
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Button {
                    addItem()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
                .disabled(newItemName.trimmingCharacters(in: .whitespaces).isEmpty || isLookingUp)
            }
            .padding(.top, 4)

            if !newItemName.isEmpty && newItemCal.isEmpty && !isLookingUp {
                Text("✦ Kalori alanı boşsa ✦ tuşuna basarak otomatik hesaplanır")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        } label: {
            HStack {
                Text(group.name).fontWeight(.medium)
                Spacer()
                if let time = group.scheduledTime {
                    Text(time, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                let total = group.items.compactMap { Double($0.calories) }.reduce(0, +)
                if total > 0 {
                    Text("\(Int(total)) kcal")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    Text("\(group.items.count) yiyecek")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func lookupCalories() {
        guard !newItemName.isEmpty else { return }
        isLookingUp = true
        Task {
            let result = await NutritionService.shared.estimateCalories(
                name: newItemName,
                quantity: newItemQty
            )
            await MainActor.run {
                if let kcal = result {
                    newItemCal = String(Int(kcal))
                }
                isLookingUp = false
            }
        }
    }

    private func addItem() {
        let name = newItemName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        if newItemCal.isEmpty {
            // Kalori boşsa önce lookup yap, sonra ekle
            isLookingUp = true
            Task {
                let result = await NutritionService.shared.estimateCalories(
                    name: name,
                    quantity: newItemQty
                )
                await MainActor.run {
                    let cal = result.map { String(Int($0)) } ?? ""
                    group.items.append(CreateMealPlanView.DraftItem(
                        name: name,
                        quantity: newItemQty,
                        calories: cal
                    ))
                    newItemName = ""
                    newItemQty = ""
                    newItemCal = ""
                    isLookingUp = false
                }
            }
        } else {
            group.items.append(CreateMealPlanView.DraftItem(
                name: name,
                quantity: newItemQty,
                calories: newItemCal
            ))
            newItemName = ""
            newItemQty = ""
            newItemCal = ""
        }
    }
}
