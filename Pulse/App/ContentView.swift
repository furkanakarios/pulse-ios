import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("dailyWaterGoal") private var dailyWaterGoal: Double = 2500

    @Query(filter: #Predicate<WaterEntry> { _ in true })
    private var allWaterEntries: [WaterEntry]

    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Query private var habitLogs: [HabitLog]

    private var todayWaterMl: Double {
        allWaterEntries
            .filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    private var completedHabitsToday: Int {
        let activeHabits = habits.filter { !$0.isArchived }
        return activeHabits.filter { habit in
            habitLogs.contains {
                $0.habit?.id == habit.id &&
                Calendar.current.isDateInToday($0.date) &&
                $0.isCompleted
            }
        }.count
    }

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Ana Sayfa", systemImage: "house.fill") }

            WaterView()
                .tabItem { Label("Su", systemImage: "drop.fill") }

            NutritionView()
                .tabItem { Label("Beslenme", systemImage: "fork.knife") }

            ExerciseView()
                .tabItem { Label("Egzersiz", systemImage: "figure.run") }

            MoreView()
                .tabItem { Label("Daha Fazla", systemImage: "ellipsis.circle.fill") }
        }
        .onChange(of: allWaterEntries) { _, _ in syncWidget() }
        .onChange(of: habitLogs) { _, _ in syncWidget() }
        .onAppear { syncWidget() }
    }

    private func syncWidget() {
        let activeHabits = habits.filter { !$0.isArchived }
        WidgetDataWriter.write(
            waterMl: todayWaterMl,
            waterGoalMl: dailyWaterGoal,
            completedHabits: completedHabitsToday,
            totalHabits: activeHabits.count
        )
    }
}

#Preview {
    ContentView()
}
