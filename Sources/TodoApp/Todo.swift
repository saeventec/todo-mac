import Foundation

struct Todo: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isDone: Bool

    init(title: String) {
        id = UUID()
        self.title = title
        isDone = false
    }
}
