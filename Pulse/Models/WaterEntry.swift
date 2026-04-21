import Foundation
import SwiftData

@Model
final class WaterEntry {
    var id: UUID = UUID()
    var amount: Double = 0.0
    var date: Date = Date.now

    init(amount: Double, date: Date = .now) {
        self.amount = amount
        self.date = date
    }
}
