 # Project Development Rules & Guidelines

These rules must be followed for every feature implementation and code change in the project.

## 1. Project Architecture & Folder Structure

We follow a feature-based architecture. Each feature should be strictly isolated in its own directory under lib/features/<feature_name>/.

### Feature Directory Layout
Each feature folder must contain the following sub-directories:

- `models/`: Data models (Request/Response objects).
- `cubits/`: State management logic. Each Cubit should have its own folder.
- `repo/`: Data layer and repository pattern implementations.
- `presentation/`: UI code.
  - components/: Smaller, reusable widgets specific to this feature.
  - <feature_name>_screen.dart: The main screen file.

Example:
lib/features/example/
├── models/
├── cubits/
├── repo/
└── presentation/
    ├── example_screen.dart
    └── components/

### Logical Layers
Organize the project into logical layers:
- Presentation (widgets, screens)
- Domain (business logic classes - Cubits)
- Data (model classes, API clients - Repositories)
- Core (shared classes, utilities, and extension types)

### Separation of Concerns
Aim for separation of concerns similar to MVC/MVVM, with defined Model, View, and Controller roles. All business logic resides in the Cubit layer.

## 2. State Management (Cubit)

- Use Cubit for all state management. This is the project standard.
- No Logic in UI: UI pages and widgets must remain logic-free. They should only listen to state changes and dispatch events/method calls to the Cubit.
- All business logic resides in the Cubit.
- State Separation: Separate ephemeral state and app state. Use Cubit for app state to handle the separation of concerns.

## 3. Data Layer (Repository)

- Repositories: Specific functions for API calls and data fetching must be placed in the repo/ directory.
- Cubits should call these repository functions to get data.
- Data Abstraction: Abstract data sources (e.g., API calls, database operations) using Repositories/Services to promote testability.
- Data Structures: Define data structures (classes) to represent the data used in the application.

## 4. UI & Widget Guidelines

- Split into Small Widgets: Do not put all code in one screen file. Break down the UI into smaller, manageable widgets.
- Components Folder: Place these smaller widgets in the presentation/components/ folder of the feature.
- Professional Structure: Ensure widgets are named clearly and have single responsibilities.
- Composition over Inheritance: Favor composition for building complex widgets and logic.
- Private Widgets: Use small, private Widget classes instead of private helper methods that return a Widget.
- Build Methods: Break down large build() methods into smaller, reusable private Widget classes.
- Immutability: Widgets (especially StatelessWidget) are immutable; when the UI needs to change, Flutter rebuilds the widget tree. Prefer immutable data structures.
- Const Constructors: Use const constructors for widgets and in build() methods whenever possible to reduce rebuilds.
- Build Method Performance: Avoid performing expensive operations, like network calls or complex computations, directly within build() methods.
- List Performance: Use ListView.builder or SliverList for long lists to create lazy-loaded lists for performance.
- Isolates: Use compute() to run expensive calculations in a separate isolate to avoid blocking the UI thread, such as JSON parsing.

## 5. Styling & Theming
 - Centralized Styling: Avoid hardcoding styles (colors, text styles) directly in widgets.
- App Theme: Add general styles to lib/config/theme/app_theme.dart.
- App Colors: Always use colors from lib/config/theme/app_colors.dart.
- Theme Usage: Access styles via Theme.of(context) whenever possible to maintain consistency across Light and Dark modes.
- Centralized Theme: Define a centralized ThemeData object to ensure a consistent application-wide style.
- Light and Dark Themes: Implement support for both light and dark themes, ideal for a user-facing theme toggle (ThemeMode.light, ThemeMode.dark, ThemeMode.system).
- Color Scheme Generation: Generate harmonious color palettes from a single color using ColorScheme.fromSeed.
- Component Themes: Use specific theme properties (e.g., appBarTheme, elevatedButtonTheme) to customize the appearance of individual Material components.
- Responsiveness: Use LayoutBuilder or MediaQuery to create responsive UIs. The project uses flutter_screenutil for responsive design.
- Text: Use Theme.of(context).textTheme for text styles.

### Material Theming Best Practices

#### Embrace ThemeData and Material 3

* Use `ColorScheme.fromSeed()`: Use this to generate a complete, harmonious color palette for both light and dark modes from a single seed color.
* Define Light and Dark Themes: Provide both theme and darkTheme to your MaterialApp to support system brightness settings seamlessly.
* Centralize Component Styles: Customize specific component themes (e.g., elevatedButtonTheme, cardTheme, appBarTheme) within ThemeData to ensure consistency.

