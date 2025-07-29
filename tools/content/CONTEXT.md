# Purplestack

Development stack designed for AI agents to build Nostr-enabled Flutter applications. It includes a complete tech stack with Purplebase and Riverpod, documentation and recipes for common implementation scenarios.

## CRITICAL FOR AI ASSISTANTS - MUST READ FIRST

**Reference**. The AI assistant's behavior and knowledge is defined by this context file (aliased to other IDE-specific filenames), which serves as the system prompt. **ALWAYS** refer to this document and follow these rules and recommendations.

### Purplestack MCP Server

**CRITICAL**: This project relies on the purplestack MCP server for recipes and documentation. **YOU _MUST_ VERIFY THE MCP SERVER IS WORKING BEFORE IMPLEMENTING ANY FEATURE**.

Available purplestack MCP tools:
- `list_recipes` - List all available implementation recipes  
- `read_recipe` - Read a specific recipe by name
- `search_recipes` - Search recipes by keyword
- `list_docs` - List all available documentation
- `read_doc` - Read specific documentation
- `search_docs` - Search documentation by keyword

**⚠️ CRITICAL CHECK**: If the purplestack MCP server cannot be called or returns 0 tools, there is a configuration issue. **STOP ALL WORK** and prompt the user to fix the MCP server before proceeding.

**Common Fix**: The `agent.json` file may need to be modified to include the correct "cwd" pointing to the current project directory for the purplestack MCP server configuration.

**Usage Requirements:**
- Before implementing any new feature, check for relevant recipes using `search_recipes` **and** API documentation using `search_docs`
- Consult documentation using `search_docs` when you need technical guidance
- If no recipes or docs are found for your use case, proceed with standard implementation
- Recipes are complete examples showing how to approach specific features

### Nostr MCP Server

The `nostr` MCP server provides Nostr protocol reference and documentation for understanding NIPs, event kinds, and protocol specifications.

### First prompt

**Do NOT skip this first step.**

When a user makes the first prompt, and only during that very first prompt, you MUST ALWAYS:

 - Summarize what you understood, and ask important questions to ensure all requirements are crystal clear before starting any code
 - Ask them which outputs they want. By default, this project builds an Android app, but Flutter supports iOS, MacOS, Linux and Windows, all of these are preconfigured. **Remove the whole folders** of platforms that the user does not care about.
 - Run `fvm flutter pub get` (if fvm available), or `flutter pub get`
 - Suggest the user an app name, app ID (e.g., `com.sample.app`) and description. Based on obtained information, you MUST call the `rename_app` tool
  - `dart tools/bin/rename_app.dart --name "Your App Name" --app-id "com.sample.app"` – full reference available via purplestack MCP server).

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
- **chewie**: Professional video player with built-in controls
- **just_audio**: High-quality audio player with advanced features

**Important**: Flutter can produce binaries for a myriad of operating systems. **Assume the user wants an Android application (arm64-v8a), unless specifically asked otherwise**, take this into account when testing a build or launching a simulator.

## Development Tools & Package Management

### FVM (Flutter Version Management)

When `fvm` is available, always use it for Flutter commands to ensure consistent Flutter version usage across development:

```bash
# Use fvm flutter instead of direct flutter commands
fvm flutter run
fvm flutter build apk --target-platform android-arm64  # For Android APK distribution
fvm flutter analyze
```

### Package Management

Always manage packages via the CLI to ensure latest compatible versions are resolved:

```bash
# Adding packages
fvm dart pub add package_name

# Removing packages  
fvm dart pub remove package_name

# Getting dependencies
fvm dart pub get
```

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
- `assets`: Static assets (remember to add any referenced assets to `pubspec.yaml`)

## Storage and Relay Pool Configuration

Configure storage behavior and relay connections.

Search for updated configuration syntax via purplestack MCP server (`search_docs storage`) first! But here is a default:

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
    'default': {
      'wss://relay.damus.io',
      'wss://relay.primal.net',
    },
    'private': {
      'wss://my-private-relay.com',
    },
  },
  
  // Default relay group
  defaultRelayGroup: 'default',
  
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

## Routing

The project uses a GoRouter with a centralized routing configuration in `router.dart`. To add new routes:

1. Create your screen in `screens`
2. Import it in `router.dart`

