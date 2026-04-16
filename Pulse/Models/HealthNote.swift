import Foundation
import SwiftData

@Model
final class HealthNote {
    var id: UUID
    var title: String
    var content: String
    var source: String // "Doktor", "Diyetisyen", "Kişisel" vb.
    var date: Date

    init(title: String, content: String, source: String = "Kişisel", date: Date = .now) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.source = source
        self.date = date
    }
}
