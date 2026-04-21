import Foundation
import SwiftData

@Model
final class MealPlan {
    var id: UUID = UUID()
    var name: String = ""
    var createdAt: Date = Date.now
    var isActive: Bool = true

    @Relationship(deleteRule: .cascade)
    var groups: [MealGroup] = []

    init(name: String, createdAt: Date = .now) {
        self.name = name
        self.createdAt = createdAt
    }

    var sortedGroups: [MealGroup] {
        groups.sorted { $0.order < $1.order }
    }
}
