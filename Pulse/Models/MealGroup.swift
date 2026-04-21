import Foundation
import SwiftData

@Model
final class MealGroup {
    var id: UUID = UUID()
    var name: String = ""
    var scheduledTime: Date? = nil
    var order: Int = 0

    var plan: MealPlan?

    @Relationship(deleteRule: .cascade)
    var items: [MealItem] = []

    @Relationship(deleteRule: .cascade)
    var logs: [MealLog] = []

    init(name: String, scheduledTime: Date? = nil, order: Int = 0) {
        self.name = name
        self.scheduledTime = scheduledTime
        self.order = order
    }

    var sortedItems: [MealItem] {
        items.sorted { $0.order < $1.order }
    }

    var totalCalories: Double? {
        let cals = items.compactMap { $0.calories }
        return cals.isEmpty ? nil : cals.reduce(0, +)
    }

    func isCompleted(on date: Date) -> Bool {
        logs.contains {
            Calendar.current.isDate($0.date, inSameDayAs: date) && $0.isCompleted
        }
    }
}
