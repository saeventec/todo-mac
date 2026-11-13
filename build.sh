#!/bin/bash
# Builds build/Todo.app from the Swift package.
set -euo pipefail

APP_NAME="Todo"
EXECUTABLE="TodoApp"
APP_DIR="build/${APP_NAME}.app"

build_executable() {
  swift build --configuration release
}

create_bundle() {
  rm -rf "$APP_DIR"
  mkdir -p "$APP_DIR/Contents/MacOS"
}

copy_files() {
  cp ".build/release/$EXECUTABLE" "$APP_DIR/Contents/MacOS/"
  cp Info.plist "$APP_DIR/Contents/"
}

sign_app() {
  codesign --force --sign - "$APP_DIR"
}

main() {
  build_executable
  create_bundle
  copy_files
  sign_app
  echo "Built $APP_DIR"
}

main
