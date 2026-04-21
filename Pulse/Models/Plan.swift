import Foundation
import SwiftData

@Model
final class Plan {
    var id: UUID = UUID()
    var title: String = ""
    var notes: String = ""
    var startDate: Date = Date.now
    var endDate: Date = Date.now
    var isCompleted: Bool = false
    var planType: String = "Haftalık"

    @Relationship(deleteRule: .cascade, inverse: \PlanItem.plan)
    var items: [PlanItem] = []

    var completedItemsCount: Int { items.filter { $0.isCompleted }.count }
    var itemProgress: Double {
        items.isEmpty ? 0 : Double(completedItemsCount) / Double(items.count)
    }

    init(title: String, notes: String = "", startDate: Date = .now, endDate: Date, planType: String = "Haftalık") {
        self.title = title
        self.notes = notes
        self.startDate = startDate
        self.endDate = endDate
        self.planType = planType
    }
}
