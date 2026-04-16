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
            MealEntry.self,
            ExerciseEntry.self,
            Habit.self,
            HabitLog.self,
            Plan.self,
            HealthNote.self
        ])
    }
}