// main.dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 14.0, height: 1.4),
    ),
  ),
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
  ),
  home: const MyHomePage(),
);

#### Implement Design Tokens with ThemeExtension

For custom styles that aren't part of the standard ThemeData, use ThemeExtension to define reusable design tokens.

* Create a Custom Theme Extension: Define a class that extends ThemeExtension<T> and include your custom properties.
* Implement `copyWith` and `lerp`: These methods are required for the extension to work correctly with theme transitions.
* Register in `ThemeData`: Add your custom extension to the extensions list in your ThemeData.
* Access Tokens in Widgets: Use Theme.of(context).extension<MyColors>()! to access your custom tokens.

// 1. Define the extension
@immutable
class MyColors extends ThemeExtension<MyColors> {
  const MyColors({required this.success, required this.danger});

  final Color? success;
  final Color? danger;

  @override
  ThemeExtension<MyColors> copyWith({Color? success, Color? danger}) {
    return MyColors(success: success ?? this.success, danger: danger ?? this.danger);
  }

  @override
  ThemeExtension<MyColors> lerp(ThemeExtension<MyColors>? other, double t) {
    if (other is! MyColors) return this;
    return MyColors(
      success: Color.lerp(success, other.success, t),
      danger: Color.lerp(danger, other.danger, t),
    );
  }
}

// 2. Register it in ThemeData
theme: ThemeData(
  extensions: const <ThemeExtension<dynamic>>[
    MyColors(success: Colors.green, danger: Colors.red),
  ],
),

// 3. Use it in a widget
Container(
  color: Theme.of(context).extension<MyColors>()!.success,
)

#### Styling with WidgetStateProperty

* `WidgetStateProperty.resolveWith`: Provide a function that receives a Set<WidgetState> and returns the appropriate value for the current state.
* `WidgetStateProperty.all`: A shorthand for when the value is the same for all states.
 // Example: Creating a button style that changes color when pressed.
final ButtonStyle myButtonStyle = ButtonStyle(
  backgroundColor: WidgetStateProperty.resolveWith<Color>(
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.green; // Color when pressed
      }
      return Colors.red; // Default color
    },
  ),
);

### Color Scheme Best Practices

#### Contrast Ratios

* WCAG Guidelines: Aim to meet the Web Content Accessibility Guidelines (WCAG) 2.1 standards.
* Minimum Contrast:
  * Normal Text: A contrast ratio of at least 4.5:1.
  * Large Text: (18pt or 14pt bold) A contrast ratio of at least 3:1.

#### Palette Selection

* Primary, Secondary, and Accent: Define a clear color hierarchy.
* The 60-30-10 Rule: A classic design rule for creating a balanced color scheme.
  * 60% Primary/Neutral Color (Dominant)
  * 30% Secondary Color
  * 10% Accent Color

#### Complementary Colors

* Use with Caution: They can be visually jarring if overused.
* Best Use Cases: They are excellent for accent colors to make specific elements pop, but generally poor for text and background pairings as they can cause eye strain.

### Font Best Practices

#### Font Selection

* Limit Font Families: Stick to one or two font families for the entire application.
* Prioritize Legibility: Choose fonts that are easy to read on screens of all sizes. Sans-serif fonts are generally preferred for UI body text.
* System Fonts: Consider using platform-native system fonts.
* Google Fonts: For a wide selection of open-source fonts, use the google_fonts package.

#### Hierarchy and Scale

* Establish a Scale: Define a set of font sizes for different text elements (e.g., headlines, titles, body text, captions).
* Use Font Weight: Differentiate text effectively using font weights.
* Color and Opacity: Use color and opacity to de-emphasize less important text.

#### Readability

* Line Height (Leading): Set an appropriate line height, typically 1.4x to 1.6x the font size.
* Line Length: For body text, aim for a line length of 45-75 characters.
* Avoid All Caps: Do not use all caps for long-form text.

### Visual Design Guidelines

