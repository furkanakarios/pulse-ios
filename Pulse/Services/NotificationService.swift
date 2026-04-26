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
    func scheduleWaterReminder(intervalMinutes: Int, startHour: Int = 8, endHour: Int = 22) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let waterIDs = requests.map { $0.identifier }.filter { $0.hasPrefix(Identifier.waterReminder) }
            center.removePendingNotificationRequests(withIdentifiers: waterIDs)
        }

        let content = UNMutableNotificationContent()
        content.title = "Su içme vakti! 💧"
        content.body = "Günlük su hedefine ulaşmak için bir bardak su içmeyi unutma."
        content.sound = .default

        // startHour:00'dan intervalMinutes adımlarla endHour:00'a kadar tüm saatleri oluştur
        // Örn: 30dk → 08:00, 08:30, 09:00, ... | 60dk → 08:00, 09:00, ... | 120dk → 08:00, 10:00, ...
        var currentMinutes = startHour * 60
        let endMinutes = endHour * 60
        while currentMinutes < endMinutes {
            let hour = currentMinutes / 60
            let minute = currentMinutes % 60
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let id = "\(Identifier.waterReminder).\(hour).\(minute)"
            center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
            currentMinutes += intervalMinutes
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
