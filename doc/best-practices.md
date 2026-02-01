# Best Practices

To get the most out of the Air Framework and CLI, follow these best practices.

## Module Design

### 1. Granularity

Keep modules focused. A module should represent a specific domain or feature set (e.g., `Authentication`, `Checkout`, `Profile`). Avoid creating a monolithic `Common` module if possible; instead, use shared packages or core libraries.

### 2. Encapsulation

Modules should be as independent as possible.

- Avoid importing code from one module directly into another.
- Use the **Event Bus** or **Interfaces** for inter-module communication.

### 3. Folder Structure

Stick to the generated structure. It provides consistency for the entire team.

- **UI Code**: Goes in `ui/`.
- **Business Logic**: Goes in `services/`.
- **State Logic**: Goes in `ui/state/`.

## State Management

### 1. View Controllers vs Services

- Use `AirState` classes to control the View logic (what shows on the screen).
- Use `Service` classes for business logic (processing data, API calls) that is independent of the View.

### 2. Pulses and Flows

- **Pulses**: Should be actions. Naming: verbs (e.g., `login`, `fetchData`, `updateProfile`).
- **Flows**: Should be data states. Naming: nouns (e.g., `userProfile`, `isLoading`, `errorMessage`).

## CLI Usage

### 1. Use Generators

Always use `air generate` to create new files. This ensures:

- Correct boilerplate.
- Proper naming conventions.
- Registration in the right places (where applicable).

### 2. Use `air doctor`

Run `air doctor` periodically, especially after upgrading the CLI or changing dependencies, to ensure your environment is healthy.

### 3. Check for Updates

Update the CLI regularly to get new features and fixes.

```bash
dart pub global activate air_cli
```