* UI Design: Build beautiful and intuitive user interfaces that follow modern design guidelines.
* Responsiveness: Ensure the app is mobile responsive and adapts to different screen sizes, working perfectly on mobile and web.
* Navigation: If there are multiple pages for the user to interact with, provide an intuitive and easy navigation bar or controls.
* Typography: Stress and emphasize font sizes to ease understanding, e.g., hero text, section headlines, list headlines, keywords in paragraphs.
* Background: Apply subtle noise texture to the main background to add a premium, tactile feel.
* Shadows: Multi-layered drop shadows create a strong sense of depth; cards have a soft, deep shadow to look "lifted."
* Icons: Incorporate icons to enhance the user's understanding and the logical navigation of the app.
* Interactive Elements: Buttons, checkboxes, sliders, lists, charts, graphs, and other interactive elements have a shadow with elegant use of color to create a "glow" effect.

## 6. Localization

- Translate All Text: Never hardcode strings in the UI.
- Use l10n: Add new strings to lib/l10n/app_en.arb and lib/l10n/app_ar.arb.
- Naming: Use descriptive keys for localization strings.

## 7. Storage Management

- Storage Keys: Never hardcode string keys for SharedPreferences or FlutterSecureStorage.
- Centralized Keys: Define all storage keys in lib/config/constants/storage_keys.dart.
- Usage: Always reference keys via the StorageKeys class.

## 8. Form Validation

- Centralized Validation: Do not write validation logic directly in UI widgets.
- Validator Class: Use the Validator class located in lib/config/validator/validator.dart for all form validations.
- Reusable: Create reusable validation methods for common fields (email, phone, password).

## 9. Image Loading
 - Cached Images: Always use CachedNetworkImage from the cached_network_image package for loading images from URLs.
- Placeholders: Always provide a placeholder and error widget for network images.
- Local Images: Use Image.asset for local images from your asset bundle.
- Custom Icons: Use ImageIcon to display an icon from an ImageProvider, useful for custom icons not in the Icons class.

### Assets and Images

* Image Guidelines: If images are needed, make them relevant and meaningful, with appropriate size, layout, and licensing (e.g., freely available). Provide placeholder images if real ones are not available.
* Asset Declaration: Declare all asset paths in your pubspec.yaml file.

flutter:
  uses-material-design: true
  assets:
    - assets/images/

## 10. Routing & Navigation

- GoRouter: Use the go_router package for declarative navigation, deep linking, and web support. This is the project standard.
- GoRouter Setup: Configure routes in lib/routes/app_router.dart.
- Authentication Redirects: Configure go_router's redirect property to handle authentication flows, ensuring users are redirected to the login screen when unauthorized, and back to their intended destination after successful login.
- Navigator: Use the built-in Navigator for short-lived screens that do not need to be deep-linkable, such as dialogs or temporary views.

// Push a new screen onto the stack
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const DetailsScreen()),
);

// Pop the current screen to go back
Navigator.pop(context);

## 11. Data Handling & Serialization

- JSON Serialization: Use json_serializable and json_annotation for parsing and encoding JSON data.
- Field Renaming: When encoding data, use fieldRename: FieldRename.snake to convert Dart's camelCase fields to snake_case JSON keys.

// In your model file
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final String firstName;
  final String lastName;

  User({required this.firstName, required this.lastName});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

## 12. Code Quality & Standards

### Code Structure

- Code structure: Adhere to maintainable code structure and separation of concerns (e.g., UI logic separate from business logic).
- SOLID Principles: Apply SOLID principles throughout the codebase.
- Concise and Declarative: Write concise, modern, technical Dart code. Prefer functional and declarative patterns.
- Simplicity: Write straightforward code. Code that is clever or obscure is difficult to maintain.
- Error Handling: Anticipate and handle potential errors. Don't let your code fail silently.

### Naming Conventions

- Naming conventions: Avoid abbreviations and use meaningful, consistent, descriptive names for variables, functions, and classes.
- Styling:
  * Line length: Lines should be 80 characters or fewer.
  * Use PascalCase for classes, camelCase for members/variables/functions/enums, and snake_case for files.

### Functions

- Functions: Functions should be short and with a single purpose (strive for less than 20 lines).
- Arrow Functions: Use arrow syntax for simple one-line functions.

