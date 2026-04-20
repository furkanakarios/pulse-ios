import Foundation
import SwiftData

@Model
final class PlanItem {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var sortOrder: Int
    var createdAt: Date

    var plan: Plan?

    init(title: String, sortOrder: Int = 0) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.sortOrder = sortOrder
        self.createdAt = .now
    }
}
