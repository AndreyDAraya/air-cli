# Installation Guide

Setting up the Air Framework CLI is straightforward. Follow these steps to get up and running.

## Prerequisites

Before installing the Air CLI, ensure you have the following installed on your system:

- **Flutter SDK**: [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK**: Included with Flutter.
- **Git**: Required for fetching modules.

## Installing the CLI

### Option 1: Activate from Path (Local Development)

If you have cloned the repository locally:

```bash
dart pub global activate --source path /path/to/air-cli
```

### Option 2: Activate from Git (Recommended)

To install the latest version directly from the repository:

```bash
dart pub global activate --source git https://github.com/your-username/air-cli.git
```

_(Replace with the actual repository URL)_

## Verifying Installation

To ensure the CLI is installed correctly, run:

```bash
air --help
```

You should see the list of available commands.

## Troubleshooting

### "command not found: air"

If you see this error, ensure that the Pub cache bin directory is in your system's `PATH`.

- **macOS/Linux**: Add the following to your shell configuration file (`.zshrc`, `.bashrc`, etc.):
  ```bash
  export PATH="$PATH":"$HOME/.pub-cache/bin"
  ```
- **Windows**: Add `%APPDATA%\Pub\Cache\bin` to your Path environment variable.

### Checking Configuration

Run the doctor command to verify your environment:

```bash
air doctor
```

This will check for:

- Flutter and Dart installation
- Project structure (if inside a project)
- Dependencies
- Common configuration issues