### Dart Best Practices
 - Effective Dart: Follow the official Effective Dart guidelines (https://dart.dev/effective-dart)
- Class Organization: Define related classes within the same library file. For large libraries, export smaller, private libraries from a single top-level library.
- Library Organization: Group related libraries in the same folder.
- API Documentation: Add documentation comments to all public APIs, including classes, constructors, methods, and top-level functions.
- Comments: Write clear comments for complex or non-obvious code. Avoid over-commenting.
- Trailing Comments: Don't add trailing comments.
- Async/Await: Ensure proper use of async/await for asynchronous operations with robust error handling.
  * Use Future`s, `async, and await for asynchronous operations.
  * Use `Stream`s for sequences of asynchronous events.
- Null Safety: Write code that is soundly null-safe. Leverage Dart's null safety features. Avoid ! unless the value is guaranteed to be non-null.
- Pattern Matching: Use pattern matching features where they simplify the code.
- Records: Use records to return multiple types in situations where defining an entire class is cumbersome.
- Switch Statements: Prefer using exhaustive switch statements or expressions, which don't require break statements.
- Exception Handling: Use try-catch blocks for handling exceptions, and use exceptions appropriate for the type of exception. Use custom exceptions for situations specific to your code.

### Logging

- Structured Logging: Use the log function from dart:developer for structured logging that integrates with Dart DevTools. Never use print statements.

import 'dart:developer' as developer;

// For simple messages
developer.log('User logged in successfully.');

// For structured error logging
try {
  // ... code that might fail
} catch (e, s) {
  developer.log(
    'Failed to fetch data',
    name: 'myapp.network',
    level: 1000, // SEVERE
    error: e,
    stackTrace: s,
  );
}

## 13. Code Generation

- Build Runner: If the project uses code generation, ensure that build_runner is listed as a dev dependency in pubspec.yaml.
- Code Generation Tasks: Use build_runner for all code generation tasks, such as for json_serializable and freezed.
- Running Build Runner: After modifying files that require code generation, run the build command:

dart run build_runner build --delete-conflicting-outputs

## 14. Package Management

- Pub Tool: To manage packages, use the pub tool, if available.
- External Packages: If a new feature requires an external package, use the pub_dev_search tool, if it is available. Otherwise, identify the most suitable and stable package from pub.dev.
- Adding Dependencies: To add a regular dependency, use the pub tool, if it is available. Otherwise, run flutter pub add <package_name>.
- Adding Dev Dependencies: To add a development dependency, use the pub tool, if it is available, with dev:<package name>. Otherwise, run flutter pub add dev:<package_name>.
- Dependency Overrides: To add a dependency override, use the pub tool, if it is available, with override:<package name>:1.0.0. Otherwise, run flutter pub add override:<package_name>:1.0.0.
- Removing Dependencies: To remove a dependency, use the pub tool, if it is available. Otherwise, run dart pub remove <package_name>.

## 15. Lint Rules

Include the package in the analysis_options.yaml file. Use the following analysis_options.yaml file as a starting point:

include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Add additional lint rules here:
    # avoid_print: false
    # prefer_single_quotes: true

## 16. Layout Best Practices

### Building Flexible and Overflow-Safe Layouts

#### For Rows and Columns

* `Expanded`: Use to make a child widget fill the remaining available space along the main axis.
* `Flexible`: Use when you want a widget to shrink to fit, but not necessarily grow. Don't combine Flexible and Expanded in the same Row or Column.
* `Wrap`: Use when you have a series of widgets that would overflow a Row or Column, and you want them to move to the next line.
#### For General Content

* `SingleChildScrollView`: Use when your content is intrinsically larger than the viewport, but is a fixed size.
* `ListView` / `GridView`: For long lists or grids of content, always use a builder constructor (.builder).
* `FittedBox`: Use to scale or fit a single child widget within its parent.
* `LayoutBuilder`: Use for complex, responsive layouts to make decisions based on the available space.

### Layering Widgets with Stack

* `Positioned`: Use to precisely place a child within a Stack by anchoring it to the edges.
* `Align`: Use to position a child within a Stack using alignments like Alignment.center.

### Advanced Layout with Overlays

* `OverlayPortal`: Use this widget to show UI elements (like custom dropdowns or tooltips) "on top" of everything else. It manages the OverlayEntry for you.

class MyDropdown extends StatefulWidget {
  const MyDropdown({super.key});

  @override
  State<MyDropdown> createState() => _MyDropdownState();
}

class _MyDropdownState extends State<MyDropdown> {
  final _controller = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (BuildContext context) {
        return const Positioned(
          top: 50,
          left: 10,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('I am an overlay!'),
            ),
          ),
        );
      },
      child: ElevatedButton(
        onPressed: _controller.toggle,
        child: const Text('Toggle Overlay'),
      ),
    );
  }
}

