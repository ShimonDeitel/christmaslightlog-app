import Foundation

struct StrandEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var condition: String
    var storageBin: String
    var notes: String

    init(id: UUID = UUID(), createdAt: Date = Date(), condition: String = "", storageBin: String = "", notes: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.condition = condition
        self.storageBin = storageBin
        self.notes = notes
    }
}
