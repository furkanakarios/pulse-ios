import Foundation
import WidgetKit

enum WidgetDataWriter {
    static let suiteName = "group.com.furkanakarios.pulse"

    static func write(waterMl: Double, waterGoalMl: Double, completedHabits: Int, totalHabits: Int) {
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.set(waterMl, forKey: "widget_waterMl")
        defaults.set(waterGoalMl, forKey: "widget_waterGoalMl")
        defaults.set(completedHabits, forKey: "widget_completedHabits")
        defaults.set(totalHabits, forKey: "widget_totalHabits")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
