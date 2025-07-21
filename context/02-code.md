## Code Guidelines

### Code Style

- Use latest Dart features and Dart-specific idioms
  - Always prefer pattern matching, switch statements, sealed classes, built-in collection manipulations (spread operator, collection-if and collection-for, etc) over Java-like syntax
  - Use `map`, `where`, `reduce` rather than an empty target collection and adding each item in a for loop, minimize for loops in general
  - For pattern-matcheable classes prefer case. Example: `if (value case EventInput(:final prop))` rather than `if (value is EventInput) { final prop = value.prop }`
  - Use pattern matching operators like `||`:
    ```dart
    final kindCheck = switch (event.kind) {
      >= 10000 && < 20000 || 0 || 3 => this is ReplaceableModel,
      >= 20000 && < 30000 => this is EphemeralModel,
      >= 30000 && < 40000 => this is ParameterizableReplaceableModel,
      _ => this is RegularModel,
    };
    ```
- Always use meaningful variable and function names
- Add comments for complex logic only
- Always ensure no compiler errors nor warnings are left. The goal is to have ZERO compiler messages in the console. If in doubt, stop and ask, as some warnings can be turned off in analysis_options
- Avoid superfluous comments like: `relay.stop(); // Stops the relay`. Only add comments in complex scenarios when code can't clearly express what is going on
- Hardcoding and workarounds: **explicitly forbidden**. For example, do not make special cases just for tests to pass, like cheating in an exam. You should always prioritize the architecturally sound approach, even if it takes a bit longer
- Never use artificial waits (`Future.delayed`) unless it is absolutely necessary for a particular feature. Properly awaiting futures is the architecturally sound way and should always be prioritized.
- Use Flutter best practices

### Architecture

- The app architecture is local-first: All data is pulled from local storage, which is continually sync'ed from remote sources
- Uses the `models` package, via Purplebase package that implements the local-first architecture
- State management:
  - Global and inter-component state uses Riverpod providers (use in `ConsumerWidget`)
  - Local, intra-component state uses Flutter Hooks (use in `HookWidget` or `HookConsumerWidget` if it also reads providers)
  - Do not create simple wrappers around providers, i.e. wrapping one other provider without adding any value
- Component-based architecture, with shared components in `lib/widgets`
- Follows Material 3 design system and component patterns
- Keep widgets of small or medium size and focused
- Use Dart constants for magic numbers and strings (`kConstant`)

### Testing

**⚠️ DO NOT WRITE TESTS** unless the user is experiencing a specific problem or explicitly requests tests. Writing unnecessary tests wastes significant time and money. Only create tests when:

1. **The user is experiencing a bug** that requires testing to diagnose
2. **The user explicitly asks for tests** to be written
3. **Existing functionality is broken** and tests are needed to verify fixes

Never proactively write tests for new features or components. Focus on building functionality that works, not on testing it unless specifically requested.

Every test should have its own environment, so try to minimize shared variables in setup/teardown. Only share initializations/disposals that (1) are expensive and (2) do not hold shared state affecting tests.

You are strictly forbidden from celebrating or congratulating yourself until my approval. Before saying a test or feature has been fixed, you must run it.

**Follow Flutter testing best practices.**

Assertions/expects in tests should be as detailed as possible, that is, do not simply assert a certain object was received, but assert each of its properties relevant to the test.

### Performance

- Optimize images and assets
- Use const constructors where possible
- Implement proper error handling
- Consider lazy loading for large lists

### Utility Functions

**Always check for existing utilities before creating new ones.** The project includes several utility classes that should be used consistently:

- **TimeUtils.formatTimestamp()**: Use this for all timestamp formatting instead of creating custom time formatting logic
- **Utils (from models package)**: Use for all Nostr-related utilities (key generation, encoding/decoding, etc.)
- **NoteParser**: REQUIRED for displaying any note content - never display raw note text

Example:
```dart
// ❌ Don't recreate time formatting
String _formatTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  if (difference.inMinutes < 1) return 'now';
  // ... more custom logic
}

// ✅ Use existing utility
import 'package:purplestack/utils/time_utils.dart';
Text(TimeUtils.formatTimestamp(note.createdAt))
```

### Accessibility

- Use appropriate contrast ratios

