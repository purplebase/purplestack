# Purplestack

Development stack designed for AI agents to build Nostr-enabled Flutter applications. It includes a complete tech stack with Purplebase and Riverpod, documentation and recipes for common implementation scenarios.

**Important for AI Assistants**:
  - **Behavior**: The AI assistant's behavior and knowledge is defined by the CONTEXT.md file, which serves as the system prompt. ALWAYS refer to this document and follow these rules and recommendations.
  - **First prompt**: When a user makes the first prompt, and only during that very first prompt, you MUST ALWAYS summarize what you understood, and ask important questions to ensure all requirements are crystal clear before starting to code. Do NOT skip this first step.

## Technology Stack

- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Riverpod / hooks_riverpod**: State management and dependency injection
- **Flutter Hooks**: React-style hooks for Flutter
- **models**: Domain models for Nostr events
- **Purplebase**: Local-first Nostr SDK with storage and relay pool, implementation of the `models` package interface
- **amber_signer**: NIP-55 Android signer integration
- **GoRouter**: Declarative routing
- **google_fonts**: Font management
- **fluttertoast**: Toast components
- **cached_network_image**: Image loading and caching
- **flutter_markdown**: Markdown rendering
- **auto_size_text**: Responsive text sizing
- **skeletonizer**: Skeleton loading states
- **percent_indicator**: Progress indicators
- **easy_image_viewer**: Image viewing
- **flutter_layout_grid**: Grid layouts
- **table_calendar**: Highly customizable, feature-packed calendar widget
- **dart_emoji**: Emoji support and parsing
- **any_link_preview**: Link preview generation
- **async_button_builder**: Async button states and interactions
- **path_provider**: Platform-specific directory paths
- **sqlite3_flutter_libs**: SQLite3 support for Flutter
- **http**: HTTP client for API requests
- **url_launcher**: Launch URLs in external applications
- **path**: Cross-platform path manipulation

**Important**: Flutter can produce binaries for a myriad of operating systems. **Assume the user wants an Android application (arm64-v8a), unless specifically asked otherwise**, take this into account when testing a build or launching a simulator.

## MCP Servers

There are included MCP servers that you MUST use them appropriately:

### `developer` MCP Server

The `developer` server provides development and debugging tools:
- **File operations**: Reading, writing, editing files in the project
- **Terminal commands**: Running development commands, build processes, testing
- **Code analysis**: Searching code, analyzing structure, finding patterns
- **Project management**: Understanding project layout and dependencies

Use this server for:
- Code generation and modification
- Running tests and builds
- Debugging issues
- Project exploration and analysis

### `nostr` MCP Server

The `nostr` server provides Nostr protocol reference and documentation:
- **NIP documentation**: Read specific NIPs using `mcp_nips_read_nip`
- **Kind reference**: Look up event kinds with `mcp_nips_read_kind`
- **Tag reference**: Understand tag usage with `mcp_nips_read_tag`
- **Protocol basics**: Core concepts with `mcp_nips_read_protocol`
- **Complete index**: Overview of all NIPs, kinds, and tags with `mcp_nips_read_nips_index`

Use this server for:
- Understanding Nostr protocol specifications
- Finding appropriate event kinds for features
- Learning tag usage patterns
- Ensuring compliance with Nostr standards
- Researching existing solutions before creating custom kinds

## Project Structure

This is a standard Flutter app with multi-platform support, but here are additional details:

- `lib/main.dart`: App entry point with providers setup
- `lib/router.dart`: Router configuration and provider
- `lib/theme.dart`: Theme related code and providers
- `lib/widgets`: Shared UI components
  - **`lib/widgets/common/`**: ⚠️ **CRITICAL - Generic, reusable components that must NEVER be modified with app-specific behavior. See detailed guidelines in Code Guidelines section.**
- `lib/screens`: Screen components used by the router
- `lib/utils`: Utility functions and shared logic
- `test/utils`: Testing utilities
- `assets`: Static assets

## UI Components

