import SwiftUI
import SwiftData

@main
struct PulseApp: App {
    @AppStorage("hasSeenNotificationPermission") private var hasSeenNotificationPermission = false
    @State private var showNotificationPermission = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(isPresented: $showNotificationPermission) {
                    NotificationPermissionView(isPresented: $showNotificationPermission)
                }
                .task {
                    guard !hasSeenNotificationPermission else { return }
                    let status = await NotificationService.shared.authorizationStatus()
                    if status == .notDetermined {
                        showNotificationPermission = true
                    }
                    hasSeenNotificationPermission = true
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
