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

extension WaterEntry {
    var amountML: Int { Int(amount) }
    var hour: Int { Calendar.current.component(.hour, from: date) }
}
