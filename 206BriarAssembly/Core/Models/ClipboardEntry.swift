import Foundation

struct ClipboardEntry: Codable, Identifiable, Equatable {
    let id: UUID
    var text: String
    let savedAt: Date
    var tag: String

    init(id: UUID = UUID(), text: String, savedAt: Date = Date(), tag: String = "General") {
        self.id = id
        self.text = text
        self.savedAt = savedAt
        self.tag = tag
    }

    enum CodingKeys: String, CodingKey {
        case id, text, savedAt, tag
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        savedAt = try container.decode(Date.self, forKey: .savedAt)
        tag = try container.decodeIfPresent(String.self, forKey: .tag) ?? "General"
    }
}
