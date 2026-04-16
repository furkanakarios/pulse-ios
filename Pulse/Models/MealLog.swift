import Foundation
import SwiftData

@Model
final class MealLog {
    var id: UUID
    var date: Date
    var isCompleted: Bool

    var group: MealGroup?

    init(date: Date = .now, isCompleted: Bool = false) {
        self.id = UUID()
        self.date = date
        self.isCompleted = isCompleted
    }
}
