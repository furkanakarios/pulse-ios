import Foundation
import SwiftData

@Model
final class HealthNote {
    var id: UUID = UUID()
    var title: String = ""
    var content: String = ""
    var source: String = "Kişisel"
    var date: Date = Date.now

    init(title: String, content: String, source: String = "Kişisel", date: Date = .now) {
        self.title = title
        self.content = content
        self.source = source
        self.date = date
    }
}
