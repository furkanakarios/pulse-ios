import SwiftUI
import SwiftData

struct NutritionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealPlan.createdAt, order: .reverse) private var plans: [MealPlan]
    @Query private var mealLogs: [MealLog]

    @State private var showCreatePlan = false
    @State private var showAllPlans = false

    private var activePlan: MealPlan? {
        plans.first { $0.isActive }
    }

    private var todayLogs: [MealLog] {
        mealLogs.filter { Calendar.current.isDateInToday($0.date) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let plan = activePlan {
                    activePlanView(plan)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Beslenme")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showCreatePlan = true
                        } label: {
                            Label("Yeni Program", systemImage: "plus")
                        }
                        Button {
                            showAllPlans = true
                        } label: {
                            Label("Tüm Programlar", systemImage: "list.bullet")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showCreatePlan) {
                CreateMealPlanView()
                    .onDisappear { activateLatestIfNeeded() }
            }
            .navigationDestination(isPresented: $showAllPlans) {
                MealPlanListView()
            }
        }
    }

    // MARK: - Active Plan View
    private func activePlanView(_ plan: MealPlan) -> some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(plan.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(completedCount(for: plan))/\(plan.groups.count) öğün tamamlandı")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    CircularProgressView(
                        progress: plan.groups.isEmpty ? 0 : Double(completedCount(for: plan)) / Double(plan.groups.count)
                    )
                    .frame(width: 44, height: 44)
                }
                .padding(.vertical, 4)
            }

            ForEach(plan.sortedGroups) { group in
                Section {
                    ForEach(group.sortedItems) { item in
                        itemRow(item)
                    }
                } header: {
                    mealGroupHeader(group, plan: plan)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Group Header (toggle içeren)
    private func mealGroupHeader(_ group: MealGroup, plan: MealPlan) -> some View {
        let completed = group.isCompleted(on: .now)

        return HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(group.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(completed ? .green : .primary)
                if let time = group.scheduledTime {
                    Text(time, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if let totalCal = group.totalCalories {
                Text("\(Int(totalCal)) kcal")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.trailing, 8)
            }
            Button {
                toggleMealGroup(group)
            } label: {
                Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(completed ? .green : .secondary)
            }
            .buttonStyle(.plain)
        }
        .textCase(nil)
        .padding(.vertical, 2)
    }

    // MARK: - Item Row
    private func itemRow(_ item: MealItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline)
                if !item.quantity.isEmpty {
                    Text(item.quantity)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if let cal = item.calories {
                Text("\(Int(cal)) kcal")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Henüz program yok")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Diyetisyeninden aldığın listeyi\nhemen ekleyebilirsin.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                showCreatePlan = true
            } label: {
                Label("Program Oluştur", systemImage: "plus")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }

    // MARK: - Helpers
    private func completedCount(for plan: MealPlan) -> Int {
        plan.groups.filter { $0.isCompleted(on: .now) }.count
    }

    private func toggleMealGroup(_ group: MealGroup) {
        let today = Calendar.current.startOfDay(for: .now)
        if let existing = group.logs.first(where: { Calendar.current.isDateInToday($0.date) }) {
            existing.isCompleted.toggle()
        } else {
            let log = MealLog(date: today, isCompleted: true)
            log.group = group
            modelContext.insert(log)
        }
    }

    private func activateLatestIfNeeded() {
        guard !plans.isEmpty, !plans.contains(where: { $0.isActive }) else { return }
        plans.first?.isActive = true
    }
}

// MARK: - Circular Progress
struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.orange.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(progress >= 1.0 ? Color.green : Color.orange,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.4), value: progress)
            Text("\(Int(progress * 100))%")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(progress >= 1.0 ? .green : .orange)
        }
    }
}

#Preview {
    NutritionView()
        .modelContainer(for: [
            MealPlan.self, MealGroup.self, MealItem.self, MealLog.self
        ], inMemory: true)
}