**Multi-Screen Navigation**: For any multi-screen application request, automatically implement a `BottomNavigationBar` with appropriate tabs and navigation structure. This provides intuitive navigation patterns that users expect on mobile platforms.

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

#### Rich Text Content

Nostr text notes (kind 1, 11, and 1111) have a plaintext `content` field that may contain URLs, hashtags, and Nostr URIs.

Use the `NoteParser` class (and utilities in the `note_parser.dart` file) for this.

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

## Loading States

**Use skeleton loading** for structured content (feeds, profiles, forms). **Use spinners** only for buttons or short operations.

**Pull-to-Refresh**: DO NOT use pull-to-refresh when streaming data. Streaming already refreshes automatically via the request notifier, making pull-to-refresh redundant and potentially confusing.

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

For video playback, use the `chewie` package. For audio playback, use the `just_audio` package.

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
- **Always prioritize using Theme colors**: Fetch colors from `Theme.of(context).colorScheme` unless they don't fit the theme
- Use theme-based styling: `Theme.of(context).colorScheme.primary`
- Implement responsive design with breakpoints
- Add hover and focus states for interactive elements

### Async Operations & User Feedback

**Use `async_button_builder` for all async operations** to provide proper user feedback and prevent multiple simultaneous operations.

#### When to Use async_button_builder

Use `async_button_builder` for:
- **Authentication operations**: Sign in, sign out, account switching
- **Network operations**: Posting notes, liking, reposting, zapping
- **File operations**: Uploading media, processing files
- **Any operation that takes >500ms**: Long-running computations, API calls

#### Basic Usage Pattern

```dart
import 'package:async_button_builder/async_button_builder.dart';

// For icon buttons
AsyncButtonBuilder(
  child: const Icon(Icons.favorite),
  onPressed: () async {
    // Your async operation
    await performLike();
  },
  builder: (context, child, callback, buttonState) {
    return IconButton(
      icon: buttonState.maybeWhen(
        loading: () => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        orElse: () => child,
      ),
      onPressed: buttonState.maybeWhen(
        loading: () => null, // Disable during loading
        orElse: () => callback,
      ),
    );
  },
  onError: () {
    // Show error feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Operation failed')),
    );
  },
)

// For filled buttons
AsyncButtonBuilder(
  child: Text('Sign In'),
  onPressed: () async {
    await signInWithAmber();
  },
  builder: (context, child, callback, buttonState) {
    return FilledButton(
      onPressed: buttonState.maybeWhen(
        loading: () => null,
        orElse: () => callback,
      ),
      child: buttonState.maybeWhen(
        loading: () => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        orElse: () => child,
      ),
    );
  },
)
```

#### Integration with Custom Components

For custom components that handle async operations (like `EngagementRow`), add loading state parameters:

```dart
// Component with loading states
EngagementRow(
  likesCount: note.reactions.length,
  isLiked: userHasLiked,
  isLiking: _isLiking, // Track loading state
  onLike: () async {
    setState(() => _isLiking = true);
    try {
      await performLike();
    } finally {
      setState(() => _isLiking = false);
    }
  },
)
```

#### Error Handling Best Practices

- **Show user-friendly error messages**: Avoid technical error details
- **Use SnackBar for temporary feedback**: Brief, non-intrusive notifications
- **Handle network failures gracefully**: Provide retry options when appropriate
- **Prevent multiple simultaneous operations**: Disable buttons during loading

#### Benefits

- **Better UX**: Users see immediate feedback that their action was received
- **Prevents double-taps**: Loading states disable buttons automatically  
- **Consistent behavior**: Standardized loading and error patterns across the app
- **Accessibility**: Screen readers can announce loading states


## Nostr Protocol Integration

This project uses the `models` and `purplebase` packages which are the ONLY way to interact with the nostr network.

### ⚠️ CRITICAL: Model vs Direct Event Manipulation

**ALWAYS use model constructors, setters, and relationships instead of direct `model.event` manipulation.**

**❌ WRONG - Direct event manipulation (NOT good practice):**
```dart
// Don't do this - bypasses model interface and breaks abstraction
note.event.addTag('custom', ['value']);
note.event.tags.add(['t', 'farming']);
note.event.content = 'modified content';

// This creates inconsistent state and bypasses validation
profile.event.tags.removeWhere((tag) => tag[0] == 'name');
```

