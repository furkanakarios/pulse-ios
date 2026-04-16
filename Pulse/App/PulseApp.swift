import SwiftUI
import SwiftData

@main
struct PulseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            WaterEntry.self,
            MealPlan.self,
            MealGroup.self,
            MealItem.self,
            MealLog.self,
            ExerciseEntry.self,
            Habit.self,
            HabitLog.self,
            Plan.self,
            HealthNote.self
        ])
    }
}
