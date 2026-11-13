import Testing

@testable import TodoApp

struct TodoStoreTests {
    @Test func startsEmptyByDefault() {
        let store = TodoStore()
        #expect(store.todos.isEmpty)
    }

    @Test func keepsGivenTodos() {
        let store = TodoStore(todos: [Todo(title: "Buy milk")])
        #expect(store.todos.count == 1)
    }

    @Test func addAppendsTodo() {
        let store = TodoStore()
        store.add(title: "Buy milk")
        #expect(store.todos.first?.title == "Buy milk")
    }

    @Test func addTrimsSpaces() {
        let store = TodoStore()
        store.add(title: "  Buy milk  ")
        #expect(store.todos.first?.title == "Buy milk")
    }

    @Test func addIgnoresEmptyTitle() {
        let store = TodoStore()
        store.add(title: "   ")
        #expect(store.todos.isEmpty)
    }

    @Test func toggleMarksTodoDone() {
        let todo = Todo(title: "Buy milk")
        let store = TodoStore(todos: [todo])
        store.toggle(todo)
        #expect(store.todos.first?.isDone == true)
    }

    @Test func toggleTwiceMarksTodoNotDone() {
        let todo = Todo(title: "Buy milk")
        let store = TodoStore(todos: [todo])
        store.toggle(todo)
        store.toggle(todo)
        #expect(store.todos.first?.isDone == false)
    }

    @Test func deleteRemovesTodo() {
        let todo = Todo(title: "Buy milk")
        let store = TodoStore(todos: [todo])
        store.delete(todo)
        #expect(store.todos.isEmpty)
    }

    @Test func deleteKeepsOtherTodos() {
        let milk = Todo(title: "Buy milk")
        let eggs = Todo(title: "Buy eggs")
        let store = TodoStore(todos: [milk, eggs])
        store.delete(milk)
        #expect(store.todos.first?.title == "Buy eggs")
    }

    @Test func addSavesToStorage() throws {
        let storage = makeTemporaryStorage()
        defer { deleteFile(of: storage) }
        let store = TodoStore(storage: storage)
        store.add(title: "Buy milk")
        #expect(try storage.load().first?.title == "Buy milk")
    }

    @Test func loadedReadsSavedTodos() throws {
        let storage = makeTemporaryStorage()
        defer { deleteFile(of: storage) }
        try storage.save([Todo(title: "Buy milk")])
        let store = TodoStore.loaded(from: storage)
        #expect(store.todos.first?.title == "Buy milk")
    }
}
