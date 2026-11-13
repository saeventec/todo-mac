import Foundation

struct TodoStorage {
    let fileURL: URL

    static let appDefault = TodoStorage(
        fileURL: URL.applicationSupportDirectory.appending(path: "TodoApp/todos.json")
    )

    func load() throws -> [Todo] {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([Todo].self, from: data)
    }

    func save(_ todos: [Todo]) throws {
        try createFolderIfNeeded()
        let data = try JSONEncoder().encode(todos)
        try data.write(to: fileURL, options: .atomic)
    }

    private func createFolderIfNeeded() throws {
        let folder = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: folder,
            withIntermediateDirectories: true
        )
    }
}
