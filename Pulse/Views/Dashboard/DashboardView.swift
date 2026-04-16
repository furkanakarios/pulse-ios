import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var waterEntries: [WaterEntry]
    @Query private var mealEntries: [MealEntry]
    @Query private var exerciseEntries: [ExerciseEntry]
    @Query private var habits: [Habit]
    @Query private var habitLogs: [HabitLog]

    private var todayWater: Double {
        waterEntries.filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    private var todayCalories: Double {
        mealEntries.filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.calories }
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
                    if activeHabitsCount > 0 {
                        habitsProgressView
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Pulse")
            .navigationBarTitleDisplayMode(.large)
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
                subtitle: "Günlük hedef: 2500 ml"
            )
            DashboardCard(
                title: "Kalori",
                value: String(format: "%.0f kcal", todayCalories),
                icon: "fork.knife",
                color: .orange,
                subtitle: "Günlük hedef: 2000 kcal"
            )
            DashboardCard(
                title: "Egzersiz",
                value: "\(todayExerciseMinutes) dk",
                icon: "figure.run",
                color: .green,
                subtitle: "Günlük hedef: 30 dk"
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
            WaterEntry.self, MealEntry.self, ExerciseEntry.self,
            Habit.self, HabitLog.self, Plan.self, HealthNote.self
        ], inMemory: true)
}