**✅ CORRECT - Use model interface (PREFERRED approach):**
```dart
// Use proper model constructors with parameters
final partialNote = PartialNote("content", tags: {'farming'});

// Use model setters and methods
final partialProfile = PartialProfile()
  ..displayName = 'New Name'
  ..about = 'Updated bio';

// Use model relationships for complex data
final note = PartialNote("reply content")
  ..replyTo = originalNote;
```

**When `model.event` access is acceptable (ADVANCED CUSTOMIZATION ONLY):**
- ✅ **Only within custom model class implementations**
- ✅ **Only for accessing custom tags not yet supported by the model interface**
- ✅ **Advanced customization by experienced developers who understand the implications**
- ✅ **Reading (not modifying) raw event data for debugging**

**Why avoid direct event manipulation:**
- **Breaks encapsulation**: Bypasses model validation and type safety
- **Creates inconsistent state**: Models may not reflect actual event data
- **Harder maintenance**: Code becomes coupled to raw Nostr protocol details
- **Debugging complexity**: Issues become harder to trace and fix
- **Framework violations**: Goes against the local-first architecture principles

**Always prioritize using models over the underlying `model.event` property.** Models provide rich methods, relationships, and domain-specific functionality that handle all the complexity for you.

### ⚠️ CRITICAL: Use Existing Models First

**BEFORE implementing ANY Nostr feature:**

1. **Check existing models** via purplestack MCP server (`search_docs models`) - complete documentation of all available models
2. **Search all NIPs** using `mcp_nostr_read_nips_index` tool to see existing kinds
3. **Investigate thoroughly** with `mcp_nostr_read_nip` for any potentially relevant NIPs
4. **Only create custom kinds** after proving no existing solution works

**Interoperability Warning**: Custom kinds mean your app won't work with existing Nostr clients and creates ecosystem fragmentation. This should be a last resort.

**Posts vs Notes**: Users may refer to "posts" when they mean "notes" (kind 1). These are synonyms. When users ask for posts, understand they mean notes. Always prevent creating new kinds - if a post scheduler is requested, create a scheduler for Note, not a new PostScheduler model.

### Nostr Implementation Guidelines

You **MUST** ALWAYS attempt to use the `models` package, following purplestack MCP server documentation (`search_docs models`) for model usage. If a model does not exist, you MAY use the `nostr` MCP server to understand how to create and register a new model.

- Always use the `mcp_nostr_read_nips_index` tool before implementing any Nostr features to see what kinds are currently in use across all NIPs.
- If any existing kind or NIP might offer the required functionality, use the `mcp_nostr_read_nip` tool to investigate thoroughly. Several NIPs may need to be read before making a decision.
- Only generate new kind numbers if no existing suitable kinds are found after comprehensive research.

Knowing when to create a new kind versus reusing an existing kind requires careful judgement. Introducing new kinds means the project won't be interoperable with existing clients. But deviating too far from the schema of a particular kind can cause different interoperability issues.

#### Choosing Between Existing NIPs and Custom Kinds

When implementing features that could use existing NIPs, follow this decision framework:

1. **Thorough NIP Review**: Before considering a new kind, always perform a comprehensive review of existing NIPs and their associated kinds. Use the `read_nips_index` tool to get an overview, and then `read_nip` and `read_kind` to investigate any potentially relevant NIPs or kinds in detail. The goal is to find the closest existing solution.

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
Research Process:
1. Check purplestack MCP server (search_docs marketplace) for existing marketplace models
2. Use mcp_nostr_read_nips_index to find marketplace-related NIPs
3. Investigate NIP-15 (Marketplace), NIP-99 (Classified Listings)
4. Analysis: NIP-99 ClassifiedListing fits well, can extend with farming tags

Decision: Use existing ClassifiedListing + farming-specific tags
Result: Interoperable with other marketplace clients
```

#### Creating Custom Event Kinds

**⚠️ Last Resort Only**: Custom kinds should only be created after exhaustively researching existing options via purplestack MCP server (`search_docs models`) and all relevant NIPs. Custom kinds sacrifice interoperability for perfect data modeling.

Extend the system with your own models only when no existing model serves your needs.

##### Basic Custom Model

```dart
class ClassifiedListing extends RegularModel<ClassifiedListing> {
  ClassifiedListing.fromMap(super.map, super.ref) : super.fromMap();
  
