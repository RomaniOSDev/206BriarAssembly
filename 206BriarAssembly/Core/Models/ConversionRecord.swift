import Foundation

struct ConversionRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let fromZone: String
    let toZone: String
    let originalTime: String
    let convertedTime: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        fromZone: String,
        toZone: String,
        originalTime: String,
        convertedTime: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.fromZone = fromZone
        self.toZone = toZone
        self.originalTime = originalTime
        self.convertedTime = convertedTime
        self.createdAt = createdAt
    }
}
