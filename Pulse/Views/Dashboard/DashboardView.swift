import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var waterEntries: [WaterEntry]
    @Query private var mealPlans: [MealPlan]
    @Query private var mealLogs: [MealLog]
    @Query private var exerciseEntries: [ExerciseEntry]
    @Query private var habits: [Habit]
    @Query private var habitLogs: [HabitLog]
    @Query(sort: \HealthNote.date, order: .reverse) private var notes: [HealthNote]

    @AppStorage("dailyWaterGoal") private var dailyWaterGoal: Double = 2500
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal: Double = 2000
    @AppStorage("dailyExerciseGoal") private var dailyExerciseGoal: Double = 30

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
                    if activeHabitsCount > 0 {
                        habitsProgressView
                    }
                    notesShortcutView
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

    // MARK: - Notes Shortcut
    private var notesShortcutView: some View {
        VStack(alignment: .leading, spacing: 12) {
            NavigationLink(destination: NotesView()) {
                HStack {
                    Text("Sağlık Notları")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(notes.count) not")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if notes.isEmpty {
                Text("Henüz not eklenmedi.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(notes.prefix(2)) { note in
                    NavigationLink(destination: NotesView()) {
                        HStack(spacing: 10) {
                            Image(systemName: "note.text")
                                .foregroundStyle(.teal)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(note.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(note.source)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(note.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
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
            WaterEntry.self, MealPlan.self, MealGroup.self, MealItem.self, MealLog.self,
            ExerciseEntry.self, Habit.self, HabitLog.self, Plan.self, HealthNote.self
        ], inMemory: true)

}
