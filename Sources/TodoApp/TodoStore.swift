import Foundation
import Observation

@Observable
final class TodoStore {
    var todos: [Todo]
    private let storage: TodoStorage?

    init(todos: [Todo] = [], storage: TodoStorage? = nil) {
        self.todos = todos
        self.storage = storage
    }

    static func loaded(from storage: TodoStorage) -> TodoStore {
        let todos = (try? storage.load()) ?? []
        return TodoStore(todos: todos, storage: storage)
    }

    func add(title: String) {
        let cleanTitle = title.trimmingCharacters(in: .whitespaces)
        guard !cleanTitle.isEmpty else { return }
        todos.append(Todo(title: cleanTitle))
        save()
    }

    func toggle(_ todo: Todo) {
        guard let index = index(of: todo) else { return }
        todos[index].isDone.toggle()
        save()
    }

    func delete(_ todo: Todo) {
        todos.removeAll { item in item.id == todo.id }
        save()
    }

    private func index(of todo: Todo) -> Int? {
        todos.firstIndex { item in item.id == todo.id }
    }

    private func save() {
        try? storage?.save(todos)
    }
}
