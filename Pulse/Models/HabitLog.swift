import Foundation
import SwiftData

@Model
final class HabitLog {
    var id: UUID
    var date: Date
    var isCompleted: Bool

    var habit: Habit?

    init(date: Date = .now, isCompleted: Bool = false) {
        self.id = UUID()
        self.date = date
        self.isCompleted = isCompleted
    }
}
