import Foundation
import SwiftData

@Model
final class MealEntry {
    var id: UUID
    var name: String
    var calories: Double
    var mealType: String // "Kahvaltı", "Öğle", "Akşam", "Ara Öğün"
    var notes: String
    var date: Date

    init(name: String, calories: Double, mealType: String, notes: String = "", date: Date = .now) {
        self.id = UUID()
        self.name = name
        self.calories = calories
        self.mealType = mealType
        self.notes = notes
        self.date = date
    }
}
