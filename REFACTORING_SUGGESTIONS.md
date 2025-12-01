# Refactoring Report & Suggestions

## Executive Summary
The codebase is functional but exhibits signs of rapid development, leading to technical debt. The primary issues are **tight coupling** between UI and data logic, **inconsistent state management**, and **lack of a unified data model**. Refactoring will improve maintainability, testability, and scalability.

## 1. Architecture & Design Patterns

### Current State
*   **Logic in UI**: `InventoryScreen` contains significant business logic (fetching data, parsing JSON, calling Cloud Functions).
*   **Direct Service Instantiation**: Services like `InventoryService` are instantiated directly in widgets (`final _inventoryService = InventoryService();`), making testing difficult.
*   **Inconsistent Data Access**: `InventoryService` uses a "Household" model, while `ShoppingService` uses a "User" sub-collection model.

### Suggestions
*   **Adopt MVVM (Model-View-ViewModel)**:
    *   **Models**: Create strong Dart objects for `InventoryItem`, `Batch`, `ShoppingItem`. Stop passing `Map<String, dynamic>` around.
    *   **Repositories**: Abstract Firestore calls behind repositories (e.g., `InventoryRepository`). This allows for easier swapping of data sources and testing.
    *   **ViewModels (Providers)**: Move logic from `InventoryScreen` to `InventoryViewModel` (extending `ChangeNotifier`). The UI should only listen to state changes.
*   **Dependency Injection**: Use `Provider` (or `get_it`) to inject services/repositories into ViewModels.

## 2. Code Quality & Clean Code

### Current State
*   **Large Files**: `InventoryScreen.dart` is nearly 1000 lines long.
*   **Duplicated Logic**: Batch date sorting and "earliest expiration" logic is repeated in `InventoryService` and `InventoryScreen`.
*   **Hardcoded Values**: Strings ("Tout", "Frigo") and colors are hardcoded throughout the app.
*   **Magic Numbers**: `dvm` calculations (days * 24 * 60...) are scattered.

### Suggestions
*   **Extract Widgets**: Break `InventoryScreen` into:
    *   `InventoryHeader`
    *   `InventoryFilterTabs`
    *   `InventoryList`
    *   `InventoryItemCard`
*   **Centralize Constants**: Move strings to `l10n` (already started but inconsistent) and constants to a `AppConstants` class.
*   **Helper Classes**: Create a `DateHelper` for date calculations and formatting.

## 3. specific Refactoring Opportunities

### `lib/services/inventory_service.dart`
*   **Refactor**: Remove `FirebaseAuth.instance` usage. Pass `userId` or `householdId` via constructor or method arguments.
*   **Refactor**: Create a `Batch` class to handle the logic of sorting and finding the earliest expiration date.

### `lib/screens/inventory/inventory_screen.dart`
*   **Refactor**: Move `_scanProductBarcode` and `_triggerRecipeGeneration` to a `InventoryActionService` or ViewModel.
*   **Refactor**: Replace `StreamBuilder` with a ViewModel that listens to the stream and exposes a list of `InventoryItem` objects.

### `lib/main.dart`
*   **Refactor**: Extract `ThemeData` to a separate `AppTheme` class.
*   **Refactor**: Move `MultiProvider` setup to a separate `AppProviders` widget to keep `main()` clean.

## 4. State Management

### Current State
*   Mix of `setState` (local UI state) and `Provider` (global state).
*   `InventoryProvider` only holds a list of names, which is underutilized.

### Suggestions
*   **Expand `InventoryProvider`**: Turn it into a full `InventoryViewModel` that manages the list of items, loading states, and error handling.
*   **Remove `setState` for Business Logic**: Use `setState` only for purely ephemeral UI state (e.g., tab selection, text input).

## 5. Performance

### Current State
*   **Frequent Parsing**: `_getInventoryData` parses Firestore documents into Maps on every call.
*   **Heavy Builds**: Large `build` method in `InventoryScreen`.

### Suggestions
*   **Data Models**: Parsing to Dart objects once (in the repository) is more efficient and safer than repeated Map lookups.
*   **`const` Widgets**: Extracting widgets allows Flutter to optimize rebuilds using `const`.

## Proposed Roadmap
1.  **Phase 1: Foundation**: Create Data Models (`InventoryItem`, `Batch`) and Repositories.
2.  **Phase 2: Logic Extraction**: Move logic from `InventoryScreen` to `InventoryViewModel`.
3.  **Phase 3: UI Cleanup**: Extract widgets and implement the new ViewModel.
4.  **Phase 4: Cleanup**: Remove dead code and standardize styling/constants.
