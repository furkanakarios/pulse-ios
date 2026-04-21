import Foundation
import SwiftData

@Model
final class PlanItem {
    var id: UUID = UUID()
    var title: String = ""
    var isCompleted: Bool = false
    var sortOrder: Int = 0
    var createdAt: Date = Date.now

    var plan: Plan?

    init(title: String, sortOrder: Int = 0) {
        self.title = title
        self.sortOrder = sortOrder
    }
}
