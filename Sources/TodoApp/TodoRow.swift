import SwiftUI

struct TodoRow: View {
    let todo: Todo
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Button("Toggle", systemImage: checkmarkIcon, action: onToggle)
            Text(todo.title)
                .strikethrough(todo.isDone)
            Spacer()
            Button("Delete", systemImage: "trash", action: onDelete)
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.plain)
    }

    private var checkmarkIcon: String {
        todo.isDone ? "checkmark.circle.fill" : "circle"
    }
}
