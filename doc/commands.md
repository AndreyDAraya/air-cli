# Commands Reference

Here is a complete list of commands available in the Air CLI.

## `air create`

Creates a new Air Framework project with the necessary structure and dependencies.

**Usage:**

```bash
air create <project_name> [options]
```

**Options:**

- `--org <domain>`: The organization domain (e.g., `com.company`). Default: `com.example`.
- `--template <name>`: The template to use. options: `blank`, `starter`. Default: `blank`.

**Example:**

```bash
air create super_shop --org com.supershop --template starter
```

---

## `air generate` (alias: `g`)

Generates new components within your project. This is the primary tool for expanding your application.

**Usage:**

```bash
air generate <type> <name> [options]
```

### Types

#### `module` (alias: `m`)

Creates a new feature module with the standard directory structure.

```bash
air g module <name>
```

#### `screen` (alias: `page`, `view`, `s`, `p`, `v`)

Creates a new UI screen/page.

```bash
air g screen <name> --module <module_name>
```

#### `service` (alias: `svc`)

Creates a business logic service class.

```bash
air g service <name> --module <module_name>
```

#### `state` (alias: `st`)

Creates an AirState controller (state management).

```bash
air g state <name> --module <module_name>
```

#### `model` (alias: `mod`)

Creates a data model class.

```bash
air g model <name> --module <module_name>
```

_Use `--core` flag instead of `--module` to generate a shared core model._

#### `widget` (alias: `w`)

Creates a reusable widget.

```bash
air g widget <name> --module <module_name>
```

---

## `air module`

Manages external or shared modules.

### `add`

Adds an existing module from a remote Git repository or a local path.

**Usage:**

```bash
air module add <source>
```

**Examples:**

- **From Git:**
  ```bash
  air module add https://github.com/my-org/auth-module.git
  ```
- **From Local Path:**
  ```bash
  air module add /path/to/local/auth-module
  ```

This command:

1.  Clones/Copies the module into `lib/modules/`.
2.  Syncs dependencies from the module's `pubspec.yaml` to your main project.
3.  Runs `flutter pub get`.

---

## `air doctor`

Checks your environment and project configuration for potential issues.

**Usage:**

```bash
air doctor
```

**Checks performed:**

- Flutter and Dart installation.
- Project structure validity (is it an Air project?).
- Missing required dependencies in `pubspec.yaml`.
- Validates existence of `lib/modules`.