  String? get title => event.getFirstTagValue('title');
  String? get price => event.getFirstTagValue('price');
  String get description => event.content;
  DateTime? get publishedAt => 
      event.getFirstTagValue('published_at')?.toInt()?.toDate();
}

class PartialClassifiedListing extends RegularPartialModel<ClassifiedListing> with PartialClassifiedListingMixin {
  PartialClassifiedListing({
    required String title,
    required String description,
    String? price,
    DateTime? publishedAt,
  }) {
    event.content = description;
    event.addTagValue('title', title);
    if (price != null) event.addTagValue('price', price);
    if (publishedAt != null) {
      event.addTagValue('published_at', publishedAt.toSeconds().toString());
    }
  }
}
```

##### Registering Custom Kinds

```dart
// Create a custom initialization provider
final customInitializationProvider = FutureProvider((ref) async {
  await ref.read(initializationProvider(StorageConfiguration()).future);
  
  // Register your custom models
  Model.register(kind: 1055, constructor: ClassifiedListing.fromMap, partialConstructor: PartialClassifiedListing.fromMap);
  
  return true;
});

// Use this provider instead of the default one
final initState = ref.watch(customInitializationProvider);
```

##### Using Custom Models

```dart
// Create and sign a classified listing
final partialListing = PartialClassifiedListing(
  title: 'John Deere Tractor',
  description: 'Excellent condition, low hours, ready for farming season.',
  price: '25000',
  publishedAt: DateTime.now(),
);

final signedListing = await partialListing.signWith(signer);

// Save to storage
await ref.storage.save({signedListing});

// Publish to relays
await ref.storage.publish({signedListing});

// Query listings
final listingsState = ref.watch(
  query<ClassifiedListing>(
    authors: {signer.pubkey},
    limit: 10,
  ),
);
```

##### Different Model Types

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

See purplestack MCP server (`search_docs models`) for how to create and initialize events and custom events (models), and which class to inherit from (`RegularModel`, `ReplaceableModel`, etc).

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

**Use `ref.storage` extension instead of `read(storageNotifierProvider.notifier)`.** This provides a cleaner API for storage operations:

```dart
// ✅ Preferred - clean extension syntax
await ref.storage.save({model});
await ref.storage.publish({model});

// ❌ Avoid - verbose provider syntax  
await ref.read(storageNotifierProvider.notifier).save({model});
```

`query` takes an `and` operator which will instruct it to load relationships. If data is needed, it's always better to use a relationship than a separate query call.

**Do not call query**, especially with many relationships inside loops! If you need relationship loading, use `and` and loop there - it will have the chance to optimize data loading and relay requests.

**Relationship Usage**: Use synchronous relationships (`.value`, `.toList()`) in widgets for immediate rendering. Use asynchronous relationships (`.valueAsync`, `.toListAsync()`) in callbacks and other non-widget contexts.

Use the default `source` argument unless otherwise requested.

See purplestack MCP server (`search_docs models`) for complete model documentation.

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

**RequestFilter Usage:**
- **NEVER use `kinds: {}` with `RequestFilter<E>`** where E is a specific model type - it makes no sense since the model type already determines the kind
- Only use `kinds:` parameter when using `RequestFilter<Model>` (generic) and you need to specify multiple kinds
- **❌ Wrong**: `RequestFilter<Note>(kinds: {1})` - Note already implies kind 1
- **✅ Correct**: `RequestFilter<Note>(authors: {pubkey})` - Let the model determine the kind
- **✅ Correct**: `RequestFilter<Model>(kinds: {1, 6, 16})` - Generic model with multiple kinds

### Displaying a profile

To display profile data for a user by their Nostr pubkey (such as an event author), use the `query<Profile>(authors: {pubkey1})`.

**Profile Bio Rendering**: When displaying profile bios or descriptions, always use `NoteParser` to properly render Nostr references, hashtags, and URLs:

```dart
// ✅ Correct: Parse bio content for Nostr entities
ParsedContentWidget(
  content: profile.about ?? '',
  onProfileTap: (pubkey) => context.push('/profile/$pubkey'),
  onHashtagTap: (hashtag) => context.push('/hashtag/$hashtag'),
)

