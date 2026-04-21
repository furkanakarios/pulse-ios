import Foundation
import SwiftData

@Model
final class MealItem {
    var id: UUID = UUID()
    var name: String = ""
    var quantity: String = ""
    var calories: Double? = nil
    var order: Int = 0

    var group: MealGroup?

    init(name: String, quantity: String = "", calories: Double? = nil, order: Int = 0) {
        self.name = name
        self.quantity = quantity
        self.calories = calories
        self.order = order
    }
}
