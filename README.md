# Todo

A simple macOS todo app, written in Swift and SwiftUI without Xcode templates.

To learn how it works, read [DOC.md](DOC.md).

## Requirements

- macOS 27+
- Swift 6.4+ (comes with Xcode or the Command Line Tools)

## Commands

```bash
swift test                 # run the tests
./build.sh                 # build build/Todo.app
open build/Todo.app        # launch the app
```

```bash
swift format lint --recursive Sources Tests          # check style
swift format --in-place --recursive Sources Tests    # fix style
```

## Data

Todos are saved to `~/Library/Application Support/TodoApp/todos.json`.
