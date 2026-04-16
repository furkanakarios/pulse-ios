import Foundation
import SwiftData

@Model
final class MealItem {
    var id: UUID
    var name: String
    var quantity: String  // "2 adet", "1 dilim", "120g" gibi serbest metin
    var calories: Double? // opsiyonel
    var order: Int

    var group: MealGroup?

    init(name: String, quantity: String = "", calories: Double? = nil, order: Int = 0) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.calories = calories
        self.order = order
    }
}
