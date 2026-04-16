import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            WaterView()
                .tabItem {
                    Label("Su", systemImage: "drop.fill")
                }

            NutritionView()
                .tabItem {
                    Label("Beslenme", systemImage: "fork.knife")
                }

            ExerciseView()
                .tabItem {
                    Label("Egzersiz", systemImage: "figure.run")
                }

            HabitsView()
                .tabItem {
                    Label("Alışkanlıklar", systemImage: "checkmark.circle.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
