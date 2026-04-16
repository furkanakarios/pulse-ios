import Foundation
import SwiftData

@Model
final class ExerciseEntry {
    var id: UUID
    var activityType: String // "Koşu", "Yüzme", "Bisiklet" vb.
    var duration: Int // dakika cinsinden
    var calories: Double
    var notes: String
    var date: Date

    init(activityType: String, duration: Int, calories: Double = 0, notes: String = "", date: Date = .now) {
        self.id = UUID()
        self.activityType = activityType
        self.duration = duration
        self.calories = calories
        self.notes = notes
        self.date = date
    }
}
