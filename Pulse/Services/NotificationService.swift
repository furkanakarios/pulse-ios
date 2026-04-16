import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    // MARK: - Identifiers
    enum Identifier {
        static let waterReminder = "com.pulse.water.reminder"
        static let morningSummary = "com.pulse.morning.summary"
        static func habitReminder(for habitID: String) -> String {
            "com.pulse.habit.reminder.\(habitID)"
        }
    }

    // MARK: - Permission
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Water Reminder
    /// intervalMinutes: kaç dakikada bir hatırlatsın (örn. 60)
    /// startHour / endHour: sadece bu saatler arasında (örn. 8-22)
    func scheduleWaterReminder(intervalMinutes: Int, startHour: Int = 8, endHour: Int = 22) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Identifier.waterReminder])

        let content = UNMutableNotificationContent()
        content.title = "Su içme vakti! 💧"
        content.body = "Günlük su hedefine ulaşmak için bir bardak su içmeyi unutma."
        content.sound = .default

        // Her saat başı için ayrı bildirim oluştur (8-22 arası)
        var identifiers: [String] = []
        for hour in startHour..<endHour {
            let remainder = hour % (intervalMinutes / 60 == 0 ? 1 : intervalMinutes / 60)
            guard remainder == 0 || intervalMinutes < 60 else { continue }

            var components = DateComponents()
            components.hour = hour
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let id = "\(Identifier.waterReminder).\(hour)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request)
            identifiers.append(id)
        }
    }

    func cancelWaterReminder() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let waterIDs = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix(NotificationService.Identifier.waterReminder) }
            center.removePendingNotificationRequests(withIdentifiers: waterIDs)
        }
    }

    // MARK: - Habit Reminder
    func scheduleHabitReminder(habitID: String, habitName: String, hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        let id = Identifier.habitReminder(for: habitID)
        center.removePendingNotificationRequests(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        content.title = "Alışkanlık hatırlatıcısı ✅"
        content.body = "\"\(habitName)\" alışkanlığını bugün tamamladın mı?"
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelHabitReminder(habitID: String) {
        let id = Identifier.habitReminder(for: habitID)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    func cancelAllHabitReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let habitIDs = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix("com.pulse.habit.reminder.") }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: habitIDs)
        }
    }

    // MARK: - Morning Summary
    func scheduleMorningSummary(hour: Int = 8, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Identifier.morningSummary])

        let content = UNMutableNotificationContent()
        content.title = "Günaydın! ☀️"
        content.body = "Bugünün hedeflerini takip etmeye hazır mısın? Pulse seni bekliyor."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: Identifier.morningSummary,
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func cancelMorningSummary() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Identifier.morningSummary])
    }

    // MARK: - Cancel All
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
