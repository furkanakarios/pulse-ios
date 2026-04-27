import Foundation
import SwiftData

@Model
final class Achievement {
    var key: String = ""
    var unlockedAt: Date? = nil
    /// Son bildirim gönderildiğindeki progress adımı — tekrar bildirimi önlemek için
    var notifiedProgress: Int = 0

    init(key: String) {
        self.key = key
    }

    var isUnlocked: Bool { unlockedAt != nil }
}