// ❌ Wrong: Displaying raw bio text
Text(profile.about ?? '')
```

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
              onPressed: () => ref.read(amberSignerProvider).signIn(),
              child: const Text('Sign In'),
            ),
          ] else ...[
            if (profile?.pictureUrl != null)
              CircleAvatar(backgroundImage: NetworkImage(profile!.pictureUrl!)),
            if (profile?.nameOrNpub != null) Text(profile!.nameOrNpub),
            Text(
                '${pubkey.substring(0, 8)}...${pubkey.substring(pubkey.length - 8)}'),
            ElevatedButton(
              onPressed: () => ref.read(amberSignerProvider).signOut(),
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

**Auto Sign-In (Recommended):**

For a better user experience, you can attempt to automatically sign in the user if they have previously authorized your app with Amber. This should be called in your app's initializer after the storage initialization:

```dart
// After initialization
await ref.read(initializationProvider(StorageConfiguration()).future);
await ref.read(amberSignerProvider).attemptAutoSignIn();
```

This method will silently attempt to restore the user's previous session without requiring user interaction.

**Temporary/Utility Signers:**

When creating temporary or utility signers that are not user-initiated (not under user control), use `registerSigner: false`:

```dart
// For temporary operations or background processing
final utilitySigner = Bip340PrivateKeySigner(privateKey, ref, registerSigner: false);
```

Look for Signer Interface & Authentication recipe via purplestack MCP server (`search_recipes authentication`).

### Publishing

To publish events, use `storage.publish(...)` in any callback.

**Important**: `storage.save()` and `storage.publish()` are independent operations. If you need both local storage AND relay publishing, both methods must be called:

```dart
// ✅ Save locally AND publish to relays
await ref.storage.save({signedEvent});
await ref.storage.publish({signedEvent});

// ❌ Wrong - only saves locally, doesn't publish to relays
await ref.storage.save({signedEvent});

// ❌ Wrong - only publishes to relays, doesn't save locally
await ref.storage.publish({signedEvent});
```

Use `save()` for local-only operations and `publish()` for relay distribution. Most user actions require both to ensure data availability offline and online.

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

For nostr-related utilities always look first in the `models` package (via MCP server), where they are likely available, before creating your own.

### Rendering Note Content

**⚠️ Important**: `NoteParser` is a generic component in `/common/`. Never modify it with app-specific behavior - use its callback system for customization. See the **Common Widget Architecture** section in Code Guidelines.

**Use for all Nostr note content parsing** to automatically handle NIP-19 entities, URLs, media, and hashtags:

```dart
import 'package:purplestack/widgets/common/note_parser.dart';

// ✅ Always use ParsedContentWidget for note content display
ParsedContentWidget(
  content: note.content,
  colorPair: [Colors.blue, Colors.blueAccent],
  onProfileTap: (pubkey) => context.push('/profile/$pubkey'),
  onHashtagTap: (hashtag) => context.push('/hashtag/$hashtag'),
)

// ✅ Or use NoteParser.parse() directly with custom callbacks
NoteParser.parse(
  context,
  note.content,
  textStyle: Theme.of(context).textTheme.bodyMedium,
  onNostrEntity: (entity) => NostrEntityWidget(entity: entity, colorPair: colorPair),
  onHttpUrl: (url) => UrlChipWidget(url: url, colorPair: colorPair),
  onMediaUrl: (url) => MediaWidget(url: url, colorPair: colorPair),
  onHashtag: (hashtag) => HashtagWidget(hashtag: hashtag, colorPair: colorPair),
  onHashtagTap: (hashtag) => context.push('/hashtag/$hashtag'),
  onProfileTap: (pubkey) => context.push('/profile/$pubkey'),
)
```

**Supported Content Types:**
- **NIP-19 Entities**: `npub1...`, `note1...`, `nevent1...`, `naddr1...` → Profile chips, note previews
- **HTTP URLs**: `https://example.com` → Link previews with `any_link_preview`
- **Media URLs**: `image.jpg`, `video.mp4`, `audio.mp3` → Embedded media players
- **Hashtags**: `#bitcoin`, `#nostr` → Styled hashtag chips with navigation

