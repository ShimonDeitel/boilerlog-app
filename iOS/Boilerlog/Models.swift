import Foundation

struct BoilerEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var pressureBar: Double = 1.2
    var bled: Bool = false
    var date: Date = Date()
    var notes: String = ""
}
