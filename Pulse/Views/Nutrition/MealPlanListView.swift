import SwiftUI
import SwiftData

struct MealPlanListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealPlan.createdAt, order: .reverse) private var plans: [MealPlan]

    var body: some View {
        List {
            let active = plans.filter { $0.isActive }
            let passive = plans.filter { !$0.isActive }

            if !active.isEmpty {
                Section("Aktif Program") {
                    ForEach(active) { plan in
                        planRow(plan, isActive: true)
                    }
                }
            }

            if !passive.isEmpty {
                Section("Geçmiş Programlar") {
                    ForEach(passive) { plan in
                        planRow(plan, isActive: false)
                    }
                    .onDelete { offsets in
                        let passivePlans = passive
                        for index in offsets {
                            modelContext.delete(passivePlans[index])
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Tüm Programlar")
        .navigationBarTitleDisplayMode(.large)
    }

    private func planRow(_ plan: MealPlan, isActive: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(plan.name)
                    .fontWeight(isActive ? .semibold : .regular)
                Text("\(plan.groups.count) öğün grubu · \(plan.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isActive {
                Text("Aktif")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green)
                    .clipShape(Capsule())
            } else {
                Button("Aktif Yap") {
                    activatePlan(plan)
                }
                .font(.caption)
                .buttonStyle(.bordered)
                .tint(.blue)
            }
        }
        .padding(.vertical, 2)
    }

    private func activatePlan(_ plan: MealPlan) {
        for p in plans { p.isActive = false }
        plan.isActive = true
    }
}
