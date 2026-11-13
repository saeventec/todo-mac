import Foundation

@testable import TodoApp

func makeTemporaryStorage() -> TodoStorage {
    let fileURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).json")
    return TodoStorage(fileURL: fileURL)
}

func deleteFile(of storage: TodoStorage) {
    try? FileManager.default.removeItem(at: storage.fileURL)
}
