import Foundation
import SwiftData

@Model
final class Plan {
    var id: UUID
    var title: String
    var notes: String
    var startDate: Date
    var endDate: Date
    var isCompleted: Bool
    var planType: String // "Haftalık", "Aylık"

    init(title: String, notes: String = "", startDate: Date = .now, endDate: Date, planType: String = "Haftalık") {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.startDate = startDate
        self.endDate = endDate
        self.isCompleted = false
        self.planType = planType
    }
}
