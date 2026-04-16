import Foundation
import SwiftData

@Model
final class MealPlan {
    var id: UUID
    var name: String
    var createdAt: Date
    var isActive: Bool

    @Relationship(deleteRule: .cascade)
    var groups: [MealGroup]

    init(name: String, createdAt: Date = .now) {
        self.id = UUID()
        self.name = name
        self.createdAt = createdAt
        self.isActive = true
        self.groups = []
    }

    var sortedGroups: [MealGroup] {
        groups.sorted { $0.order < $1.order }
    }
}
