import Foundation
import SwiftData

@Model
final class ExerciseEntry {
    var id: UUID = UUID()
    var activityType: String = ""
    var duration: Int = 0
    var calories: Double = 0.0
    var notes: String = ""
    var date: Date = Date.now

    init(activityType: String, duration: Int, calories: Double = 0, notes: String = "", date: Date = .now) {
        self.activityType = activityType
        self.duration = duration
        self.calories = calories
        self.notes = notes
        self.date = date
    }
}
