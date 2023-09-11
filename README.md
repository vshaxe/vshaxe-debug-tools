# Haxe Extension Debug Tools

[![CI](https://img.shields.io/github/workflow/status/vshaxe/vshaxe-debug-tools/CI.svg?logo=github)](https://github.com/vshaxe/vshaxe-debug-tools/actions?query=workflow%3ACI)

This is a VSCode extension that exists solely to aid the development of the [vshaxe](https://github.com/vshaxe/vshaxe) extension.

## Features

- **haxe-formatter test file highlighting**

  [haxe-formatter](https://github.com/vshaxe/haxe-formatter) uses a custom `.hxtest` file extension for unit test definitions. These files are highlighted by the debug tools:

  ![](images/hxtest.png)

- **Cursor Byte Offset Status Bar Item**

  ![](images/cursorByteOffset.png)

  The debug tools add a status bar item displaying the current cursor byte offset when in a Haxe file. Haxe `--display` queries require the cursor byte offset as an argument, making this feature very useful when isolating and reproducing bugs.

## Installation

1. Navigate to the extensions folder (`C:\Users\<username>\.vscode\extensions` on Windows, `~/.vscode/extensions` otherwise)
2. Clone this repo: `git clone --recursive https://github.com/vshaxe/vshaxe-debug-tools`.
3. Change current directory to the cloned one: `cd vshaxe-debug-tools`.
4. Install the dependencies: `npm install`
5. To build everything:

    ```
    npx lix run vshaxe-build --target all
    ```

6. After modifying and rebuilding the extension itself, restart VSCode, reload the window or run a debug instance with F5 ([standard vscode workflow](https://code.visualstudio.com/docs/extensions/debugging-extensions)).