## 17. Testing

- Running Tests: To run tests, use the run_tests tool if it is available, otherwise use flutter test.
- Unit Tests: Use package:test for unit tests.
- Widget Tests: Use package:flutter_test for widget tests.
- Integration Tests: Use package:integration_test for integration tests.
- Assertions: Prefer using package:checks for more expressive and readable assertions over the default matchers.

### Testing Best Practices

- Convention: Follow the Arrange-Act-Assert (or Given-When-Then) pattern.
- Unit Tests: Write unit tests for domain logic, data layer, and state management (Cubits).
- Widget Tests: Write widget tests for UI components.
- Integration Tests: For broader application validation, use integration tests to verify end-to-end user flows.
- integration_test package: Use the integration_test package from the Flutter SDK for integration tests. Add it as a dev_dependency in pubspec.yaml by specifying sdk: flutter.
- Mocks: Prefer fakes or stubs over mocks. If mocks are absolutely necessary, use mockito or mocktail to create mocks for dependencies. While code generation is common for state management (e.g., with freezed), try to avoid it for mocks.
- Coverage: Aim for high test coverage.
- Testing in Mind: Write code with testing in mind. Use the file, process, and platform packages, if appropriate, so you can inject in-memory and fake versions of the objects.

## 18. Documentation

- `dartdoc`: Write dartdoc-style comments for all public APIs.

### Documentation Philosophy

- Comment wisely: Use comments to explain why the code is written a certain way, not what the code does. The code itself should be self-explanatory.
- Document for the user: Write documentation with the reader in mind. If you had a question and found the answer, add it to the documentation where you first looked. This ensures the documentation answers real-world questions.
- No useless documentation: If the documentation only restates the obvious from the code's name, it's not helpful. Good documentation provides context and explains what isn't immediately apparent.
- Consistency is key: Use consistent terminology throughout your documentation.

### Commenting Style
 - Use `///` for doc comments: This allows documentation generation tools to pick them up.
- Start with a single-sentence summary: The first sentence should be a concise, user-centric summary ending with a period.
- Separate the summary: Add a blank line after the first sentence to create a separate paragraph. This helps tools create better summaries.
- Avoid redundancy: Don't repeat information that's obvious from the code's context, like the class name or signature.
- Don't document both getter and setter: For properties with both, only document one. The documentation tool will treat them as a single field.

### Writing Style

- Be brief: Write concisely.
- Avoid jargon and acronyms: Don't use abbreviations unless they are widely understood.
- Use Markdown sparingly: Avoid excessive markdown and never use HTML for formatting.
- Use backticks for code: Enclose code blocks in backtick fences, and specify the language.

### What to Document

- Public APIs are a priority: Always document public APIs.
- Consider private APIs: It's a good idea to document private APIs as well.
- Library-level comments are helpful: Consider adding a doc comment at the library level to provide a general overview.
- Include code samples: Where appropriate, add code samples to illustrate usage.
- Explain parameters, return values, and exceptions: Use prose to describe what a function expects, what it returns, and what errors it might throw.
- Place doc comments before annotations: Documentation should come before any metadata annotations.

## 19. Accessibility (A11Y)

Implement accessibility features to empower all users, assuming a wide variety of users with different physical abilities, mental abilities, age groups, education levels, and learning styles.

- Color Contrast: Ensure text has a contrast ratio of at least 4.5:1 against its background.
- Dynamic Text Scaling: Test your UI to ensure it remains usable when users increase the system font size.
- Semantic Labels: Use the Semantics widget to provide clear, descriptive labels for UI elements.
- Screen Reader Testing: Regularly test your app with TalkBack (Android) and VoiceOver (iOS).

## 20. API Design Principles

When building reusable APIs, such as a library, follow these principles.

- Consider the User: Design APIs from the perspective of the person who will be using them. The API should be intuitive and easy to use correctly.
- Documentation is Essential: Good documentation is a part of good API design. It should be clear, concise, and provide examples.

## 21. Dependency Injection

- Manual Constructor Injection: Use simple manual constructor dependency injection to make a class's dependencies explicit in its API, and to manage dependencies between different layers of the application.
- Service Locator: The project uses a service locator pattern (see lib/core/services/service_locator.dart) for dependency management.

---

*Reference this file before starting any new task to ensure compliance with project standards.*