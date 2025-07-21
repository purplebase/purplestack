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