The project uses [Material 3](https://m3.material.io/).

The setting `useMaterial3: true` is already used in the default `MaterialApp`.

### Use Built-in Material 3 Components

- **AppBar**: A top app bar that displays information and actions related to the current screen, typically containing a title, navigation icon, and action items.

- **Alert/AlertDialog**: A modal dialog that interrupts the user's workflow to provide critical information or ask for a decision.

- **CircleAvatar**: A circular widget that represents a user with an image, icon, or initials.

- **Badge**: A small notification marker that appears on top of an icon or other content to indicate an unread message, notification, or update.

- **MaterialBanner**: A persistent, non-modal surface that displays an important message and related actions.

- **BottomSheet**: A surface that slides up from the bottom edge of the screen to reveal additional content.

- **Button**: Various button types (Elevated, Filled, Outlined, Text) that trigger actions when pressed, with different emphasis levels based on importance.

- **Card**: A container that presents content and actions on a single topic, with a distinct visual boundary and elevation shadow.

- **Checkbox**: A selection control that allows users to select multiple items from a set or mark items as completed.

- **Chip**: A compact element representing an input, attribute, or action, often used for filtering content or entering information.

- **Progress Indicators**: Indicators showing an ongoing process with either determinate or indeterminate duration, including CircularProgressIndicator and LinearProgressIndicator.

- **DatePicker**: A dialog or inline component that allows users to select a date from a calendar interface.

- **Dialog**: A modal window that appears in front of app content to provide critical information or ask for a decision.

- **Divider/Separator**: A thin line that groups content in lists and layouts, creating visual separation between items.

- **Drawer**: A panel that slides in from the edge of the screen to show navigation options or other content.

- **DropdownButton/Select**: A button that displays a menu when pressed, allowing users to select from a list of options.

- **ExpansionPanel**: A container that can be expanded or collapsed to reveal or hide content.

- **FloatingActionButton**: A circular button that represents the primary action of a screen, floating above the UI.

- **IconButton**: A button that displays an icon without a text label, used for common actions.

- **TextField**: An input component that allows users to enter and edit text, with various styling and validation options.

- **ListTile**: A single fixed-height row that typically contains text and icons, used in lists and menus.

- **Menu**: A temporary sheet of options that appears when a user interacts with a button or other control.

- **Radio/RadioGroup**: A selection control that allows users to select one option from a set.

- **Sheet**: A surface containing content that appears by sliding from an edge of the screen, including bottom sheets, side sheets, etc.

- **Slider**: A control that lets users select a value from a continuous or discrete range by dragging a thumb.

- **SnackBar**: A lightweight message that appears temporarily at the bottom of the screen to provide feedback.

- **Switch**: A toggle control that changes the state of a single option between on and off.

- **TabBar**: A horizontal row of tabs for navigating between different views or functional aspects of an app.

- **DataTable**: A component for displaying data in rows and columns, with options for sorting, selecting, and pagination.

- **TimePicker**: A dialog or inline component that allows users to select a specific time.

- **Tooltip**: A small popup that displays informative text when users hover over, focus on, or tap an element.

### Components Requiring External Packages

These are already included in `pubspec.yaml`.

1. **Calendar**
You can add Calendar, Horizontal Calendar, Planner or Timetable to your Flutter app using external packages. Use `table_calendar`, a is a highly customizable, feature-packed calendar widget for Flutter.

2. **Toast**
Flutter apps can provide quick feedback about operations using Toasts or Notifications that appear in the middle of the lower half of the screen as small alerts with translucent backgrounds. For this functionality, you can use packages like `fluttertoast` which is a Toast Library for Flutter that lets you easily create toast messages in a single line of code.

## Package Usage Guidelines

### Content Rendering

#### flutter_markdown
**Use ONLY for long-form content** where Markdown is explicitly allowed or expected:

```dart
// ✅ Correct: Articles, long-form content (kind 30023)
import 'package:flutter_markdown/flutter_markdown.dart';

// For Articles and other long-form content
Markdown(
  data: article.content,
  styleSheet: MarkdownStyleSheet(
    h1: Theme.of(context).textTheme.headlineLarge,
    h2: Theme.of(context).textTheme.headlineMedium,
    p: Theme.of(context).textTheme.bodyMedium,
  ),
)

// ❌ Wrong: Never use for kind 1 notes (short text notes)
// Kind 1 notes should use NoteParser.parse() instead
```

**When to use flutter_markdown:**
- Kind 30023 (Articles)
- Custom kinds where Markdown is part of the specification
- Tags explicitly documented to contain Markdown
- Long-form content display screens

**When NOT to use:**
- Kind 1 notes (use `NoteParser.parse()` instead)
- Profile descriptions (unless NIP specifies Markdown support)
- Any content where Markdown isn't explicitly part of the protocol

#### any_link_preview
Already implemented in `NoteParser`, but useful for standalone hyperlink rendering:

```dart
import 'package:any_link_preview/any_link_preview.dart';

// For standalone link previews outside of note content
AnyLinkPreview(
  link: url,
  displayDirection: UIDirection.uiDirectionHorizontal,
  showMultimedia: true,
  bodyMaxLines: 2,
  titleStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
  backgroundColor: Theme.of(context).colorScheme.surface,
  borderRadius: 8.0,
  onTap: () => launchUrl(Uri.parse(url)),
)
```

### Layout and Responsiveness

#### flutter_layout_grid
**Use for complex UIs** where a grid layout is justified:

```dart
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

// ✅ Good: Complex layouts with multiple columns and varied sizing
LayoutGrid(
  columnSizes: [1.fr, 2.fr, 1.fr],
  rowSizes: [auto, 1.fr, auto],
  columnGap: 16,
  rowGap: 16,
  children: [
    GridPlacement(
      areaName: 'header',
      child: HeaderWidget(),
    ),
    GridPlacement(
      columnStart: 1,
      columnSpan: 2,
      child: ContentWidget(),
    ),
    GridPlacement(
      areaName: 'sidebar',
      child: SidebarWidget(),
    ),
  ],
)

// ❌ Avoid: Simple lists or basic layouts (use Column/Row instead)
```

**When to use flutter_layout_grid:**
- Dashboard layouts with multiple panels
- Complex responsive designs
- Layouts requiring specific column/row spanning
- When CSS Grid-like behavior is needed

#### auto_size_text
**Use for long labels** that don't fit in available space as an **alternative to ellipsis**:

```dart
import 'package:auto_size_text/auto_size_text.dart';

// ✅ Good: Dynamic text sizing for constrained spaces
AutoSizeText(
  user.displayName ?? 'Unknown User',
  style: Theme.of(context).textTheme.titleMedium,
  maxLines: 1,
  minFontSize: 12,
  maxFontSize: 16,
  overflow: TextOverflow.ellipsis, // Fallback if text still doesn't fit
)

// ✅ Good: Responsive text in cards or constrained containers
Container(
  width: 120,
  child: AutoSizeText(
    longTitle,
    style: Theme.of(context).textTheme.bodyLarge,
    maxLines: 2,
    textAlign: TextAlign.center,
  ),
)

// ❌ Avoid: Use regular Text widget when space is not constrained
```

**When to use auto_size_text:**
- User-generated content with varying lengths
- Responsive cards or tiles with dynamic content
- Navigation labels that might overflow
- Any UI where text length is unpredictable and space is limited

### Progress and File Operations

#### percent_indicator
**Perfect for uploads/downloads** and file transfer operations, especially with **Blossom implementation**:

```dart
import 'package:percent_indicator/percent_indicator.dart';

// ✅ Excellent: File upload progress with Blossom
StreamBuilder<double>(
  stream: uploadProgressStream,
  builder: (context, snapshot) {
    final progress = snapshot.data ?? 0.0;
    return LinearPercentIndicator(
      width: 200,
      lineHeight: 6.0,
      percent: progress,
      backgroundColor: Colors.grey[300],
      progressColor: Theme.of(context).colorScheme.primary,
      trailing: Text('${(progress * 100).toInt()}%'),
    );
  },
)

// ✅ Good: Circular progress for file operations
CircularPercentIndicator(
  radius: 30.0,
  lineWidth: 4.0,
  percent: downloadProgress,
  center: Icon(Icons.download),
  progressColor: Theme.of(context).colorScheme.primary,
  backgroundColor: Colors.grey[300],
)

// Example: Blossom file upload with progress
Future<void> uploadWithProgress(File file) async {
  final streamController = StreamController<double>();
  
  try {
    // Calculate file hash and create authorization
    final bytes = await file.readAsBytes();
    final assetHash = sha256.convert(bytes).toString();
    
    // Upload with progress tracking
    final response = await http.put(
      uploadUri,
      body: bytes,
      headers: headers,
    );
    
    // Update progress
    streamController.add(1.0); // Complete
    
  } catch (e) {
    streamController.addError(e);
  } finally {
    streamController.close();
  }
}
```

**When to use percent_indicator:**
- File upload/download progress (especially with Blossom)
- Media processing operations
- Sync operations with relays
- Any long-running operation with measurable progress
- Loading states where progress percentage is available

## Configuration

See "Storage Configuration" in `models` package reference below in this document.

The default relay group includes: `'wss://relay.damus.io', 'wss://relay.primal.net', 'wss://nos.lol'`.

## Routing

The project uses a GoRouter with a centralized routing configuration in `router.dart`. To add new routes:

1. Create your screen in `screens`
2. Import it in `router.dart`

**Multi-Screen Navigation**: For any multi-screen application request, automatically implement a `BottomNavigationBar` with appropriate tabs and navigation structure. This provides intuitive navigation patterns that users expect on mobile platforms.

## Loading States

**Use skeleton loading** for structured content (feeds, profiles, forms). **Use spinners** only for buttons or short operations.

```dart
// Skeleton loading example for a card list
ListView.builder(
  itemCount: 5,
  itemBuilder: (context, index) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Skeleton(width: 48, height: 48, shape: BoxShape.circle),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Skeleton(width: 120, height: 16),
                SizedBox(height: 8),
                Skeleton(width: 200, height: 12),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
)
```

## Design Customization

**Tailor the site's look and feel based on the user's specific request.**

This includes:

- **Color schemes**: Incorporate the user's color preferences when specified, and choose an appropriate scheme that matches the application's purpose and aesthetic
- **Layout**: Follow the requested structure (bottom navigation bar, drawer, grid, etc)
- **Component styling**: Use appropriate border radius, shadows, and spacing for the desired feel
- **Interactive elements**: Style buttons, forms, and hover states to match the theme

### Typography

Use the `google_fonts` package. Choose fonts that match the requested aesthetic (modern, elegant, playful, etc.).

Material 3 typography is accessible through the theme:

```dart
Text('Headline Large', style: Theme.of(context).textTheme.headlineLarge),
Text('Headline Medium', style: Theme.of(context).textTheme.headlineMedium),
Text('Headline Small', style: Theme.of(context).textTheme.headlineSmall),
Text('Title Large', style: Theme.of(context).textTheme.titleLarge),
Text('Title Medium', style: Theme.of(context).textTheme.titleMedium),
Text('Title Small', style: Theme.of(context).textTheme.titleSmall),
Text('Body Large', style: Theme.of(context).textTheme.bodyLarge),
Text('Body Medium', style: Theme.of(context).textTheme.bodyMedium),
Text('Body Small', style: Theme.of(context).textTheme.bodySmall),
Text('Label Large', style: Theme.of(context).textTheme.labelLarge),
Text('Label Medium', style: Theme.of(context).textTheme.labelMedium),
Text('Label Small', style: Theme.of(context).textTheme.labelSmall),
```

### Loading and displaying media

For images, use the available `cached_network_image` package **with proper error handling**:

```dart
// ✅ Always include errorBuilder to prevent crashes on failed image loads
CachedNetworkImage(
  imageUrl: imageUrl,
  errorBuilder: (context, error, stackTrace) => Container(
    width: 40,
    height: 40,
    color: Colors.grey[300],
    child: Icon(Icons.broken_image, color: Colors.grey[600]),
  ),
  placeholder: (context, url) => CircularProgressIndicator(),
)

// For profile avatars
CircleAvatar(
  backgroundImage: author?.pictureUrl != null
      ? CachedNetworkImageProvider(
          author!.pictureUrl!,
          errorListener: (error) => debugPrint('Image failed to load: $error'),
        )
      : null,
  child: author?.pictureUrl == null ? Icon(Icons.person) : null,
)
```

For viewing larger images with zoom, etc use the `easy_image_viewer` package.

If the user requests video support, use the `chewie` package (not included, must be installed).

### Recommended Styles by Use Case

If the user does not specify, **Modern/Clean** style is the default.

Always adjust palettes to ensure a good contrast ratio, especially with text over backgrounds.

- **Modern/Clean**: 
  - **Fonts**: Inter Variable, Outfit Variable, or Manrope
  - **Color Scheme**: Minimalist palette with subtle grays (#F8F9FA, #E9ECEF, #6C757D) and a single accent color (#007BFF)
  - **UI Elements**: Rounded corners (8-12px), subtle shadows, generous whitespace, clean typography hierarchy
  - **Best For**: Productivity apps, dashboards, professional tools

- **Professional/Corporate**: 
  - **Fonts**: Roboto, Open Sans, or Source Sans Pro  
  - **Color Scheme**: Conservative blues and grays (#1E3A8A, #374151, #F3F4F6) with muted accents
  - **UI Elements**: Sharp corners (4-6px), structured layouts, consistent spacing, formal typography
  - **Best For**: Business applications, enterprise software, financial tools

- **Creative/Artistic**: 
  - **Fonts**: Poppins, Nunito, or Comfortaa
  - **Color Scheme**: Vibrant, diverse palette with gradients (#FF6B6B, #4ECDC4, #45B7D1, #96CEB4)
  - **UI Elements**: Organic shapes, bold colors, playful animations, creative layouts
  - **Best For**: Design tools, creative platforms, entertainment apps

- **Technical/Code**: 
  - **Fonts**: JetBrains Mono, Fira Code, or Source Code Pro (for monospace)
  - **Color Scheme**: Dark theme with syntax highlighting colors (#0D1117, #21262D, #58A6FF, #7EE787)
  - **UI Elements**: Monospace fonts, code-style layouts, terminal aesthetics, minimal distractions
  - **Best For**: Development tools, code editors, technical documentation

### Theme System

The project includes a complete light/dark theme system. The theme can be controlled via the `brightnessProvider` provider for programmatic theme switching.

### Color Scheme Implementation

When users specify color schemes, use Material 3's color system:
- Use `colorSchemeSeed` to generate cohesive color schemes from a single color
- Apply colors consistently across components (buttons, links, accents) using theme colors
- Test both light and dark mode variants

### Component Styling Patterns

- Follow Material 3 design patterns and component variants
- Use theme-based styling: `Theme.of(context).colorScheme.primary`
- Implement responsive design with breakpoints
- Add hover and focus states for interactive elements

## Icons launcher

Used to create icons for all platforms.

```yaml
icons_launcher:
  image_path: "assets/images/logo.png"
  platforms:
    android:
      enable: true
      image_path: "assets/images/logo.png"
      notification_image: "assets/images/logo.png"
      adaptive_background_image: "assets/images/logo-bg.png"
      adaptive_foreground_image: "assets/images/logo-fg.png"
      adaptive_monochrome_image: "assets/images/logo-bw.png"
    macos:
      enable: true
      image_path: "assets/images/logo.png"
```
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
- Fix ALL compiler warnings and errors immediately - The goal is ZERO compiler messages in the console. Run `flutter analyze` before completing any task and fix every single issue it reports:
  - Warnings (marked with ⚠️ or "warning") must be fixed - these indicate potential bugs
  - Info messages (marked with ℹ️ or "info") should also be addressed - these improve code quality
  - Never ignore or skip compiler messages - if unsure how to fix, ask for guidance
  - Always run `flutter analyze` as your final step before marking any task complete
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


## Nostr Protocol Integration

This project uses the `models` and `purplebase` packages which are the ONLY way to interact with the nostr network.

### Nostr Implementation Guidelines

- Always use the `mcp_nips_read_nips_index` tool before implementing any Nostr features to see what kinds are currently in use across all NIPs.
- If any existing kind or NIP might offer the required functionality, use the `mcp_nips_read_nip` tool to investigate thoroughly. Several NIPs may need to be read before making a decision.
- Only generate new kind numbers if no existing suitable kinds are found after comprehensive research.

Knowing when to create a new kind versus reusing an existing kind requires careful judgement. Introducing new kinds means the project won't be interoperable with existing clients. But deviating too far from the schema of a particular kind can cause different interoperability issues.

#### Choosing Between Existing NIPs and Custom Kinds

When implementing features that could use existing NIPs, follow this decision framework:

1. **Thorough NIP Review**: Before considering a new kind, always perform a comprehensive review of existing NIPs and their associated kinds. Use the `mcp_nips_read_nips_index` tool to get an overview, and then `mcp_nips_read_nip` and `mcp_nips_read_kind` to investigate any potentially relevant NIPs or kinds in detail. The goal is to find the closest existing solution.

2. **Prioritize Existing NIPs**: Always prefer extending or using existing NIPs over creating custom kinds, even if they require minor compromises in functionality.

3. **Interoperability vs. Perfect Fit**: Consider the trade-off between:
   - **Interoperability**: Using existing kinds means compatibility with other Nostr clients
   - **Perfect Schema**: Custom kinds allow perfect data modeling but create ecosystem fragmentation

4. **Extension Strategy**: When existing NIPs are close but not perfect:
   - Use the existing kind as the base
   - Add domain-specific tags for additional metadata
   - Document the extensions in `NIP.md`

5. **When to Generate Custom Kinds**:
   - No existing NIP covers the core functionality
   - The data structure is fundamentally different from existing patterns
   - The use case requires different storage characteristics (regular vs replaceable vs addressable)

6. **Custom Kind Publishing**: When publishing events with custom kinds, always include a NIP-31 "alt" tag with a human-readable description of the event's purpose.

**Example Decision Process**:
```
Need: Equipment marketplace for farmers
Options:
1. NIP-15 (Marketplace) - Too structured for peer-to-peer sales
2. NIP-99 (Classified Listings) - Good fit, can extend with farming tags
3. Custom kind - Perfect fit but no interoperability

Decision: Use NIP-99 + farming-specific tags for best balance
```

#### Tag Design Principles

When designing tags for Nostr events, follow these principles:

1. **Kind vs Tags Separation**:
   - **Kind** = Schema/structure (how the data is organized)
   - **Tags** = Semantics/categories (what the data represents)
   - Don't create different kinds for the same data structure

2. **Use Single-Letter Tags for Categories**:
   - **Relays only index single-letter tags** for efficient querying
   - Use `t` tags for categorization, not custom multi-letter tags
   - Multiple `t` tags allow items to belong to multiple categories

3. **Relay-Level Filtering**:
   - Design tags to enable efficient relay-level filtering with `#t: ["category"]`
   - Avoid client-side filtering when relay-level filtering is possible
   - Consider query patterns when designing tag structure

4. **Tag Examples**:
   ```json
   // ❌ Wrong: Multi-letter tag, not queryable at relay level
   ["product_type", "electronics"]
   
   // ✅ Correct: Single-letter tag, relay-indexed and queryable
   ["t", "electronics"]
   ["t", "smartphone"]
   ["t", "android"]
   ```

5. **Querying Best Practices**:
   ```dart
   // ❌ Inefficient: Get all events, filter in Dart
   final models = await ref.storage.query(RequestFilter(kinds: {30402}).toRequest());
   final filtered = models.filter((m) => m.event.containsTag('electronics'));
   
   // ✅ Efficient: Filter at relay level
   final models = await ref.storage.query(RequestFilter(kinds: {30402}, tags: {'#t': {'electronics'}}).toRequest());
   ```

#### `t` Tag Filtering for Community-Specific Content

For applications focused on a specific community or niche, you can use `t` tags to filter events for the target audience.

**When to Use:**
- ✅ Community apps: "farmers" → `t: "farming"`, "Poland" → `t: "poland"`
- ❌ Generic platforms: Twitter clones, general Nostr clients

**Implementation:**
```dart
// Publishing with community tag
final note = PartialNote("note", tags: {'farming'}).signWith(signer);
await ref.storage.publish([note]);

// Querying community content
final notes = await ref.storage.query(RequestFilter<Note>(tags: {'#t': {'farming'}}, limit: 20).toRequest());
```

### Kind Ranges

An event's kind number determines the event's behavior and storage characteristics:

- **Regular Events** (1000 ≤ kind < 10000): Expected to be stored by relays permanently. Used for persistent content like notes, articles, etc.
- **Replaceable Events** (10000 ≤ kind < 20000): Only the latest event per pubkey+kind combination is stored. Used for profile metadata, contact lists, etc.
- **Addressable Events** (30000 ≤ kind < 40000): Identified by pubkey+kind+d-tag combination, only latest per combination is stored. Used for articles, long-form content, etc.

Kinds below 1000 are considered "legacy" kinds, and may have different storage characteristics based on their kind definition. For example, kind 1 is regular, while kind 3 is replaceable.

See `models` package reference below for how to create and initialize events and custom events (models), and which class to inherit from (`RegularModel`, `ReplaceableModel`, etc).

### Content Field Design Principles

When designing new event kinds, the `content` field should be used for semantically important data that doesn't need to be queried by relays. **Structured JSON data generally shouldn't go in the content field** (kind 0 being an early exception).

#### Guidelines

- **Use content for**: Large text, freeform human-readable content, or existing industry-standard JSON formats (Tiled maps, FHIR, GeoJSON)
- **Use tags for**: Queryable metadata, structured data, anything that needs relay-level filtering
- **Empty content is valid**: Many events need only tags with `content: ""`
- **Relays only index tags**: If you need to filter by a field, it must be a tag

#### Example

**✅ Good - queryable data in tags:**
```json
{
  "kind": 30402,
  "content": "",
  "tags": [["d", "product-123"], ["title", "Camera"], ["price", "250"], ["t", "photography"]]
}
```

**❌ Bad - structured data in content:**
```json
{
  "kind": 30402,
  "content": "{\"title\":\"Camera\",\"price\":250,\"category\":\"photo\"}",
  "tags": [["d", "product-123"]]
}
```

### NIP.md

The file `NIP.md` (in the root folder of this project) is used to define a custom Nostr protocol document. If the file doesn't exist, it means this project doesn't have any custom kinds associated with it.

Whenever new kinds are generated, the `NIP.md` file in the project must be created or updated to document the custom event schema. Whenever the schema of one of these custom events changes, `NIP.md` must also be updated accordingly.

### The `query` provider

The `query` provider has a filter-like API for querying Nostr events.

```dart
import 'package:models/models.dart';

final state = ref.watch(query<Note>(authors: {pubkey1}, limit: 10));
```

`query` takes an `and` operator which will instruct it to load relationships. If data is needed, it's always better to use a relationship than a separate query call.

**Do not call query**, especially with many relationships inside loops! If you need relationship loading, use `and` and loop there - it will have the chance to optimize data loading and relay requests.

Use the default `source` argument unless otherwise requested.

See [#models 👯](#models-) reference below.

#### Efficient Query Design

**Critical**: Always minimize the number of separate queries to avoid rate limiting and improve performance. Combine related queries whenever possible.

**✅ Efficient - Single query with multiple kinds:**
```dart
ref.watch(queryKinds(kinds: {1, 6, 16}, authors: {pubkey1}, limit: 150));

// Separate by type in Dart
final notes = events.whereType<Note>();
final reposts = events.whereType<Repost>();
final genericReposts = events.whereType<GenericRepost>();
```

**❌ Inefficient - Multiple separate queries:**
```dart
ref.watch(query<Note>(authors: {pubkey1}));
ref.watch(query<Repost>(authors: {pubkey1}));
ref.watch(query<GenericRepost>(authors: {pubkey1}));
```

**Query Optimization Guidelines:**
1. **Combine kinds**: Use `kinds: [1, 6, 16]` instead of separate queries; if these are relationships then always use the `and` operator: `ref.watch(query<Profile>(authors: {pubkey1}, and: (p) => {p.notes, p.reposts}));`
2. **Use multiple filters**: When you need different tag filters, use multiple filter objects in a single query
3. **Adjust limits**: When combining queries, increase the limit appropriately
4. **Filter by querying local storage**: Querying local storage is cheap, make any kind of specific query there
5. **Consider relay capacity**: Each query consumes relay resources and may count against rate limits

### Displaying a profile

To display profile data for a user by their Nostr pubkey (such as an event author), use the `query<Profile>(authors: {pubkey1})`.

### Signing in a profile

Make sure to **always** use `amber_signer` package first to sign in with the NIP-55-compatible "Amber" Android app, unless the user instructs to support signing in with nsec (`Bip340PrivateKeySigner`). All signer interfaces inherit from `Signer`.

The `Profile` class has all the necessary properties to display a profile in a widget.

Example:

```dart
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile =
        ref.watch(Signer.activeProfileProvider(RemoteSource(group: 'social')));
    final pubkey = ref.watch(Signer.activePubkeyProvider);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pubkey == null) ...[
            ElevatedButton(
              onPressed: () => ref.read(amberSignerProvider).initialize(),
              child: const Text('Sign In'),
            ),
          ] else ...[
            if (profile?.pictureUrl != null)
              CircleAvatar(backgroundImage: NetworkImage(profile!.pictureUrl!)),
            if (profile?.nameOrNpub != null) Text(profile!.nameOrNpub),
            Text(
                '${pubkey.substring(0, 8)}...${pubkey.substring(pubkey.length - 8)}'),
            ElevatedButton(
              onPressed: () => ref.read(amberSignerProvider).dispose(),
              child: const Text('Sign Out'),
            ),
          ],
        ],
      ),
    );
  }
}

final amberSignerProvider = Provider<AmberSigner>(AmberSigner.new);
```

See "Signer Interface & Authentication" in the [#models 👯](#models-) reference below for more.

### Publishing

To publish events, use `storage.publish(...)` in any callback.

### `npub`, `naddr`, and other Nostr addresses

Nostr defines a set of identifiers in NIP-19. Their prefixes:

- `npub`: public keys
- `nsec`: private keys
- `note`: note ids
- `nprofile`: a nostr profile
- `nevent`: a nostr event
- `naddr`: a nostr replaceable event coordinate
- `nrelay`: a nostr relay (deprecated)

All of these can be encoded/decoded via:
  - `Utils.encodeShareableIdentifier` and `Utils.decodeShareableIdentifier` (sealed class with correct types)
  - `Utils.encodeShareable` and `Utils.decodeShareable` (shortcuts for types that return the main value as String)

Always use valid pubkeys, `Utils.generate64Hex()` and other utils allow you to generate private keys, turn to nsec (`privkey.encodeShareable()`), public keys (`Utils.derivePubkey(privkey)`) etc; never use invalid pubkeys like "author-1" which will make relays fail.

For nostr-related utilities always look first in the `models` or `purplebase` packages, where they are likely available, before creating your own.

### Rendering Note Content

**⚠️ Important**: `NoteParser` is a generic component in `/common/`. Never modify it with app-specific behavior - use its callback system for customization. See the **Common Widget Architecture** section in Code Guidelines.

Use `NoteParser.parse()` to automatically detect and render NIP-19 entities, media URLs, and links in note content:

```dart
import 'package:purplestack/widgets/common/note_parser.dart';

// ALWAYS use this instead of Text(note.content)
NoteParser.parse(
  context,
  note.content,
  textStyle: Theme.of(context).textTheme.bodyMedium,
  linkStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: Theme.of(context).colorScheme.primary,
    decoration: TextDecoration.underline,
  ),
)

// With custom widget replacements
NoteParser.parse(
  context,
  note.content,
  textStyle: Theme.of(context).textTheme.bodyMedium,
  onNostrEntity: (entity) {
    // Replace npub1..., note1..., nevent1... with custom widgets
    final decoded = Utils.decodeShareableIdentifier(entity);
    return switch (decoded) {
      ProfileData() => ProfileChip(pubkey: decoded.pubkey),
      EventData() => NotePreview(eventId: decoded.eventId),
      _ => null, // Falls back to styled text
    };
  },
  onMediaUrl: (url) => CachedNetworkImage(
    imageUrl: url, 
    height: 200,
    errorBuilder: (context, error, stackTrace) => Container(
      height: 200,
      color: Colors.grey[300],
      child: Icon(Icons.broken_image, color: Colors.grey[600]),
    ),
  ),
  onHttpUrl: (url) => LinkChip(url: url),
)
```

**Features:**
- Automatically detects `npub1...`, `note1...`, `nevent1...`, etc. (handles `nostr:` prefix)
- Identifies media URLs by file extension (jpg, png, mp4, etc.)
- Returns `RichText` with `WidgetSpan` for seamless text/widget mixing
- Validates NIP-19 entities using `Utils.decodeShareableIdentifier()`
- Graceful fallbacks when callbacks return `null`

**Important**: Any time you display note content (kind 1, kind 11, kind 1111), you MUST use this instead of displaying raw text.

### Displaying Engagement Information

**⚠️ Important**: `EngagementRow` is a generic component in `/common/`. Never modify it with app-specific behavior - use its callback system for customization. See the **Common Widget Architecture** section in Code Guidelines.

Use the `EngagementRow` widget to display social engagement metrics (likes, reposts, zaps, comments) for Nostr notes in a clean, Material 3 design.

**Basic Usage:**

```dart
import 'package:purplestack/widgets/common/engagement_row.dart';

// In your note card widget
EngagementRow(
  likesCount: note.reactions.length,
  repostsCount: note.reposts.length, 
  zapsCount: note.zaps.length,
  zapsSatAmount: note.zaps.toList().fold(0, (sum, zap) => sum + zap.amount),
  commentsCount: note.replies.length, // Optional
)
```

**Interactive Engagement:**

```dart
EngagementRow(
  likesCount: note.reactions.length,
  repostsCount: note.reposts.length,
  zapsCount: note.zaps.length,
  zapsSatAmount: note.zaps.toList().fold(0, (sum, zap) => sum + zap.amount),
  commentsCount: note.replies.length,
  
  // User interaction state
  isLiked: userHasLiked,
  isReposted: userHasReposted,
  isZapped: userHasZapped,
  
  // Callbacks for user actions
  onLike: () async {
    final reaction = PartialReaction(
      reactedOn: note,
      emojiTag: ('+', null), // Standard like reaction
    );
    final signedReaction = await reaction.signWith(signer);
    await ref.storage.publish({signedReaction});
  },
  
  onRepost: () async {
    final repost = PartialRepost(originalEvent: note);
    final signedRepost = await repost.signWith(signer);
    await ref.storage.publish({signedRepost});
  },
  
  onZap: () {
    // Handle zap action (open zap dialog, etc.)
    showZapDialog(context, note);
  },
  
  onComment: () {
    // Navigate to reply screen or show comment composer
    Navigator.push(context, ReplyScreen(parentNote: note));
  },
)
```

**Required Relationships:**

When using `EngagementRow`, ensure your note query includes the necessary relationships:

```dart
final notesState = ref.watch(
  query<Note>(
    limit: 50,
    and: (note) => {
      note.author,      // For author info
      note.reactions,   // For likes count
      note.reposts,     // For reposts count  
      note.zaps,        // For zaps count and sat amounts
      note.replies,     // For comments count (optional)
    },
  ),
);
```

**Features:**
- **Smart formatting**: Large numbers display as "1.2K", "3.4M" etc.
- **Active states**: Different colors when user has engaged
- **Zap amounts**: Shows total sats if available, otherwise zap count
- **Optional comments**: Include `commentsCount` to show reply count
- **Material 3 design**: Consistent with app theming
- **Tap targets**: Proper touch areas with ripple effects

#### Use in Filters

The base Nostr protocol uses hex string identifiers when filtering by event IDs and pubkeys. Nostr filters only accept hex strings.

```dart
// ❌ Wrong: naddr is not decoded
final models = await ref.storage.query(ids: {naddr});
```

Corrected example:

```dart
// Decode a NIP-19 identifier
final naddr = Utils.decodeShareableIdentifier(value);

// Optional: guard certain types (depending on the use-case)
if (naddr is! AddressData) {
  throw new Error('Unsupported Nostr identifier');
}

// ✅ Correct: naddr is expanded into the correct filter
final models = await ref.storage.query(
  kinds: {naddr.kind},
  authors: {naddr.author},
  tags: {'#d': {naddr.identifier}},
);
```

### Uploading Files on Nostr

Use the Blossom protocol (https://github.com/hzrd149/blossom) to interact with file servers based on file hashes. The `models` package includes support for Blossom authorization events.

**Basic File Upload Flow:**

```dart
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

// 1. Calculate file hash and prepare authorization
final file = File(originalFilePath);
final bytes = await file.readAsBytes();
final assetHash = sha256.convert(bytes).toString();
final mimeType = lookupMimeType(originalFilePath);

// 2. Create Blossom authorization event
final partialAuthorization = PartialBlossomAuthorization()
  ..content = 'Upload asset $originalFilePath'
  ..type = BlossomAuthorizationType.upload
  ..mimeType = mimeType
  ..expiration = DateTime.now().add(Duration(hours: 1))
  ..hash = assetHash;

final authorization = await partialAuthorization.signWith(signer);

// 3. Check if file already exists on server
final assetUploadUrl = '$server/$assetHash';
final headResponse = await http.head(Uri.parse(assetUploadUrl));

if (headResponse.statusCode == 200) {
  // File already exists, use existing URL
  print('File already exists at: $assetUploadUrl');
} else {
  // 4. Upload file to Blossom server
  final response = await http.put(
    Uri.parse(path.join(server.toString(), 'upload')),
    body: bytes,
    headers: {
      if (authorization.mimeType != null)
        'Content-Type': authorization.mimeType!,
      'Authorization': 'Nostr ${authorization.toBase64()}',
    },
  );

  if (response.statusCode == 200) {
    print('File uploaded successfully to: $assetUploadUrl');
  } else {
    throw Exception('Upload failed: ${response.statusCode} ${response.body}');
  }
}
```

**File Deletion:**

```dart
// Create deletion authorization
final deleteAuth = PartialBlossomAuthorization()
  ..content = 'Delete asset $assetHash'
  ..type = BlossomAuthorizationType.delete
  ..expiration = DateTime.now().add(Duration(hours: 1))
  ..hash = assetHash;

final signedDeleteAuth = await deleteAuth.signWith(signer);

// Delete from server
final deleteResponse = await http.delete(
  Uri.parse('$server/$assetHash'),
  headers: {
    'Authorization': 'Nostr ${signedDeleteAuth.toBase64()}',
  },
);
```

**Attaching Files to Events:**

To attach files to kind 1 events, each file's URL should be appended to the event's `content`, and an `imeta` tag should be added for each file. For kind 0 events, the URL by itself can be used in relevant fields of the JSON content.

```dart
// After uploading via Blossom, attach to note
final noteContent = 'Check out this image! $assetUploadUrl';
final note = PartialNote(noteContent)
  ..addTag('imeta', [
    'url $assetUploadUrl',
    if (mimeType != null) 'm $mimeType',
    'x $assetHash',
  ]);

final signedNote = await note.signWith(signer);
await ref.storage.publish({signedNote});
```

### Nostr Encryption and Decryption

The `Signer` interface has methods for:

 - `nip04Encrypt`
 - `nip04Decrypt`
 - `nip44Encrypt`
 - `nip44Decrypt`

Signers can be obtained via the `signerProvider` family or `activeSignerProvider`.

The signer's nip44 methods handle all cryptographic operations internally, including key derivation and conversation key management, so you never need direct access to private keys. Always use the signer interface for encryption rather than requesting private keys from users, as this maintains security and follows best practices.

**NIP-04 Encryption Example:**
```dart
// Encrypt a message using NIP-04
final signer = ref.read(Signer.activeSignerProvider);
final recipientPubkey = 'npub1abc123...';

// Encrypt the message
final encryptedContent = await signer.nip04Encrypt(
  message: 'Hello, this is a secret message!',
  recipientPubkey: recipientPubkey,
);

// Create and sign the encrypted direct message
final dm = PartialDirectMessage.encrypted(
  encryptedContent: encryptedContent,
  receiver: recipientPubkey,
);

final signedDm = await dm.signWith(signer);
await ref.storage.save({signedDm});
```

**NIP-44 Encryption Example (Recommended):**
```dart
// Encrypt a message using NIP-44 (more secure)
final signer = ref.read(Signer.activeSignerProvider);
final recipientPubkey = 'npub1abc123...';

// Encrypt the message with NIP-44
final encryptedContent = await signer.nip44Encrypt(
  message: 'Hello, this is a secret message!',
  recipientPubkey: recipientPubkey,
);

// Create and sign the encrypted direct message
final dm = PartialDirectMessage.encrypted(
  encryptedContent: encryptedContent,
  receiver: recipientPubkey,
);

final signedDm = await dm.signWith(signer);
await ref.storage.save({signedDm});
```

**Decrypting Messages:**
```dart
// Query for encrypted messages
final dmsState = ref.watch(
  query<DirectMessage>(
    authors: {signer.pubkey},
    tags: {'#p': {recipientPubkey}},
  ),
);

// Decrypt messages in UI
class MessageTile extends StatelessWidget {
  final DirectMessage dm;
  
  const MessageTile({required this.dm, super.key});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: dm.decryptContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text('Decrypting...'),
            subtitle: Text(dm.encryptedContent),
          );
        }
        
        if (snapshot.hasError) {
          return ListTile(
            title: Text('Failed to decrypt'),
            subtitle: Text('Message may be corrupted or from different encryption method'),
          );
        }
        
        return ListTile(
          title: Text(snapshot.data ?? 'Empty message'),
          subtitle: Text(dm.createdAt.toString()),
        );
      },
    );
  }
}
```

**Key Differences:**
- **NIP-04**: Legacy encryption method, simpler but less secure
- **NIP-44**: Modern encryption with better security, forward secrecy, and metadata protection
- Always prefer NIP-44 for new applications unless compatibility with older clients is required

### Custom data

Any time you need to store custom data, use the `CustomData` model from the `models` package. Use `setProperty` to set tags, and feel free to use encryption as defined above for sensitive data (NWC strings, cashu tokens, for example).

## Error Handling and Debugging

### Automatic Error Handling

The underlying `models` implementation (via the `purplebase` package) automatically handles all low-level Nostr protocol errors:

- **Relay connections**: Connection failures, timeouts, reconnection logic
- **Malformed events**: Invalid event structure, missing fields, parsing errors
- **Signature verification**: BIP-340 signature validation and rejection of invalid events
- **Network timeouts**: Request timeouts and retry mechanisms
- **Rate limiting**: Relay rate limit handling and backoff strategies

**Important**: Your UI code does not need to handle these low-level errors. The storage layer manages all protocol-level error recovery automatically.

### Debug Information Provider

For debugging and monitoring, Purplebase exposes the `infoNotifierProvider` which streams diagnostic messages about the Nostr operations:

```dart
// Listen to debug info in your app
ref.listen(infoNotifierProvider, (previous, next) {
  print('Nostr Debug: $next');
  // Or display in a debug screen, log to file, etc.
});
```

Use this provider to:
- Monitor relay connection status
- Debug event publishing issues
- Track storage operations
- Monitor network performance
- Troubleshoot synchronization problems

## Security and Environment

### API Key Management

**No API keys are required or handled** in Purplestack projects. The Nostr protocol is decentralized and does not require API keys for accessing relays or publishing events.

### Private Key Security

#### Default: In-Memory Storage
By default, private keys (nsec) are handled in-memory only when using `Bip340PrivateKeySigner`:

```dart
// Private key is only stored in memory during app session
final signer = Bip340PrivateKeySigner(privateKeyHex, ref);
await signer.initialize();

// When app closes, private key is lost and user must re-enter
```

#### Persistent Key Storage

If the user specifically requests persistent nsec signing, use the `flutter_secure_storage` package. Do NOT use this storage for regular data storage, use `CustomData` as instructed before.

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureSignerManager {
  static const _storage = FlutterSecureStorage();
  static const _keyPrivateKey = 'nostr_private_key';

  // Store private key securely
  static Future<void> storePrivateKey(String privateKey) async {
    await _storage.write(key: _keyPrivateKey, value: privateKey);
  }

  // Retrieve private key
  static Future<String?> getPrivateKey() async {
    return await _storage.read(key: _keyPrivateKey);
  }

  // Clear stored private key
  static Future<void> clearPrivateKey() async {
    await _storage.delete(key: _keyPrivateKey);
  }

  // Initialize signer from secure storage
  static Future<Bip340PrivateKeySigner?> initializeFromStorage(WidgetRef ref) async {
    final privateKey = await getPrivateKey();
    if (privateKey != null) {
      return Bip340PrivateKeySigner(privateKey, ref);
    }
    return null;
  }
}
```

**Security Note**: Only implement persistent private key storage if explicitly requested by the user. The default and recommended approach is to use the `amber_signer` package with NIP-55 compatible signing apps like Amber.

### Rendering Rich Text Content

Nostr text notes (kind 1, 11, and 1111) have a plaintext `content` field that may contain URLs, hashtags, and Nostr URIs.

Use the `NoteParser` class (and utilities in the `note_parser.dart` file) for this.
# models 👯

Fast local-first nostr framework designed to make developers (and vibe-coders) happy. Written in Dart.

It provides:
 - Domain-specific models that wrap common nostr event kinds (with relationships between them)
 - A local-first model storage and relay interface, leveraging reactive Riverpod providers
 - Easy extensibility

An offline-ready app with reactions/zaps in a few lines of code:

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final value = ref.watch(
    query<Note>(
      limit: 10,
      authors: {npub1, npub2, npub3, ...},
      and: (note) => {note.author, note.reactions, note.zaps},
    ),
  );
  // ...
  Column(children: [
    for (final note in value.models)
      NoteCard(
        userName: note.author.value!.nameOrNpub,
        noteText: note.content,
        timestamp: note.createdAt,
        likes: note.reactions.length,
        zaps: note.zaps.length,
        zapAmount: note.zaps.toList().fold(0, (acc, e) => acc += e.amount),
      )
  ])
```

Current implementations:
  - Dummy: In-memory storage and relay fetch simulation, for testing and prototyping (default, included)
  - [Purplebase](https://github.com/purplebase/purplebase): SQLite-powered storage and an efficient relay pool

## Features ✨

 - **Domain models**: Instead of NIP-jargon, use type-safe classes with domain language to interact with nostr, many common nostr event kinds are available (or bring your own)
 - **Relationships**: Smoothly navigate local storage with model relationships
 - **Watchable queries**: Reactive querying interface with a familiar nostr request filter API
 - **Signers**: Construct new nostr events and sign them using Amber (Android) and other NIP-55 signers available via external packages
 - **Reactive signed-in profile provider**: Keep track of signed in pubkeys and the current active user in your application
 - **Dummy implementation**: Plug-and-play implementation for testing/prototyping, easily generate dummy profiles, notes, and even a whole feed
 - **Raw events**: Access lower-level nostr event data (`event` property on all models)
 - and much more

## Installation 🛠️

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  models:
    git: # git until we put it on pub.dev
      url: https://github.com/purplebase/models
      ref: 0.1.0
```

Then run `dart pub get` or `flutter pub get`.

## Table of Contents 📜

- [Quickstart 🚀](#quickstart-)
- [Core Concepts 🧠](#core-concepts-)
  - [Models & Partial Models](#models--partial-models)
  - [Relationships](#relationships)
  - [Querying](#querying)
  - [Storage & Relays](#storage--relays)
  - [Source Behavior](#source-behavior)
- [Recipes 🍳](#recipes-)
  - [Signer Interface & Authentication](#signer-interface--authentication)
  - [Building a Feed](#building-a-feed)
  - [Creating Custom Event Kinds](#creating-custom-event-kinds)
  - [Using the `and` Operator for Relationships](#using-the-and-operator-for-relationships)
  - [Direct Messages & Encryption](#direct-messages--encryption)
  - [Working with DVMs (NIP-90)](#working-with-dvms-nip-90)
- [API Reference 📚](#api-reference-)
  - [Storage Configuration](#storage-configuration)
  - [Query Filters](#query-filters)
  - [Model Types](#model-types)
  - [Utilities](#utilities)
  - [Event Verification](#event-verification)
  - [Error Handling](#error-handling)
- [Design Notes 📝](#design-notes-)
- [Contributing 🙏](#contributing-)
- [License 📄](#license-)

## Quickstart 🚀

Here is a minimal Flutter/Riverpod app that shows a user's notes and replies.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';

void main() => runApp(ProviderScope(child: MaterialApp(home: NotesScreen())));

class NotesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(initializationProvider(StorageConfiguration()))) {
      AsyncLoading() => Center(child: CircularProgressIndicator()),
      AsyncError() => Center(child: Text('Error initializing')),
      _ => Scaffold(
        body: Consumer(
          builder: (context, ref, _) {
            final activePubkey = ref.watch(Signer.activePubkeyProvider);
            if (activePubkey == null) {
              return Center(child: Text('Please sign in'));
            }
            
            final notesState = ref.watch(
              query<Note>(
                authors: {activePubkey},
                limit: 100,
                and: (note) => {
                  note.author,      // Include author profile
                  note.reactions,   // Include reactions
                  note.zaps,        // Include zaps
                  note.root,        // Include root note for replies
                  note.replies,     // Include direct replies
                },
              ),
            );
            
            return switch (notesState) {
              StorageLoading() => Center(child: CircularProgressIndicator()),
              StorageError() => Center(child: Text('Error loading notes')),
              StorageData() => ListView.builder(
                itemCount: notesState.models.length,
                itemBuilder: (context, index) {
                  final note = notesState.models[index];
                  return NoteCard(note: note);
                },
              ),
            };
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            final signer = ref.read(Signer.activeSignerProvider);
            if (signer != null) {
              final newNote = await PartialNote('Hello, nostr!').signWith(signer);
              await ref.storage.save({newNote});
            }
          },
        ),
      ),
    };
  }
}

class NoteCard extends StatelessWidget {
  final Note note;
  
  const NoteCard({required this.note, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    note.author.value?.pictureUrl ?? '',
                  ),
                ),
                SizedBox(width: 8),
                Text(note.author.value?.nameOrNpub ?? 'Unknown'),
              ],
            ),
            SizedBox(height: 8),
            
            // Note content
            Text(note.content),
            SizedBox(height: 8),
            
            // Reply indicator
            if (note.root.value != null)
              Text('↳ Reply to ${note.root.value!.author.value?.nameOrNpub ?? 'Unknown'}'),
            
            // Engagement metrics
            Row(
              children: [
                Icon(Icons.favorite, size: 16),
                Text('${note.reactions.length}'),
                SizedBox(width: 16),
                Icon(Icons.flash_on, size: 16),
                Text('${note.zaps.length}'),
                SizedBox(width: 16),
                Icon(Icons.reply, size: 16),
                Text('${note.replies.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

**Flutter Syntax Sugar** (Optional): For Flutter apps, you can add this extension for cleaner syntax:

```dart
extension WidgetRefStorage on WidgetRef {
  StorageNotifier get storage => read(storageNotifierProvider.notifier);
}
```

## NIP Implementation Status 📋

- [x] **NIP-01: Basic protocol flow description**
- [x] **NIP-02: Follow List**
- [x] **NIP-04: Encrypted Direct Message**
- [x] **NIP-05: Mapping Nostr keys to DNS-based internet identifiers**
- [x] **NIP-09: Event Deletion Request**
- [x] **NIP-10: Text Notes and Threads**
- [x] **NIP-11: Relay Information Document**
- [x] **NIP-18: Reposts**
- [x] **NIP-19: bech32-encoded entities**
- [x] **NIP-21: `nostr:` URI scheme**
- [x] **NIP-22: Comment**
- [x] **NIP-23: Long-form Content**
- [x] **NIP-25: Reactions**
- [x] **NIP-28: Public Chat**
- [x] **NIP-29: Relay-based Groups**
- [x] **NIP-39: External Identities in Profiles**
- [x] **NIP-42: Authentication of clients to relays**
- [x] **NIP-44: Encrypted Payloads (Versioned)**
- [x] **NIP-51: Lists**
- [x] **NIP-55: Android Signer Application**
- [x] **NIP-57: Lightning Zaps**
- [x] **NIP-65: Relay List Metadata**
- [x] **NIP-72: Moderated Communities (Reddit Style)**
- [x] **NIP-78: Arbitrary custom app data**
- [x] **NIP-82: Application metadata, releases, assets** _(draft)_
- [x] **NIP-90: Data Vending Machine**
- [x] **NIP-94: File Metadata**

## Core Concepts 🧠

### Models & Partial Models

Models represent signed, immutable nostr events with domain-specific properties. Each model has a corresponding `PartialModel` for creation and signing.

```dart
// Immutable, signed model
final note = Note.fromMap(eventData, ref);
print(note.content); // Access domain properties

// Mutable, unsigned partial model for creation
final partialNote = PartialNote('Hello, nostr!');
final signedNote = await partialNote.signWith(signer);
```

**Converting Models to Partial Models:**

Models can be converted back to editable partial models using the `toPartial()` method:

```dart
// Load an existing note
final note = await ref.storage.get<Note>(noteId);

// Convert to partial for editing
final partialNote = note.toPartial<PartialNote>();

// Modify and re-sign
partialNote.content = 'Updated content';
final updatedNote = await partialNote.signWith(signer);
```

**Important Notes:**
- All public APIs work with "models" (all of which can access the underlying nostr event representation via `model.event`)
- All notifier events are already emitted sorted by `created_at` by the framework - no need to sort again

### Relationships

Models automatically establish relationships with other models:

```dart
// One-to-one relationship (BelongsTo<Profile>)
final author = note.author.value;

// One-to-many relationships (HasMany<Reaction>, HasMany<Zap>)
final reactions = note.reactions.toList();
final zaps = note.zaps.toList();
```

### Querying

Use the `query` function to reactively watch for models:

```dart
final notesState = ref.watch(
  query<Note>(
    authors: {userPubkey},
    limit: 20,
    since: DateTime.now().subtract(Duration(days: 7)),
  ),
);

// Access models and handle loading/error states
switch (notesState) {
  case StorageLoading():
    return CircularProgressIndicator();
  case StorageError():
    return Text('Error loading notes');
  case StorageData():
    return ListView.builder(
      itemCount: notesState.models.length,
      itemBuilder: (context, index) => NoteCard(notesState.models[index]),
    );
}
```

### Storage & Relays

Storage provides a unified interface for local persistence and relay communication:

```dart
// Save locally
await note.save();

// Publish to relays
await note.publish(source: RemoteSource(group: 'social'));

// Query from local storage only
final localNotes = await ref.storage.query(
  RequestFilter<Note>(authors: {pubkey}).toRequest(),
  source: LocalSource(),
);

// Query from relays only
final remoteNotes = await ref.storage.query(
  RequestFilter<Note>(authors: {pubkey}).toRequest(),
  source: RemoteSource(),
);

// Query locally and from relays in the background
final remoteNotes = await ref.storage.query(
  RequestFilter<Note>(authors: {pubkey}).toRequest(),
  source: LocalAndRemoteSource(background: true),
);
```

Note that `background: false` means waiting for EOSE. The streaming phase is always in the background.

### Source Behavior

The `Source` parameter controls where data comes from and how queries behave:

**LocalSource**: Only query local storage, never contact relays
```dart
source: LocalSource()
```

**RemoteSource**: Only query relays, never use local storage
```dart
source: RemoteSource(
  group: 'social',        // Use specific relay group (defaults to 'default')
  stream: true,           // Enable streaming (default)
  background: false,      // Wait for EOSE before returning
)
```

**LocalAndRemoteSource**: Query both local storage and relays
```dart
source: LocalAndRemoteSource(
  group: 'social',        // Use specific relay group (defaults to 'default')
  stream: true,           // Enable streaming (default)
  background: true,       // Don't wait for EOSE
)
```

**Query Behavior**:
- All queries block until local storage returns results
- If `background: false`, queries additionally block until EOSE from relays
- If `background: true`, queries return immediately after local results, relay results stream in
- The streaming phase never blocks regardless of `background` setting

## Recipes 🍳

### Signer Interface & Authentication

The signer system manages authentication and signing across your app.

**Basic Signer Setup:**

```dart
// Create a private key signer
final privateKey = 'your_private_key_here';
final signer = Bip340PrivateKeySigner(privateKey, ref);

// Initialize (sets the pubkey as active)
await signer.initialize();

// Check if signer is available for use
final isAvailable = await signer.isAvailable;

// Watch the active profile (use RemoteSource() if you want to fetch from relays)
final activeProfile = ref.watch(Signer.activeProfileProvider(LocalSource()));
final activePubkey = ref.watch(Signer.activePubkeyProvider);
```

**Multiple Account Management:**

```dart
// Sign in multiple accounts
final signer1 = Bip340PrivateKeySigner(privateKey1, ref);
final signer2 = Bip340PrivateKeySigner(privateKey2, ref);

await signer1.initialize(active: false); // Don't set as active
await signer2.initialize(active: true);  // Set as active

// Switch between accounts
signer1.setActive();
signer2.removeActive();

// Get all signed-in accounts
final signedInPubkeys = ref.watch(Signer.signedInPubkeysProvider);
```

**Active Profile with Different Sources:**

```dart
// Get active profile from local storage only
final localProfile = ref.watch(Signer.activeProfileProvider(LocalSource()));

// Get active profile from local storage and relays
final fullProfile = ref.watch(Signer.activeProfileProvider(LocalAndRemoteSource()));

// Get active profile from specific relay group
final socialProfile = ref.watch(Signer.activeProfileProvider(
  RemoteSource(group: 'social'),
));
```

The [amber_signer](https://github.com/purplebase/amber_signer) package implements this interface for Amber / NIP-55.

**Sign Out Flow:**

```dart
// Clean up when user signs out
await signer.dispose();

// The active profile provider will automatically update
// as the signer is removed from the system
```

### Building a Feed

Create a reactive feed that updates in real-time.

**Home Feed with Relationships:**

```dart
class HomeFeed extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(Signer.activeProfileProvider(LocalSource()));
    
    if (activeProfile == null) {
      return Center(child: Text('Please sign in'));
    }
    
    // Get following pubkeys from contact list
    final following = activeProfile.contactList.value?.followingPubkeys ?? {};
    
    final feedState = ref.watch(
      query<Note>(
        authors: following,
        limit: 50,
        and: (note) => {
          note.author,           // Include author profile
          note.reactions,        // Include reactions
          note.zaps,            // Include zaps
          note.root,            // Include root note for replies
        },
      ),
    );
    
    return switch (feedState) {
      StorageLoading() => Center(child: CircularProgressIndicator()),
      StorageError() => Center(child: Text('Error loading feed')),
      StorageData() => ListView.builder(
        itemCount: feedState.models.length,
        itemBuilder: (context, index) {
          final note = feedState.models[index];
          return FeedItemCard(note: note);
        },
      ),
    };
  }
}

class FeedItemCard extends StatelessWidget {
  final Note note;
  
  const FeedItemCard({required this.note, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    note.author.value?.pictureUrl ?? '',
                  ),
                ),
                SizedBox(width: 8),
                Text(note.author.value?.nameOrNpub ?? 'Unknown'),
              ],
            ),
            SizedBox(height: 8),
            
            // Note content
            Text(note.content),
            SizedBox(height: 8),
            
            // Engagement metrics
            Row(
              children: [
                Icon(Icons.favorite, size: 16),
                Text('${note.reactions.length}'),
                SizedBox(width: 16),
                Icon(Icons.flash_on, size: 16),
                Text('${note.zaps.length}'),
                SizedBox(width: 16),
                Text(note.createdAt.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

**Real-time Updates:**

```dart
// The feed automatically updates when new notes arrive
// thanks to the reactive query system

// You can also manually trigger updates
final storage = ref.read(storageNotifierProvider.notifier);

// Save a new note and it will appear in the feed
final newNote = await PartialNote('Hello, world!').signWith(signer);
await storage.save({newNote});
```

### Creating Custom Event Kinds

Extend the system with your own event kinds.

**Basic Custom Model:**

```dart
@GeneratePartialModel()
class Joke extends RegularModel<Joke> {
  Joke.fromMap(super.map, super.ref) : super.fromMap();
  
  String? get title => event.getFirstTagValue('title');
  String get punchline => event.content;
  DateTime? get publishedAt => 
      event.getFirstTagValue('published_at')?.toInt()?.toDate();
}

class PartialJoke extends RegularPartialModel<Joke> with PartialJokeMixin {
  PartialJoke({
    required String title,
    required String punchline,
    DateTime? publishedAt,
  }) {
    event.content = punchline;
    event.addTagValue('title', title);
    if (publishedAt != null) {
      event.addTagValue('published_at', publishedAt.toSeconds().toString());
    }
  }
}
```

**Registering Custom Kinds:**

```dart
// Create a custom initialization provider
final customInitializationProvider = FutureProvider((ref) async {
  await ref.read(initializationProvider(StorageConfiguration()).future);
  
  // Register your custom models
  Model.register(kind: 1055, constructor: Joke.fromMap);
  Model.register(kind: 1056, constructor: Meme.fromMap);
  
  return true;
});

// Use this provider instead of the default one
final initState = ref.watch(customInitializationProvider);
```

**Using Custom Models:**

```dart
// Create and sign a joke
final partialJoke = PartialJoke(
  title: 'The Time Traveler',
  punchline: 'I was going to tell you a joke about time travel... but you didn\'t like it.',
  publishedAt: DateTime.now(),
);

final signedJoke = await partialJoke.signWith(signer);

// Save to storage
await ref.storage.save({signedJoke});

// Query jokes
final jokesState = ref.watch(
  query<Joke>(
    authors: {signer.pubkey},
    limit: 10,
  ),
);
```

**Different Model Types:**

```dart
// Regular events (kind 1-9999)
class RegularEvent extends RegularModel<RegularEvent> {
  RegularEvent.fromMap(super.map, super.ref) : super.fromMap();
}

// Replaceable events (kind 0, 3, 10000-19999)
class ReplaceableEvent extends ReplaceableModel<ReplaceableEvent> {
  ReplaceableEvent.fromMap(super.map, super.ref) : super.fromMap();
}

// Parameterizable replaceable events (kind 30000-39999)
class ParameterizableEvent extends ParameterizableReplaceableModel<ParameterizableEvent> {
  ParameterizableEvent.fromMap(super.map, super.ref) : super.fromMap();
  
  String get identifier => event.identifier; // d-tag value
}

// Ephemeral events (kind 20000-29999)
class EphemeralEvent extends EphemeralModel<EphemeralEvent> {
  EphemeralEvent.fromMap(super.map, super.ref) : super.fromMap();
}
```

### Using the `and` Operator for Relationships

The `and` operator enables reactive relationship loading and updates.

**Basic Relationship Loading:**

```dart
// Load notes with their authors and reactions
final notesState = ref.watch(
  query<Note>(
    limit: 20,
    and: (note) => {
      note.author,      // Load author profile
      note.reactions,   // Load reactions
      note.zaps,        // Load zaps
    },
  ),
);
```

**Nested Relationships:**

```dart
// Load notes with nested relationship data
final notesState = ref.watch(
  query<Note>(
    limit: 20,
    and: (note) => {
      note.author,      // Author profile
      note.reactions,   // Reactions
      ...note.reactions.map((reaction) => reaction.author), // Reaction authors
      note.zaps,        // Zaps
      ...note.zaps.map((zap) => zap.author), // Zap authors
    },
  ),
);
```

**Conditional Relationship Loading:**

```dart
// Only load relationships for notes with content
final notesState = ref.watch(
  query<Note>(
    limit: 20,
    and: (note) => {
      if (note.content.isNotEmpty) ...[
        note.author,
        note.reactions,
      ],
    },
  ),
);
```

**Relationship Updates:**

```dart
// When a new reaction is added, all queries watching that note
// will automatically update thanks to the relationship system

final newReaction = await PartialReaction(
  reactedOn: note,
  emojiTag: ('+', 'https://example.com/plus.png'),
).signWith(signer);

await ref.storage.save({newReaction});

// The note's reactions relationship will automatically update
// and any UI watching it will rebuild
```

**Community Chat Messages:**

```dart
// Load a community with its chat messages
final communityState = ref.watch(
  query<Community>(
    ids: {communityId},
    and: (community) => {
      community.chatMessages, // Load associated chat messages
    },
  ),
);

// Access the chat messages
final community = communityState.models.first;
final messages = community.chatMessages.toList();
```

### Direct Messages & Encryption

Create encrypted direct messages using NIP-04 and NIP-44.

**Creating Encrypted Messages:**

```dart
// Create a message with automatic encryption
final dm = PartialDirectMessage(
  content: 'Hello, this is a secret message!',
  receiver: 'npub1abc123...', // Recipient's npub
  useNip44: true, // Use NIP-44 (more secure) or false for NIP-04
);

// Sign and encrypt the message
final signedDm = await dm.signWith(signer);

// Save to storage
await ref.storage.save({signedDm});
```

**Decrypting Messages:**

```dart
// Query for direct messages
final dmsState = ref.watch(
  query<DirectMessage>(
    authors: {signer.pubkey}, // Messages we sent
    tags: {'#p': {recipientPubkey}}, // Messages to specific recipient
  ),
);

// In your UI, decrypt messages asynchronously
class MessageTile extends StatelessWidget {
  final DirectMessage dm;
  
  const MessageTile({required this.dm, super.key});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: dm.decryptContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text('Decrypting...'),
            subtitle: Text(dm.encryptedContent),
          );
        }
        
        return ListTile(
          title: Text(snapshot.data ?? 'Failed to decrypt'),
          subtitle: Text(dm.createdAt.toString()),
        );
      },
    );
  }
}
```

**Message Threads:**

```dart
// Create a conversation view
class ConversationView extends ConsumerWidget {
  final String otherPubkey;
  
  const ConversationView({required this.otherPubkey, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesState = ref.watch(
      query<DirectMessage>(
        authors: {signer.pubkey, otherPubkey},
        tags: {'#p': {signer.pubkey, otherPubkey}},
        limit: 100,
      ),
    );
    
    return switch (messagesState) {
      StorageLoading() => Center(child: CircularProgressIndicator()),
      StorageError() => Center(child: Text('Error loading messages')),
      StorageData() => ListView.builder(
        reverse: true,
        itemCount: messagesState.models.length,
        itemBuilder: (context, index) {
          final dm = messagesState.models[index];
          final isFromMe = dm.event.pubkey == signer.pubkey;
          
          return MessageBubble(
            message: dm,
            isFromMe: isFromMe,
          );
        },
      ),
    };
  }
}
```

**Pre-encrypted Messages:**

```dart
// For messages already encrypted by external systems
final preEncryptedDm = PartialDirectMessage.encrypted(
  encryptedContent: 'A1B2C3...', // Already encrypted content
  receiver: 'npub1abc123...',
);

final signedDm = await preEncryptedDm.signWith(signer);
```

### Working with DVMs (NIP-90)

Interact with Decentralized Virtual Machines for reputation verification and other services.

**Creating DVM Requests:**

```dart
// Create a reputation verification request
final request = PartialVerifyReputationRequest(
  source: 'npub1source123...',
  target: 'npub1target456...',
);

final signedRequest = await request.signWith(signer);

// Run the DVM request
final response = await signedRequest.run('default'); // relay group

if (response != null) {
  if (response is VerifyReputationResponse) {
    print('Reputation verified: ${response.pubkeys}');
  } else if (response is DVMError) {
    print('DVM error: ${response.status}');
  }
}
```

**Custom DVM Models:**

```dart
// Create your own DVM request model
class CustomDVMRequest extends RegularModel<CustomDVMRequest> {
  CustomDVMRequest.fromMap(super.map, super.ref) : super.fromMap();
  
  Future<Model<dynamic>?> run(String relayGroup) async {
    final source = RemoteSource(group: relayGroup);
    
    // Publish the request
    await storage.publish({this}, source: source);
    
    // Wait for responses
    final responses = await storage.query(
      RequestFilter(
        kinds: {7001}, // Your response kind
        tags: {'#e': {event.id}}, // Reference to this request
      ).toRequest(),
      source: source,
    );
    
    return responses.firstOrNull;
  }
}

class PartialCustomDVMRequest extends RegularPartialModel<CustomDVMRequest> {
  PartialCustomDVMRequest({
    required String parameter1,
    required String parameter2,
  }) {
    event.addTag('param', ['param1', parameter1]);
    event.addTag('param', ['param2', parameter2]);
  }
}
```

**DVM Response Handling:**

```dart
// Handle different types of DVM responses
class DVMResponseHandler {
  static void handleResponse(Model<dynamic> response) {
    switch (response) {
      case VerifyReputationResponse():
        print('Reputation verified: ${response.pubkeys}');
        break;
      case DVMError():
        print('DVM error: ${response.status}');
        break;
      case CustomDVMResponse():
        print('Custom response: ${response.data}');
        break;
      default:
        print('Unknown response type');
    }
  }
}

// Use in your app
final response = await dvmRequest.run('default');
if (response != null) {
  DVMResponseHandler.handleResponse(response);
}
```

**DVM Error Handling:**

```dart
// Robust DVM interaction with error handling
Future<Model<dynamic>?> runDVMWithRetry(
  Model<dynamic> request,
  String relayGroup, {
  int maxRetries = 3,
  Duration delay = Duration(seconds: 5),
}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      final response = await request.run(relayGroup);
      
      if (response is DVMError) {
        print('DVM error on attempt $attempt: ${response.status}');
        if (attempt < maxRetries) {
          await Future.delayed(delay);
          continue;
        }
      }
      
      return response;
    } catch (e) {
      print('DVM request failed on attempt $attempt: $e');
      if (attempt < maxRetries) {
        await Future.delayed(delay);
        continue;
      }
      rethrow;
    }
  }
  
  return null;
}
```

## API Reference 📚

### Storage Configuration

Configure storage behavior and relay connections.

```dart
final config = StorageConfiguration(
  // Database path (null for in-memory)
  databasePath: '/path/to/database.sqlite',
  
  // Whether to keep signatures in local storage
  keepSignatures: false,
  
  // Whether to skip BIP-340 verification
  skipVerification: false,
  
  // Relay groups
  relayGroups: {
    'popular': {
      'wss://relay.damus.io',
      'wss://relay.primal.net',
    },
    'private': {
      'wss://my-private-relay.com',
    },
  },
  
  // Default relay group
  defaultRelayGroup: 'popular',
  
  // Default source for queries when not specified
  defaultQuerySource: LocalAndRemoteSource(stream: false),
  
  // Connection timeouts
  idleTimeout: Duration(minutes: 5),
  responseTimeout: Duration(seconds: 6),
  
  // Streaming configuration
  streamingBufferWindow: Duration(seconds: 2),
  
  // Storage limits
  keepMaxModels: 20000,
);
```

### Query Filters

Build complex queries with multiple conditions.

```dart
// Basic filters
final basicQuery = query<Note>(
  authors: {pubkey1, pubkey2},
  limit: 50,
  since: DateTime.now().subtract(Duration(days: 7)),
);

// Tag-based filters
final tagQuery = query<Note>(
  tags: {
    '#t': {'nostr', 'flutter'},
    '#e': {noteId},
  },
);

// Search queries
final searchQuery = query<Note>(
  search: 'hello world',
  limit: 20,
);

// Complex filters with relationships
final complexQuery = query<Note>(
  authors: {pubkey},
  kinds: {1, 6}, // Notes and reposts
  since: DateTime.now().subtract(Duration(hours: 24)),
  and: (note) => {
    note.author,
    note.reactions,
    note.zaps,
  },
);
```

### Model Types

Available built-in models and their relationships.

**Core Models:**
- `Profile` (kind 0) - User profiles with metadata
- `Note` (kind 1) - Text posts with reply threading
- `ContactList` (kind 3) - Following/followers
- `DirectMessage` (kind 4) - Encrypted private messages
- `Repost` (kind 6) - Reposts of other notes (NIP-18)
- `Reaction` (kind 7) - Emoji reactions to events
- `ChatMessage` (kind 9) - Public chat messages

**Content Models:**
- `Article` (kind 30023) - Long-form articles
- `App` (kind 32267) - App metadata and listings
- `Release` (kind 30063) - Software releases
- `FileMetadata` (kind 1063) - File information with release relationship
- `SoftwareAsset` (kind 3063) - Software binaries

**Social Models:**
- `Community` (kind 10222) - Community definitions with chatMessages relationship
- `TargetedPublication` (kind 30222) - Targeted content
- `Comment` (kind 1111) - Comments on content

**Monetization:**
- `ZapRequest` (kind 9734) - Lightning payment requests
- `Zap` (kind 9735) - Lightning payments

**DVM Models:**
- `VerifyReputationRequest` (kind 5312) - Reputation verification
- `VerifyReputationResponse` (kind 6312) - Reputation results
- `DVMError` (kind 7000) - DVM error responses

### Utilities

The `Utils` class provides essential nostr-related utilities.

**Key Management:**
```dart
// Generate cryptographically secure random hex
final randomHex = Utils.generateRandomHex64();

// Derive public key from private key
final pubkey = Utils.derivePublicKey(privateKey);
```

**NIP-19 Encoding/Decoding:**
```dart
// Encode simple entities
final npub = Utils.encodeShareableFromString(pubkey, type: 'npub');
final nsec = Utils.encodeShareableFromString(privateKey, type: 'nsec');
final note = Utils.encodeShareableFromString(eventId, type: 'note');

// Decode simple entities
final decodedPubkey = Utils.decodeShareableToString(npub);
final decodedPrivateKey = Utils.decodeShareableToString(nsec); // nsec is always decoded as a string
final decodedEventId = Utils.decodeShareableToString(note);
```

**Complex Shareable Identifiers:**
```dart
// Encode complex identifiers with metadata
final profileInput = ProfileInput(
  pubkey: pubkey,
  relays: ['wss://relay.damus.io'],
  author: author,
  kind: 0,
);
final nprofile = Utils.encodeShareableIdentifier(profileInput);

final eventInput = EventInput(
  eventId: eventId,
  relays: ['wss://relay.damus.io'],
  author: author,
  kind: 1,
);
final nevent = Utils.encodeShareableIdentifier(eventInput);

final addressInput = AddressInput(
  identifier: 'my-article',
  relays: ['wss://relay.damus.io'],
  author: author,
  kind: 30023,
);
final naddr = Utils.encodeShareableIdentifier(addressInput);

// Decode complex identifiers
final profileData = Utils.decodeShareableIdentifier(nprofile) as ProfileData;
final eventData = Utils.decodeShareableIdentifier(nevent) as EventData;
final addressData = Utils.decodeShareableIdentifier(naddr) as AddressData;
```

**NIP-05 Resolution:**
```dart
// Resolve NIP-05 identifier to public key
final pubkey = await Utils.decodeNip05('alice@example.com');
```

**Event Utilities:**
```dart
// Generate event ID for partial event
final eventId = Utils.getEventId(partialEvent, pubkey);

// Check if event kind is replaceable
final isReplaceable = Utils.isEventReplaceable(kind);
```

### Event Verification

The verifier system validates BIP-340 signatures on nostr events.

**Basic Verification:**

```dart
// Get the verifier from the provider
final verifier = ref.read(verifierProvider);

// Verify an event signature
final isValid = verifier.verify(eventMap);
if (!isValid) {
  print('Event has invalid signature');
}
```

**Custom Verifier Implementation:**

```dart
class CustomVerifier extends Verifier {
  @override
  bool verify(Map<String, dynamic> map) {
    // Custom verification logic
    if (map['sig'] == null || map['sig'] == '') {
      return false;
    }
    
    // Implement your verification logic here
    return true; // or false based on verification result
  }
}

// Override the verifier provider (proper way)
ProviderScope(
  overrides: [
    verifierProvider.overrideWithValue(CustomVerifier()),
  ],
  child: MyApp(),
)
```

**Verification Configuration:**

```dart
// Enable verification (default)
final config = StorageConfiguration(
  skipVerification: false,
);

// Disable verification for performance
final config = StorageConfiguration(
  skipVerification: true,
);
```

**Verification in Storage Operations:**

```dart
// Events are automatically verified when saved (unless skipVerification: true)
await ref.storage.save({signedEvent});

// Manual verification
final verifier = ref.read(verifierProvider);
final isValid = verifier.verify(signedEvent.toMap());
```

### Error Handling

Handle storage errors and network failures gracefully.

```dart
// Watch for storage errors
ref.listen(storageNotifierProvider, (previous, next) {
  if (next is StorageError) {
    print('Storage error: ${next.exception}');
    // Show error UI or retry logic
  }
});

// Handle query errors
final queryState = ref.watch(
  query<Note>(authors: {pubkey}),
);

switch (queryState) {
  case StorageError():
    return ErrorWidget(
      message: queryState.exception.toString(),
      onRetry: () {
        // Trigger a new query
        ref.invalidate(query<Note>(authors: {pubkey}));
      },
    );
  case StorageLoading():
    return LoadingWidget();
  case StorageData():
    return NotesList(notes: queryState.models);
}

// Handle network failures
try {
  await ref.storage.save({model});
} catch (e) {
  // Save locally only if remote fails
  await ref.storage.save({model});
  print('Remote save failed, saved locally: $e');
}
```

## Design Notes 📝

- Built on Riverpod providers (`storageNotifierProvider`, `query`, etc.).
- The `Storage` interface acts similarly to a relay but is optimized for local use (e.g., storing replaceable event IDs, potentially storing decrypted data, managing eviction).
- Queries (`ref.watch(query<...>(...))`) primarily interact with the local `Storage`.
- By default, queries also trigger requests to configured remote relays. Results are saved to `Storage`, automatically updating watchers.
- The system tracks query timestamps (`since`) to optimize subsequent fetches from relays.
- Relay groups can be configured and used for publishing

### Storage vs relay

A storage is very close to a relay but has some key differences, it:

 - Stores replaceable event IDs as the main ID for querying
 - Discards event signatures after validation, so not meant for rebroadcasting
 - Tracks origin relays for events, as well as connection timestamps for subsequent time-based querying
 - Has more efficient interfaces for mass deleting data
 - Can store decrypted DMs or cashu tokens, cache profile images, etc

## Contributing 📩

Contributions are welcome. However, please open an issue to discuss your proposed changes *before* starting work on a pull request.

## License 📄

MIT
# CHANGELOG

 - Initial fork from mkstack
