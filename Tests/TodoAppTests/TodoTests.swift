import Testing

@testable import TodoApp

struct TodoTests {
    @Test func newTodoKeepsTitle() {
        let todo = Todo(title: "Buy milk")
        #expect(todo.title == "Buy milk")
    }

    @Test func newTodoIsNotDone() {
        let todo = Todo(title: "Buy milk")
        #expect(todo.isDone == false)
    }

    @Test func eachTodoHasUniqueID() {
        let first = Todo(title: "Buy milk")
        let second = Todo(title: "Buy milk")
        #expect(first.id != second.id)
    }
}
