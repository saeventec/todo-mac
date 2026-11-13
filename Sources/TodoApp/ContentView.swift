import SwiftUI

struct ContentView: View {
    let store: TodoStore
    @State private var newTitle = ""

    var body: some View {
        VStack {
            addTodoRow
            todoList
        }
        .padding()
    }

    private var addTodoRow: some View {
        HStack {
            TextField("New todo", text: $newTitle)
                .onSubmit(addTodo)
            Button("Add", action: addTodo)
        }
    }

    private var todoList: some View {
        List(store.todos) { todo in
            TodoRow(
                todo: todo,
                onToggle: { store.toggle(todo) },
                onDelete: { store.delete(todo) }
            )
        }
    }

    private func addTodo() {
        store.add(title: newTitle)
        newTitle = ""
    }
}
