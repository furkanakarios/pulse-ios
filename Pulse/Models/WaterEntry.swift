import Foundation
import SwiftData

@Model
final class WaterEntry {
    var id: UUID
    var amount: Double // ml cinsinden
    var date: Date

    init(amount: Double, date: Date = .now) {
        self.id = UUID()
        self.amount = amount
        self.date = date
    }
}
