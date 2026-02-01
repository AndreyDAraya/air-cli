# Air CLI

[![pub package](https://img.shields.io/pub/v/air_cli.svg)](https://pub.dev/packages/air_cli)
[![publisher](https://img.shields.io/pub/publisher/air_cli.svg)](https://pub.dev/packages/air_cli)
[![coverage](https://img.shields.io/badge/coverage-100%25-success)](https://github.com/your_username/air_cli)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

```text
   ___    ____  ____       ______   __    ____
  /   |  /  _/ / __ \     / ____/  / /   /  _/
 / /| |  / /  / /_/ /    / /      / /    / /
/ ___ |_/ /  / _, _/    / /___   / /___ _/ /
/_/  |_/___/ /_/ |_|     \____/  /_____//___/
```

**The official Command Line Interface for the Air Framework.**

Build scalable, testable, and modular Flutter applications with ease. The Air CLI automates the tedious parts of development, letting you focus on building features that matter.

## 🚀 Features

- **Modular Architecture**: Generate independent, reusable modules with a single command.
- **State Management**: Scaffolds the powerful `AirState` pattern (State + Pulses + Flows).
- **Dependency Injection**: Automatic setup of services and bindings.
- **Templates**: Start with a `blank` canvas or a full `starter` app with authentication.
- **100% Test Coverage**: The CLI itself is rigorously tested to ensure rock-solid reliability.

## 📦 Installation

Activate the CLI globally using Dart:

```bash
dart pub global activate air_cli
```

## 🛠 Usage

```bash
air <command> [arguments]
```

### 🆕 Create Project

Initialize a new Air Framework project with best practices built-in.

```bash
air create <project_name> --org=com.example --template=starter
```

| Option       | Description                                           |
| ------------ | ----------------------------------------------------- |
| `--template` | `blank` (default) or `starter` (includes Auth module) |
| `--org`      | Organization identifier (e.g., `com.company`)         |

### ✨ Generate Code

Rapidly scaffold components. Run this command from the root of your project.

```bash
air generate <type> <name> [options]
# Alias: air g
```

#### Generators

| Type        | Command                | Description                                                                       |
| ----------- | ---------------------- | --------------------------------------------------------------------------------- |
| **Module**  | `air g module <name>`  | Creates a new feature module with routing and DI. Add `--all` for full structure. |
| **Screen**  | `air g screen <name>`  | Generates a Page widget. Requires `--module`.                                     |
| **State**   | `air g state <name>`   | Generates AirState, Pulses, and Flows. Requires `--module`.                       |
| **Service** | `air g service <name>` | Generates a Service class. Requires `--module`.                                   |
| **Model**   | `air g model <name>`   | Generates a Data Model. Use `--core` or `--module`.                               |
| **Widget**  | `air g widget <name>`  | Generates a reusable UI Widget. Requires `--module`.                              |

**Examples:**

```bash
air g module products --all
air g screen product_detail --module=products
air g state cart --module=products
```

### 🧩 Module Management

Easily add Modules to your project.

```bash
# Add from a Git repository
air module add https://github.com/user/air_module_auth.git

# Add from a local path
air module add /path/to/local/module
```

### 🩺 Doctor

Diagnose your environment and project configuration.

```bash
air doctor
```

## 🏗 Architecture

Air Framework promotes a clear separation of concerns:

- **Modules**: Self-contained units of functionality (e.g., Auth, Home, Settings).
- **UI (Views)**: Flutter widgets that react to state changes.
- **State (AirState)**: Business logic using Flows (Data) and Pulses (Events).
- **Services**: Pure Dart classes for API calls, Database, etc.

## 🧪 Reliability

We take quality seriously. The Air CLI is maintained with **100% Unit Test Coverage**, ensuring that every command and generator works exactly as expected.

## 📄 License

MIT © 2026 Air Framework
