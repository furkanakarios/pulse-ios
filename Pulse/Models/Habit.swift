import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var icon: String // SF Symbol adı
    var colorHex: String
    var createdAt: Date
    var isArchived: Bool

    @Relationship(deleteRule: .cascade)
    var logs: [HabitLog]

    init(name: String, icon: String = "checkmark.circle", colorHex: String = "#007AFF", createdAt: Date = .now) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.isArchived = false
        self.logs = []
    }

    var streak: Int {
        let calendar = Calendar.current
        let sortedLogs = logs
            .filter { $0.isCompleted }
            .map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)

        guard !sortedLogs.isEmpty else { return 0 }

        var streak = 0
        var checkDate = calendar.startOfDay(for: .now)

        for logDate in sortedLogs {
            if logDate == checkDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        return streak
    }
}
