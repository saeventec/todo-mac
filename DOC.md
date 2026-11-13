# Mac App Fundamentals

A reference for the fundamentals, structure and syntax behind this app. For commands, see [README.md](README.md).

## Contents

1. [The big picture](#1-the-big-picture)
2. [Tools](#2-tools)
3. [Terminal basics](#3-terminal-basics)
4. [Project files](#4-project-files)
5. [What a Mac app is](#5-what-a-mac-app-is)
6. [Swift basics](#6-swift-basics)
7. [SwiftUI](#7-swiftui)
8. [App architecture](#8-app-architecture)
9. [Saving data](#9-saving-data)
10. [Unit testing](#10-unit-testing)
11. [Best practices](#11-best-practices)

---

## 1. The big picture

```
Swift code (text)  ──compiler──▶  program (machine code)  ──packaged──▶  Todo.app
```

- **Code** is text that humans can read.
- The **compiler** turns code into a **program** the CPU can run.
- If you change the code, you have to compile again.
- A **Mac app** is a folder holding the program plus a file that describes it.

---

## 2. Tools

| Tool | What it is |
|---|---|
| **Swift** | Apple's programming language. |
| **swiftc** | The Swift compiler. |
| **Swift Package Manager (SwiftPM)** | The official way to build Swift projects without the Xcode app (`swift build`, `swift run`, `swift test`). |
| **macOS SDK** | Apple's built-in code (SwiftUI, Foundation, and so on). It comes with Xcode or the Command Line Tools. Only Apple ships it, so tools like mise can't install it. |
| **swift-format** | Apple's official style checker and fixer (`swift format`). |
| **codesign** | Signs an app so macOS trusts it. |

| Command | Shows |
|---|---|
| `swift --version` | The Swift version and your CPU type (`arm64` means an Apple chip) |
| `xcodebuild -version` | The Xcode version |
| `xcode-select -p` | Where your developer tools are installed |

---

## 3. Terminal basics

| Thing | Meaning |
|---|---|
| `swiftc main.swift -o hello` | Compile `main.swift` into a program. `-o` names the **o**utput. |
| `./hello` | Run the program in **this** folder. `./` means "here". |
| `-rwxr-xr-x` | File permissions. The `x` means "this file is allowed to run". |
| `chmod +x build.sh` | Give a file the `x` permission. |
| `open Todo.app` | Open something as if you double-clicked it in Finder. |
| `~` | Your home folder (`/Users/<you>`). |
| Files starting with `.` | Hidden files, like `.gitignore`. Use `ls -A` to see them. |

### A shell script (`build.sh`)

```bash
#!/bin/bash              # run this file with bash
set -euo pipefail        # stop right away if any command fails

APP_DIR="build/Todo.app" # variable (CAPS by convention), read as $APP_DIR

create_bundle() {        # a function: a named group of commands
  rm -rf "$APP_DIR"              # delete (recursive, no questions asked)
  mkdir -p "$APP_DIR/Contents"   # make folders (-p = parent folders too)
}

main() {                 # one main function that runs the steps in order
  create_bundle
}

main                     # call it
```

Other commands in it: `cp` copies a file, `echo` prints text, and `swift build --configuration release` makes a release build.

---

## 4. Project files

```
todo-app/
├── README.md              ← what this is + commands
├── DOC.md                 ← this reference
├── .gitignore             ← files Git should skip
├── .swift-format          ← style rules
├── Package.swift          ← describes the project
├── Info.plist             ← the app's ID card
├── build.sh               ← builds build/Todo.app
├── Sources/TodoApp/
│   ├── TodoApp.swift      ← app starts here
│   ├── Todo.swift         ← data: one todo
│   ├── TodoStore.swift    ← logic: add / toggle / delete / save
│   ├── TodoStorage.swift  ← files: read / write JSON
│   ├── ContentView.swift  ← main screen
│   └── TodoRow.swift      ← one row
└── Tests/TodoAppTests/
    ├── TodoTests.swift
    ├── TodoStoreTests.swift
    ├── TodoStorageTests.swift
    └── TestHelpers.swift
```

**Generated folders** (never edit them, and delete them anytime):
- `.build/` is SwiftPM's build output.
- `build/` holds the app made by `build.sh`.

### Package.swift

```swift
// swift-tools-version: 6.4          ← required first line: SwiftPM version
import PackageDescription

let package = Package(
    name: "TodoApp",
    platforms: [.macOS(.v27)],       // minimum macOS
    targets: [
        .executableTarget(name: "TodoApp"),       // builds the app from Sources/TodoApp/
        .testTarget(
            name: "TodoAppTests",                 // builds tests from Tests/TodoAppTests/
            dependencies: ["TodoApp"]             // the code these tests use
        ),
    ]
)
```

A **target** is one thing to build. Folder names must match the target names.

### .swift-format

```json
{
  "version": 1,
  "indentation": { "spaces": 4 }
}
```

`version` is required. Every rule not listed here keeps its default, for example a maximum line length of 100.

### .gitignore

Each line is a file or folder Git should skip. We skip generated folders (`.build/`, `build/`), macOS junk files (`.DS_Store`) and editor settings (`.vscode/`).

---

## 5. What a Mac app is

A `.app` is just a **folder**. Finder shows it as a single icon.

```
Todo.app/
└── Contents/
    ├── Info.plist          ← describes the app
    ├── MacOS/TodoApp       ← the program
    └── _CodeSignature/     ← fingerprints of every file
```

### Info.plist

A list of key → value pairs, written in XML. The first 3 lines are a standard header that never changes.

| Key | Meaning |
|---|---|
| `CFBundleExecutable` | Which program in `MacOS/` to run |
| `CFBundleIdentifier` | The unique ID, written as a reversed web address (`com.sadra.todo`) |
| `CFBundleName` | The name shown in the menu bar |
| `CFBundlePackageType` | `APPL` means "application" |
| `CFBundleShortVersionString` | The version users see (1.0) |
| `CFBundleVersion` | The build number. Increase it with every release. |
| `LSMinimumSystemVersion` | The oldest macOS the app supports |

`CF` (Core Foundation) and `LS` (Launch Services) are old Apple system names that the keys still use.

### Code signing

- macOS requires apps to be signed.
- The signature lists every file with a fingerprint. If a file changes, macOS refuses to run the app.
- `codesign --force --sign -` makes an **ad-hoc** signature: free, and it works only on your Mac.
- Sharing the app with other people needs a paid Apple certificate.

### Debug vs release

| | Debug | Release |
|---|---|---|
| Used by | `swift build`, `swift run`, `swift test` | `build.sh` |
| Builds | Fast | Slower |
| Runs | Slower, easy to debug | Fast and small |

### `swift run` vs `Todo.app`

`swift run` starts just the program, so it's missing from the Dock and may open behind other windows. A real `.app` folder with an `Info.plist` behaves like a normal Mac app.

### Two ways to build an app

| Way | Notes |
|---|---|
| **SwiftPM + build script** (ours) | Small, and you understand everything. Not the usual way, so icons and permissions mean manual work. |
| **Xcode project** (the standard) | Since Xcode 27.2 the project file is readable JSON (`project.xcproj`). It creates the Info.plist for you, and you can build from the terminal with `xcodebuild`. |

---

## 6. Swift basics

### A Swift file

```swift
import Foundation          // load a framework (ready-made code)

struct Todo {              // define a type
    // ...                 // a comment: ignored by the compiler
}
```

The program starts at `@main`. The exception is a file named `main.swift`, which runs from top to bottom.

### Values

```swift
let name = "Milk"      // let = never changes (use this by default)
var count = 0          // var = can change
```

Swift usually figures out the type for you. You can also write it: `var title: String`.

### Common types

| Type | Example |
|---|---|
| `String` (text) | `"Buy milk"` |
| `Bool` (true or false) | `true` |
| `Int` (whole number) | `42` |
| `[Todo]` (array: an ordered list) | `[milk, eggs]` |
| `UUID` (random unique ID) | `UUID()` |
| `URL` (a file path or web address) | `URL.temporaryDirectory` |
| `Data` (raw bytes, for example file contents) | `Data(contentsOf: url)` |

### Working with arrays and strings

| Code | Does |
|---|---|
| `todos.append(todo)` | Add to the end |
| `todos.count` | How many items |
| `todos.isEmpty` | `true` if there are no items |
| `todos.first` | The first item, or `nil` if the list is empty |
| `todos[2]` | The item at position 2 (counting starts at 0) |
| `todos.firstIndex { ... }` | The position of the first match, or `nil` |
| `todos.removeAll { ... }` | Remove every item that matches |
| `isDone.toggle()` | Flip `true` ↔ `false` |
| `title.trimmingCharacters(in: .whitespaces)` | Remove spaces at the start and end |
| `"\(value)"` | Put a value inside a string |

### Struct vs class

The difference is what happens when you pass it to someone.

| | Behaves like | Use for |
|---|---|---|
| `struct` | A **photocopy**: each person gets their own copy | Small data (`Todo`). Use it by default. |
| `class` | A **shared link**: everyone sees the same thing | One shared thing (`TodoStore`) |

```swift
var a = Todo(title: "Milk")
var b = a            // copy
b.title = "Eggs"     // a.title is still "Milk"

let x = TodoStore()
let y = x            // same store
y.add(title: "Eggs") // x sees it too
```

Write `final class` so nobody can subclass it. That's the best-practice default.

### Properties

```swift
let id: UUID                    // stored property: a field
var checkmarkIcon: String {     // computed property: calculated each time it's read
    todo.isDone ? "checkmark.circle.fill" : "circle"
}
static let appDefault = ...     // static: belongs to the type, used as TodoStorage.appDefault
```

### Initializer (`init`)

The function that creates a new value.

```swift
init(title: String) {
    id = UUID()
    self.title = title   // self.title = my field, title = the value passed in
    isDone = false
}
```

Parameters can have default values: `init(todos: [Todo] = [])` lets you call either `TodoStore()` or `TodoStore(todos: [...])`.

### Functions

```swift
func add(title: String) { ... }       // call: store.add(title: "Milk")
func toggle(_ todo: Todo) { ... }     // _ = no label. Call: store.toggle(todo)
func index(of todo: Todo) -> Int? {   // -> = what it returns
    todos.firstIndex { item in item.id == todo.id }  // one line = returned automatically
}
```

### Access control

| Keyword | Who can use it |
|---|---|
| (nothing) = `internal` | Any code in the same target |
| `private` | Only code inside this type |

Hide what others don't need. Tests use `@testable import` to see `internal` code.

### Protocols

A **protocol** is a list of rules a type promises to follow. `struct Todo: Identifiable` means "Todo follows the Identifiable rules".

| Protocol | Promise |
|---|---|
| `Identifiable` | Has a unique `id`. SwiftUI lists need this. |
| `Codable` | Can be turned into JSON and back. |
| `Equatable` | Can be compared with `==`. |
| `App` | Is an app. |
| `View` | Is a piece of screen. |

### Optionals: "maybe nothing"

A type with `?` might hold no value (`nil`).

| Syntax | Meaning |
|---|---|
| `Int?` | An Int, or nothing |
| `todos.first?.title` | The title, or `nil` if the list is empty |
| `guard let x = maybe else { return }` | If there's a value, call it `x` and continue. Otherwise leave. |
| `value ?? []` | If it's `nil`, use `[]` instead |
| `storage?.save(...)` | Only runs if `storage` isn't `nil` |
| `value!` | **Force unwrap**: crashes if `nil`. **Avoid.** |

`!` *before* a value means "not" (`!isEmpty`), and that's fine to use.

### Errors

| Syntax | Meaning |
|---|---|
| `func load() throws` | This function can fail |
| `try load()` | Required before anything that can fail |
| `try? load()` | If it fails, give `nil` instead of an error |

### Closures

A **closure** is a small piece of code you pass around and run later.

```swift
todos.removeAll { item in item.id == todo.id }   // "item in" names the input
Button("Add") { store.add(title: newTitle) }     // runs on click
let onDelete: () -> Void                         // type: takes nothing, returns nothing
```

### Control flow

| Syntax | Meaning |
|---|---|
| `guard condition else { return }` | Check, or leave early |
| `a ? b : c` | Short if/else: if `a`, then `b`, otherwise `c` |
| `defer { ... }` | Run this when the function ends, no matter how it ends |

### Other syntax

| Syntax | Meaning |
|---|---|
| `some View` | "Some kind of View". Swift works out the exact type. |
| `[Todo].self` | The type itself, not a value (used by `decode`) |
| `@Something` | An **attribute**: adds a special behavior (`@main`, `@State`, `@Test`) |
| `#expect(...)` | A **macro**: code that writes more code for you |

---

## 7. SwiftUI

You **describe** what the screen should look like, and SwiftUI draws it.

### The tree

```
App  →  Scene (window)  →  Views (text, buttons, lists)
```

```swift
@main                          // app starts here
struct TodoApp: App {
    var body: some Scene {     // body = what this contains
        WindowGroup {          // a window
            ContentView(...)   // what's inside
        }
    }
}
```

Every `App` has a `body` of scenes, and every `View` has a `body` of views. `ContentView` is the conventional name for the main view.

### Views we used

| View | What it shows |
|---|---|
| `Text("Hi")` | Text |
| `TextField("Hint", text: $value)` | A text box. The hint is the grey text shown when it's empty. |
| `Button("Add", action: addTodo)` | A button |
| `Button("Delete", systemImage: "trash") { ... }` | A button with an icon |
| `List(items) { item in ... }` | One row per item |
| `VStack` / `HStack` | Stack views vertically / horizontally |
| `Spacer()` | Empty space that pushes things apart |

### Modifiers

They change a view and are chained with a dot:

| Modifier | Does |
|---|---|
| `.padding()` | Adds space around the view |
| `.strikethrough(isDone)` | Draws a line through the text |
| `.onSubmit(addTodo)` | Runs when Return is pressed |
| `.labelStyle(.iconOnly)` | Shows only the icon. VoiceOver (the screen reader for blind users) still reads the text. |
| `.buttonStyle(.plain)` | A button with no background |

### Icons

**SF Symbols** are thousands of free Apple icons, picked by name: `"trash"`, `"circle"`, `"checkmark.circle.fill"`.

### State and data flow

| Tool | Meaning |
|---|---|
| `@State` | Keeps a value alive while the view (or app) exists |
| `@Observable` | When this class's data changes, screens showing it redraw by themselves |
| `$value` | **Binding**: a two-way link (typing updates the variable, and the variable updates the box) |

### Breaking up a screen

- Split a long `body` into named pieces with computed properties: `private var addTodoRow: some View`.
- Move a piece into its own view once it grows (`TodoRow`).
- Small views get **data in** and send **events out**:

```swift
TodoRow(
    todo: todo,                          // data in
    onToggle: { store.toggle(todo) },    // events out
    onDelete: { store.delete(todo) }
)
```

---

## 8. App architecture

```
ContentView / TodoRow   →  UI: shows things, forwards clicks
        ↓
TodoStore               →  logic: rules (add, toggle, delete)
        ↓
TodoStorage             →  files: read/write JSON
        ↓
Todo                    →  data: one todo
```

**Why split it up?**
- Logic is easy to test, and UI is hard to test, so keep the logic out of the views.
- Each type has **one job**.
- **Pass dependencies in** instead of creating them inside: `TodoStore(storage: ...)`. Tests can then pass in a temporary storage.
- Match items by `id`, never by title. Two todos can share a title.

---

## 9. Saving data

- **JSON** is a simple text format for data: `[{"id":"…","title":"Buy milk","isDone":false}]`
- `Codable` plus `JSONEncoder` / `JSONDecoder` convert between your types and JSON.
- `Data(contentsOf: url)` reads a file, and `data.write(to: url)` writes one.
- `.atomic` writes to a temporary file first, then swaps it in. A crash can't leave half a file.
- `FileManager.default.createDirectory(...)` creates folders.
- `url.appending(path:)` and `url.deletingLastPathComponent()` build file paths.
- App data goes in **`~/Library/Application Support/<AppName>/`**. That's Apple's standard place.

---

## 10. Unit testing

A **unit test** is code that checks your other code automatically. Run them with `swift test`.

```swift
import Testing                 // Apple's modern test framework (Swift Testing)
@testable import TodoApp       // load app code, including internal parts

struct TodoStoreTests {        // a group of tests: <Thing>Tests
    @Test func addTrimsSpaces() {
        let store = TodoStore()               // Arrange
        store.add(title: "  Buy milk  ")      // Act
        #expect(store.todos.first?.title == "Buy milk")  // Check
    }
}
```

| Tool | Meaning |
|---|---|
| `@Test` | Marks a function as a test |
| `#expect(condition)` | Fails the test if the condition is false, and shows both values |
| `#expect(throws: (any Error).self) { ... }` | Passes only if the code throws an error |
| `@Test func x() throws` | The test fails automatically if anything inside it throws |

The output may also say `Executed 0 tests`. That line comes from the older framework, XCTest, and you can ignore it.

**Best practices:**
- Name tests like sentences: `deleteKeepsOtherTodos`.
- Check one thing per test.
- Follow **Arrange → Act → Check**.
- Test what should change **and** what shouldn't.
- Never touch real user data. Use temporary files, and clean up with `defer`.
- Put shared test code in a helper file (`TestHelpers.swift`).
- After changing code, run the tests. If they pass, you didn't break anything (this is **refactoring safely**).

---

## 11. Best practices

### Naming (Apple's API Design Guidelines)

| Rule | Example |
|---|---|
| Types use `UpperCamelCase` | `TodoStore` |
| Functions and variables use `lowerCamelCase` | `addTodo`, `newTitle` |
| Booleans read like questions | `isDone` |
| Calls read like English | `store.add(title:)`, `store.toggle(todo)` |
| Clear beats short | `deleteFile(of:)`, not `delF` |

### Code

- `let` by default, `struct` by default.
- One main type per file, and the file is named after it.
- Small functions with one job each.
- Use `guard` to leave early instead of nesting `if`s.
- Avoid force unwrap `!`.
- Use `private` for anything other code doesn't need.
- Keep logic out of views.

### Style

- Store style rules in `.swift-format`. Ours sets 4-space indentation.
- **Lint** (`swift format lint`) only reports problems. **Format** (`swift format --in-place`) fixes them.
- Keep lines under 100 characters. When a call gets long, put one argument per line.
