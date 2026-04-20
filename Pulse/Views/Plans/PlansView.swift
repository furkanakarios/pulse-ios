import SwiftUI
import SwiftData

struct PlansView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Plan.startDate, order: .reverse) private var plans: [Plan]

    @State private var showAddPlan = false
    @State private var selectedType: PlanFilter = .all

    enum PlanFilter: String, CaseIterable {
        case all = "Tümü"
        case weekly = "Haftalık"
        case monthly = "Aylık"
        case active = "Aktif"
        case completed = "Tamamlanan"
    }

    private var filtered: [Plan] {
        switch selectedType {
        case .all: return plans
        case .weekly: return plans.filter { $0.planType == "Haftalık" }
        case .monthly: return plans.filter { $0.planType == "Aylık" }
        case .active: return plans.filter { !$0.isCompleted }
        case .completed: return plans.filter { $0.isCompleted }
        }
    }

    private var activePlans: [Plan] { plans.filter { !$0.isCompleted } }
    private var completedPlans: [Plan] { plans.filter { $0.isCompleted } }

    var body: some View {
        NavigationStack {
            Group {
                if plans.isEmpty {
                    emptyStateView
                } else {
                    plansList
                }
            }
            .navigationTitle("Planlar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddPlan = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddPlan) {
                AddPlanView()
            }
        }
    }

    // MARK: - Plans List
    private var plansList: some View {
        List {
            // Filtre
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PlanFilter.allCases, id: \.self) { filter in
                            Button(filter.rawValue) {
                                selectedType = filter
                            }
                            .font(.caption)
                            .fontWeight(selectedType == filter ? .semibold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedType == filter ? Color.blue : Color(.secondarySystemBackground))
                            .foregroundStyle(selectedType == filter ? .white : .primary)
                            .clipShape(Capsule())
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowBackground(Color.clear)
            }

            if filtered.isEmpty {
                Section {
                    Text("Bu kategoride plan yok.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            } else {
                Section("\(filtered.count) plan") {
                    ForEach(filtered) { plan in
                        NavigationLink(destination: PlanDetailView(plan: plan)) {
                            PlanRow(plan: plan, onToggle: { togglePlan(plan) })
                        }
                    }
                    .onDelete { offsets in
                        for i in offsets { modelContext.delete(filtered[i]) }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("Henüz plan yok")
                .font(.title3).fontWeight(.semibold)
            Text("Haftalık veya aylık sağlık hedeflerini\nburaya ekleyebilirsin.")
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                showAddPlan = true
            } label: {
                Label("Plan Ekle", systemImage: "plus")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }

    private func togglePlan(_ plan: Plan) {
        plan.isCompleted.toggle()
    }
}

// MARK: - Plan Row
struct PlanRow: View {
    let plan: Plan
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: plan.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(plan.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(plan.title)
                    .font(.subheadline).fontWeight(.medium)
                    .strikethrough(plan.isCompleted, color: .secondary)
                    .foregroundStyle(plan.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    planTypeBadge(plan.planType)
                    Text("\(plan.startDate.formatted(date: .abbreviated, time: .omitted)) – \(plan.endDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !plan.notes.isEmpty {
                    Text(plan.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private func planTypeBadge(_ type: String) -> some View {
        Text(type)
            .font(.caption2).fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background(type == "Haftalık" ? Color.blue : Color.purple)
            .clipShape(Capsule())
    }
}