**When to use NoteParser:**
- Kind 1 notes (short text notes)
- Kind 11 notes (group chat messages)
- Kind 1111 notes (comments)
- Profile descriptions (bio text)
- Any Nostr content with mixed text and entities

**When NOT to use:**
- Kind 30023 articles (use `flutter_markdown` instead)
- Pure plaintext without entities
- Content where Markdown formatting is expected

**Features:**
- Automatically detects `npub1...`, `note1...`, `nevent1...`, etc. (handles `nostr:` prefix)
- Identifies media URLs by file extension (jpg, png, mp4, etc.)
- Detects hashtags in `#hashtag` format with navigation support
- Returns `RichText` with `WidgetSpan` for seamless text/widget mixing
- Validates NIP-19 entities using `Utils.decodeShareableIdentifier()`
- Graceful fallbacks when callbacks return `null`

**Important**: Any time you display note content (kind 1, kind 11, kind 1111), you MUST use this instead of displaying raw text.

### Zaps and Lightning Payments

**NWC (Nostr Wallet Connect) Support**: Lightning payments and zaps are fully supported through NWC integration. For complete documentation on implementing NWC for zaps, use purplestack MCP server (`search_recipes nwc` and `search_docs nwc`).

NWC enables secure Lightning wallet connections without exposing private wallet credentials to the application. Users can connect their Lightning wallets (like Alby, Zeus, or Mutiny) to send zaps directly from your Nostr application.

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

**⚠️ CRITICAL: Always Use NIP-44 Encryption**

**NIP-44 is the modern, secure encryption standard and should ALWAYS be your first choice.** NIP-04 is older, less secure, and should only be used when explicitly requested by the user or for compatibility with legacy systems.

The `Signer` interface has methods for:

 - `nip44Encrypt` ✅ **USE THIS - Modern, secure encryption**
 - `nip44Decrypt` ✅ **USE THIS - Modern, secure decryption**
 - `nip04Encrypt` ⚠️ **Legacy only - use only when specifically needed**
 - `nip04Decrypt` ⚠️ **Legacy only - use only when specifically needed**

Signers can be obtained via the `signerProvider` family or `activeSignerProvider`.

The signer's encryption methods handle all cryptographic operations internally, including key derivation and conversation key management, so you never need direct access to private keys. Always use the signer interface for encryption rather than requesting private keys from users, as this maintains security and follows best practices.

**NIP-44 Encryption Example (ALWAYS USE THIS):**
```dart
// ✅ PREFERRED: Encrypt a message using NIP-44 (modern, secure)
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

**NIP-04 Encryption Example (LEGACY ONLY):**
```dart
// ⚠️ LEGACY: Only use NIP-04 when specifically requested or for compatibility
final signer = ref.read(Signer.activeSignerProvider);
final recipientPubkey = 'npub1abc123...';

// Encrypt the message using legacy NIP-04
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
- **NIP-44**: ✅ **DEFAULT CHOICE** - Modern encryption with superior security, forward secrecy, and metadata protection
- **NIP-04**: ⚠️ **LEGACY ONLY** - Older encryption method with known security limitations
- **ALWAYS use NIP-44 for all new implementations** unless the user explicitly requests NIP-04 compatibility

### Custom data

Any time you need to store custom data, use the `CustomData` model from the `models` package. Use `setProperty` to set tags, and feel free to use encryption as defined above for sensitive data (NWC strings, cashu tokens, for example).

**User Preferences and Settings**: Always use `CustomData` for storing user preferences, app settings, and configuration data instead of other storage methods.

**Clear App Data**: To clear all app data during development or for user logout, use:

```dart
await ref.storage.clear();
```

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

For debugging and monitoring, Purplebase exposes the `infoNotifierProvider` which streams diagnostic messages about the Nostr operations. This is the primary tool for debugging storage and relay pool issues:

```dart
// Example: Display debug info in a debug screen
class DebugScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debugInfo = ref.watch(infoNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Debug Info')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Current Status'),
            subtitle: Text(debugInfo ?? 'No debug info'),
          ),
          // Add more debug information display
        ],
      ),
    );
  }
}
```

