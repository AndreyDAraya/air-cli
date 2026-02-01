# Getting Started

This guide will walk you through creating your first Air Framework project.

## 1. Create a New Project

Use the `create` command to generate a new project with the standard structure.

```bash
air create my_awesome_app --org com.mycompany
```

Arguments:

- `<name>`: The name of your project (snake_case).
- `--org`: (Optional) The organization domain (reverse domain notation). Default is `com.example`.
- `--template`: (Optional) Choose a starting template (`blank` or `starter`). Default is `blank`.

## 2. Explore the Structure

Navigate into your new project:

```bash
cd my_awesome_app
```

You will see a structure designed for scalability:

```text
lib/
├── main.dart           # Application entry point
├── app.dart            # Main App widget and configuration
└── modules/            # Directory for all feature modules
```

## 3. Run the App

Install dependencies and run the app:

```bash
flutter pub get
flutter run
```

## 4. Generate a Module

Let's say we want to add a "Products" feature. We can generate a module for it:

```bash
air generate module products
```

This creates `lib/modules/products/` with the standard internal structure (pages, widgets, services, state, models).

## 5. Generate a Screen

Now, let's add a "Product Details" screen to our new module:

```bash
air generate screen product_details --module products
```

This creates:

- `lib/modules/products/pages/product_details_page.dart`
- Updates the module routing (if applicable).

## Next Steps

- Learn more about available [Commands](commands.md).
- Understand the [Architecture](architecture.md).
