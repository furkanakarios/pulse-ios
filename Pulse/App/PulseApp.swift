import SwiftUI
import SwiftData

@main
struct PulseApp: App {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var showLaunch = true

    let container: ModelContainer = {
        let schema = Schema([
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
            HealthNote.self,
            Achievement.self
        ])
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private("iCloud.com.furkanakarios.pulse")
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            let localConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
            return try! ModelContainer(for: schema, configurations: [localConfig])
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasOnboarded {
                    ContentView()
                } else {
                    OnboardingFlow(onFinish: { hasOnboarded = true })
                }

                if showLaunch {
                    LaunchScreen()
                        .transition(.opacity)
                        .zIndex(1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation(.easeOut(duration: 0.35)) {
                                    showLaunch = false
                                }
                            }
                        }
                }
            }
        }
        .modelContainer(container)
    }
}