**Use `infoNotifierProvider` for easy debugging of:**
- **Storage operations**: Database queries, saves, and cache hits
- **Relay pool status**: Connection states, subscription management, publishing results
- **Event processing**: Validation, parsing, and relationship loading
- **Network performance**: Response times, retry attempts, failure reasons
- **Synchronization issues**: Data consistency problems between local and remote

**Pro tip**: Create a debug overlay or dedicated debug screen in development builds to continuously monitor this information.


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
- **NEVER EVER use polling** - Always subscribe to listeners and streams instead of polling for data changes. Polling wastes resources and creates poor user experience. Use Riverpod's reactive patterns, `ref.watch()`, `ref.listen()`, and stream subscriptions.
- **Avoid pure wrapper methods** that add bloat and no value. Don't create simple wrappers around providers or methods without adding meaningful functionality.
- Use Flutter best practices

### Architecture

- The app architecture is local-first: All data is pulled from local storage, which is continually sync'ed from remote sources
- Uses the `models` package, via Purplebase package that implements the local-first architecture
- State management:
  - **Always use `flutter_hooks` for widget-local state** - Use `HookWidget` or `HookConsumerWidget`
  - **Use Riverpod providers for all other state** - Global and inter-component state uses `ConsumerWidget`
  - **Never use StatefulWidgets** - Hooks provide better composition and testing
  - Do not create simple wrappers around providers, i.e. wrapping one other provider without adding any value
  - **Listening to model streams**: When a model from a stream needs to be listened to, use `ref.listen(query(...))` with a Completer for proper async handling:
    ```dart
    // ✅ Correct pattern for listening to model changes (in this case the `source` argument must have stream: true)
    final completer = Completer<Note>();
    ref.listen(query<Note>(ids: {noteId}), (_, state) {
      if (state case StorageData(:final models)
            when models.isNotEmpty && ... && !completer.isCompleted) {
          completer.complete(models.first);
        }
    });
    final note = await completer.future;
    ```
- Component-based architecture, with shared components in `lib/widgets`
- **SafeArea**: Always use `SafeArea` by default in widgets up the hierarchy to handle device notches and system UI
- Follows Material 3 design system and component patterns
- Keep widgets of small or medium size and focused
- Use Dart constants for magic numbers and strings (`kConstant`)

### Git Guidelines

**NEVER commit code changes on behalf of the user.** Always let the user review and commit their own changes. This ensures they maintain control over their git history and can review all changes before they become permanent.

### Common Widget Architecture

The widgets in the `lib/widgets/common` folder are generic, reusable components that must remain pure and framework-agnostic. These widgets serve as the foundation layer for all Purplestack applications.

**Do not modify common widgets with app-specific behavior; if absolutely necessary do modify them with generic behavior**.

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

**Always use available MCP servers before searching the web.** The project includes purplestack MCP server for recipes/documentation and nostr MCP server for protocol reference - these should be your first resource for information and debugging.

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

## Security and Environment

### API Key Management

**No API keys are required or handled** in Purplestack projects. The Nostr protocol is decentralized and does not require API keys for accessing relays or publishing events.

### Private Key Security

#### Default: In-Memory Storage
By default, private keys (nsec) are handled in-memory only when using `Bip340PrivateKeySigner`:

```dart
// Private key is only stored in memory during app session
final signer = Bip340PrivateKeySigner(privateKeyHex, ref);
await signer.signIn();

// When app closes, private key is lost and user must re-enter
```

#### Persistent Key Storage specifically for nsec

If the user specifically requests persistent **nsec** signing, use the `flutter_secure_storage` package. Do NOT use this storage for any other kind of data storage, use `CustomData` as instructed before.

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

## Releasing to Production

For correct app name, app ID, and icon generation for all platforms, use purplestack MCP server (`search_recipes renaming`).

When building Flutter apps for Android distribution, always use the optimized ARM64 build: `fvm flutter build apk --target-platform android-arm64` (this is the only platform that matters for modern Android devices).

For distribution, consider using [Zapstore](https://zapstore.dev) - a decentralized app store built on Nostr.

### README Guidelines

The README file should be short and concise:
- Remove "Purplestack" from the title
- Include 1-2 paragraphs describing the app and its features
- Brief instructions on how to run in development (no extensive technical details)
- Footer should read: "Powered by [Purplestack](https://purplestack.io)"