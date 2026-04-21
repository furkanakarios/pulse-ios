import Foundation
import SwiftData

@Model
final class MealLog {
    var id: UUID = UUID()
    var date: Date = Date.now
    var isCompleted: Bool = false

    var group: MealGroup?

    init(date: Date = .now, isCompleted: Bool = false) {
        self.date = date
        self.isCompleted = isCompleted
    }
}
