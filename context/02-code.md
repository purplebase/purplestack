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

### Common Widget Architecture - CRITICAL RULE

**⚠️ NEVER MODIFY WIDGETS IN `lib/widgets/common/` WITH APP-SPECIFIC BEHAVIOR**

The widgets in the `common` folder are **GENERIC, REUSABLE COMPONENTS** that must remain pure and framework-agnostic. These widgets serve as the foundation layer for all Purplestack applications.

#### What Makes a Widget "Generic" vs "App-Specific"

**✅ Generic (belongs in `/common/`):**
- Takes data through parameters, never hardcodes app-specific values
- Uses callback functions (`onTap`, `onLike`, etc.) to handle actions
- Focuses on rendering and interaction patterns, not business logic
- Can be used across different applications without modification
- Configurable through props and styling parameters

**❌ App-Specific (belongs in app screens/widgets):**
- Hardcoded business rules or app-specific behavior
- Direct navigation to specific screens
- Hardcoded data sources or API calls
- App-specific styling that can't be configured
- Logic that only makes sense in one application context

#### Examples of FORBIDDEN Modifications

```dart
// ❌ FORBIDDEN: Adding app-specific logic to EngagementRow
class EngagementRow extends StatelessWidget {
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            // This is app-specific navigation - FORBIDDEN in common widgets
            Navigator.pushNamed(context, '/comments'); 
          },
          icon: Icon(Icons.comment),
        ),
        // More forbidden app-specific logic...
      ],
    );
  }
}

// ❌ FORBIDDEN: Hardcoding app-specific behavior in NoteParser
class NoteParser {
  static Widget parse(String content) {
    return TextSpan(
      children: [
        // This hardcodes app-specific behavior - FORBIDDEN
        if (content.contains('farming')) 
          WidgetSpan(child: FarmingBadge()),
      ],
    );
  }
}
```

#### Correct Usage: Keep Common Widgets Generic

```dart
// ✅ CORRECT: Generic EngagementRow that delegates through callbacks
EngagementRow(
  likesCount: note.reactions.length,
  onLike: () {
    // App-specific logic goes in the consuming widget/screen
    _handleLikeAction(note);
  },
  onComment: () {
    // App-specific navigation goes in the consuming widget/screen  
    Navigator.pushNamed(context, '/comments', arguments: note);
  },
)

// ✅ CORRECT: Generic NoteParser with configurable callbacks
NoteParser.parse(
  context,
  note.content,
  onNostrEntity: (entity) {
    // App-specific entity rendering goes in the consuming widget
    return _buildCustomEntityWidget(entity);
  },
)
```

#### Current Generic Widgets (DO NOT MODIFY)

These widgets are already properly designed as generic components:

1. **`NoteParser`** - Parses Nostr content with customizable callbacks for entities, media, and links
2. **`EngagementRow`** - Social engagement metrics with callback-based interaction handling
3. **`TimeUtils` & `TimeAgoText`** - Time formatting utilities with reactive updates
4. **`ProfileAvatar`** - Avatar component that takes a Profile model and styling parameters

#### How to Extend Generic Widgets

**When you need app-specific behavior:**

1. **Use the existing callback system** - All generic widgets provide callbacks for customization
2. **Wrap, don't modify** - Create app-specific wrapper widgets that use the generic component
3. **Compose, don't pollute** - Build complex behaviors by composing multiple generic widgets

**Example: Creating an App-Specific Note Card**

```dart
// ✅ CORRECT: App-specific wrapper that uses generic components
class FarmingNoteCard extends ConsumerWidget {
  final Note note;
  
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          // Use generic ProfileAvatar
          ProfileAvatar(profile: note.author.value),
          
          // Use generic NoteParser with app-specific callbacks
          NoteParser.parse(
            context,
            note.content,
            onNostrEntity: (entity) => _buildFarmingEntity(entity),
            onMediaUrl: (url) => _buildFarmingMedia(url),
          ),
          
          // Use generic EngagementRow with app-specific actions
          EngagementRow(
            likesCount: note.reactions.length,
            onLike: () => _handleFarmingLike(note),
            onComment: () => _navigateToFarmingComments(note),
          ),
        ],
      ),
    );
  }
  
  // App-specific methods stay in the app-specific widget
  Widget _buildFarmingEntity(String entity) { /* ... */ }
  Widget _buildFarmingMedia(String url) { /* ... */ }
  void _handleFarmingLike(Note note) { /* ... */ }
  void _navigateToFarmingComments(Note note) { /* ... */ }
}
```

#### Enforcement

- **Before modifying any file in `/common/`:** Ask yourself "Would this change make sense in every Purplestack application?"
- **If the answer is no:** Create a new app-specific widget that composes the generic components
- **Code reviews must reject** any pull requests that add app-specific behavior to common widgets
- **When in doubt:** Discuss the change with the team before implementation

This separation ensures:
- ✅ Reusability across different Purplestack applications  
- ✅ Easier maintenance and testing
- ✅ Clear separation of concerns
- ✅ Framework-level stability

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

- **TimeUtils & TimeAgoText**: Use for all timestamp formatting with both static and reactive options
  - ⚠️ **These are generic components in `/common/` - never modify with app-specific behavior**
- **Utils (from models package)**: Use for all Nostr-related utilities (key generation, encoding/decoding, etc.)
- **NoteParser**: REQUIRED for displaying any note content - never display raw note text
  - ⚠️ **This is a generic component in `/common/` - never modify with app-specific behavior**

**Time Formatting Guidelines:**
- Use `TimeAgoText` for timestamps that need to auto-update (feeds, chats, live content)
- Use `TimeUtils.formatTimestamp()` for static displays that don't need updates

Examples:
```dart
// ❌ Don't recreate time formatting
String _formatTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  if (difference.inMinutes < 1) return 'now';
  // ... more custom logic
}

// ✅ Use reactive widget for auto-updating displays
import 'package:purplestack/widgets/common/time_utils.dart';
TimeAgoText(
  note.createdAt,
  style: Theme.of(context).textTheme.bodySmall,
)

// ✅ Use static utility for non-updating displays
Text(TimeUtils.formatTimestamp(note.createdAt))
```

