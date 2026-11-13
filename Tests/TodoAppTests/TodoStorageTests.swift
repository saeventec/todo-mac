import Testing

@testable import TodoApp

struct TodoStorageTests {
    @Test func saveThenLoadReturnsSameTodos() throws {
        let storage = makeTemporaryStorage()
        defer { deleteFile(of: storage) }
        let todos = [Todo(title: "Buy milk")]
        try storage.save(todos)
        #expect(try storage.load() == todos)
    }

    @Test func loadMissingFileThrows() {
        let storage = makeTemporaryStorage()
        #expect(throws: (any Error).self) { try storage.load() }
    }
}
