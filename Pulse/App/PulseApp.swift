import SwiftUI
import SwiftData

@main
struct PulseApp: App {
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                ContentView()
            } else {
                OnboardingFlow(onFinish: { hasOnboarded = true })
            }
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
            PlanItem.self,
            HealthNote.self
        ])
    }
}
