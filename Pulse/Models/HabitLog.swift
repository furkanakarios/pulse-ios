import Foundation
import SwiftData

@Model
final class HabitLog {
    var id: UUID = UUID()
    var date: Date = Date.now
    var isCompleted: Bool = false

    var habit: Habit?

    init(date: Date = .now, isCompleted: Bool = false) {
        self.date = date
        self.isCompleted = isCompleted
    }
}
