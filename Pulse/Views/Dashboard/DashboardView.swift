import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var waterEntries: [WaterEntry]
    @Query private var mealPlans: [MealPlan]
    @Query private var mealLogs: [MealLog]
    @Query private var exerciseEntries: [ExerciseEntry]
    @Query private var habits: [Habit]
    @Query private var habitLogs: [HabitLog]
    @AppStorage("dailyWaterGoal") private var dailyWaterGoal: Double = 2500
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal: Double = 2000
    @AppStorage("dailyExerciseGoal") private var dailyExerciseGoal: Double = 30

    @State private var hkSteps: Double = 0
    @State private var hkCalories: Double = 0
    @State private var hkAuthorized: Bool = false
    @State private var sleepData: SleepData? = nil

    private var todayWater: Double {
        waterEntries.filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    private var activePlan: MealPlan? {
        mealPlans.first { $0.isActive }
    }

    private var todayCompletedMeals: Int {
        mealLogs.filter { Calendar.current.isDateInToday($0.date) && $0.isCompleted }.count
    }

    private var totalMeals: Int {
        activePlan?.groups.count ?? 0
    }

    private var todayExerciseMinutes: Int {
        exerciseEntries.filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.duration }
    }

    private var todayCompletedHabits: Int {
        habitLogs.filter {
            Calendar.current.isDateInToday($0.date) && $0.isCompleted
        }.count
    }

    private var activeHabitsCount: Int {
        habits.filter { !$0.isArchived }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    todayHeaderView
                    summaryGridView
                    if hkAuthorized {
                        healthKitSection
                        NavigationLink(destination: SleepView()) {
                            sleepCard
                        }
                    }
                    if activeHabitsCount > 0 {
                        habitsProgressView
                    }
                    weeklyShortcutView
                    monthlyShortcutView
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Pulse")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .task { await loadHealthKitData() }
        }
    }

    // MARK: - Today Header
    private var todayHeaderView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Günlük Özet")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: - Summary Grid
    private var summaryGridView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            DashboardCard(
                title: "Su",
                value: String(format: "%.0f ml", todayWater),
                icon: "drop.fill",
                color: .blue,
                subtitle: "Hedef: \(Int(dailyWaterGoal)) ml"
            )
            DashboardCard(
                title: "Beslenme",
                value: "\(todayCompletedMeals)/\(totalMeals)",
                icon: "fork.knife",
                color: .orange,
                subtitle: totalMeals == 0 ? "Program eklenmedi" : "Öğün tamamlandı"
            )
            DashboardCard(
                title: "Egzersiz",
                value: "\(todayExerciseMinutes) dk",
                icon: "figure.run",
                color: .green,
                subtitle: "Hedef: \(Int(dailyExerciseGoal)) dk"
            )
            DashboardCard(
                title: "Alışkanlıklar",
                value: "\(todayCompletedHabits)/\(activeHabitsCount)",
                icon: "checkmark.circle.fill",
                color: .purple,
                subtitle: "Bugün tamamlanan"
            )
        }
    }

    // MARK: - Weekly Shortcut
    private var weeklyShortcutView: some View {
        NavigationLink(destination: WeeklyView()) {
            HStack(spacing: 14) {
                Image(systemName: "calendar.day.timeline.left")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Haftalık Görünüm")
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Text("Bu haftanın özetini gör")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Monthly Shortcut
    private var monthlyShortcutView: some View {
        NavigationLink(destination: MonthlyView()) {
            HStack(spacing: 14) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundStyle(.purple)
                    .frame(width: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Aylık Görünüm")
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Text("Takvim ve plan zaman çizelgesi")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Sleep Card
    private var sleepCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "moon.stars.fill")
                .font(.title2)
                .foregroundStyle(.indigo)
                .frame(width: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text("Uyku")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(sleepData?.formattedDuration ?? "Veri yok")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - HealthKit Section
    private var healthKitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Apple Health")
                    .font(.headline)
                Spacer()
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .font(.subheadline)
            }

            HStack(spacing: 12) {
                DashboardCard(
                    title: "Adım",
                    value: hkSteps > 0 ? "\(Int(hkSteps))" : "—",
                    icon: "figure.walk",
                    color: .teal,
                    subtitle: "Bugün atılan adım"
                )
                DashboardCard(
                    title: "Aktif Kalori",
                    value: hkCalories > 0 ? "\(Int(hkCalories)) kcal" : "—",
                    icon: "flame.fill",
                    color: .red,
                    subtitle: "Bugün yakılan"
                )
            }
        }
    }

    // MARK: - HealthKit Data
    private func loadHealthKitData() async {
        guard HealthKitService.shared.isAvailable else { return }
        await HealthKitService.shared.requestAuthorization()
        hkAuthorized = true
        async let steps = HealthKitService.shared.fetchTodaySteps()
        async let calories = HealthKitService.shared.fetchTodayActiveCalories()
        let (s, c) = await (steps, calories)
        hkSteps = s
        hkCalories = c
        sleepData = await HealthKitService.shared.fetchLastNightSleep()
    }

    // MARK: - Habits Progress
    private var habitsProgressView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Alışkanlık Durumu")
                .font(.headline)

            ForEach(habits.filter { !$0.isArchived }) { habit in
                let isCompleted = habitLogs.contains {
                    Calendar.current.isDateInToday($0.date) &&
                    $0.habit?.id == habit.id &&
                    $0.isCompleted
                }

                HStack(spacing: 12) {
                    Image(systemName: habit.icon)
                        .font(.body)
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(isCompleted ? Color.green : Color.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text(habit.name)
                        .font(.subheadline)

                    Spacer()

                    if habit.streak > 0 {
                        Label("\(habit.streak)", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isCompleted ? .green : .secondary)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Dashboard Card
struct DashboardCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [
            WaterEntry.self, MealPlan.self, MealGroup.self, MealItem.self, MealLog.self,
            ExerciseEntry.self, Habit.self, HabitLog.self, Plan.self, PlanItem.self, HealthNote.self
        ], inMemory: true)

}
