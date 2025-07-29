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
- **BEFORE IMPLEMENTING ANY FEATURE**: Check for relevant recipes using `search_recipes` **AND** API documentation using `search_docs`
- **For ANY code implementation**: Consult both recipes and documentation first
- **Always search first**: Use `search_recipes` and `search_docs` before writing any code
- If no recipes or docs are found for your use case, proceed with standard implementation
- Recipes are complete examples showing how to approach specific features

### Nostr MCP Server

The `nostr` MCP server provides Nostr protocol reference and documentation for understanding NIPs, event kinds, and protocol specifications. **It is only useful when implementing a custom model**.

### First prompt

**Do NOT skip this first step.**

When a user makes the first prompt, and only during that very first prompt, you MUST ALWAYS:

 - Summarize what you understood, and ask important questions to ensure all requirements are crystal clear before starting any code
 - Ask them which outputs they want. By default, this project builds an Android app, but Flutter supports iOS, MacOS, Linux and Windows, all of these are preconfigured. **Remove the whole folders** of platforms that the user does not care about.
 - Run `fvm flutter pub get` (if fvm available), or `flutter pub get`
 - Suggest the user an app name, app ID (e.g., `com.sample.app`) and description. Based on obtained information, you MUST call the `rename_app` tool
  - `dart tools/bin/rename_app.dart --name "Your App Name" --app-id "com.sample.app"` – full reference available via purplestack MCP server: `search_recipes renaming`.

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
  - `lib/widgets/common`: Generic, reusable components that must NEVER be modified with app-specific behavior. See detailed guidelines in Code Guidelines section
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

## UI Development Guide

Comprehensive guide to building beautiful, responsive Flutter apps with Material 3 design and Nostr-specific UI patterns.

The project uses [Material 3](https://m3.material.io/) with `useMaterial3: true` in the default `MaterialApp`.

### Material 3 Components

**Navigation & Structure:**
- **AppBar**: Top app bar with title, navigation icon, and action items
- **BottomNavigationBar**: Primary navigation for multi-screen apps
- **NavigationRail**: Side navigation for larger screens
- **Drawer**: Panel sliding from screen edge for navigation
- **TabBar**: Horizontal tabs for navigating between views

**Feedback & Overlays:**
- **Alert/AlertDialog**: Modal dialog for critical information or decisions
- **MaterialBanner**: Persistent surface for important messages
- **BottomSheet**: Surface sliding from bottom edge for additional content
- **SnackBar**: Temporary feedback message at bottom of screen
- **Tooltip**: Informative popup on hover/focus/tap

**Input & Selection:**
- **TextField**: Text input with styling and validation options
- **Checkbox**: Multi-selection control for lists
- **Radio/RadioGroup**: Single-selection control from a set
- **Switch**: On/off toggle control
- **Slider**: Value selection from continuous/discrete range
- **DropdownButton**: Menu with selectable options
- **DatePicker**: Calendar interface for date selection
- **TimePicker**: Time selection interface

**Actions & Buttons:**
- **Button**: Elevated, Filled, Outlined, Text variants with different emphasis
- **FloatingActionButton**: Primary action button floating above UI
- **IconButton**: Icon-only button for common actions

**Display & Content:**
- **Card**: Container for single-topic content with elevation
- **ListTile**: Fixed-height row for lists and menus
- **CircleAvatar**: Circular widget for user representation
- **Badge**: Small notification marker for unread messages/updates
- **Chip**: Compact element for input, attributes, or actions
- **ExpansionPanel**: Expandable/collapsible container
- **DataTable**: Rows and columns with sorting/selection/pagination
- **Divider/Separator**: Visual separation between content

**Progress & Loading:**
- **CircularProgressIndicator**: Circular loading indicator
- **LinearProgressIndicator**: Linear progress bar

### Package Usage Guidelines

#### Content Rendering

##### flutter_markdown

- **When to use**: Kind 30023 (Articles), custom kinds where Markdown is part of specification, long-form content display screens
- **When NOT to use**: Kind 1 notes (use `NoteParser.parse()` instead), profile descriptions (unless NIP specifies Markdown), any content where Markdown isn't explicitly part of the protocol

```dart
// ✅ Correct usage for articles
MarkdownBody(
  data: article.content,
  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
)

// ❌ Wrong for notes - use NoteParser instead
Text(note.content) // Missing entity parsing
```

##### any_link_preview
Already implemented in `NoteParser`, useful for standalone hyperlink rendering:

##### Rich Text Content with NoteParser

**CRITICAL**: Always use `NoteParser` for Nostr text notes (kind 1, 11, 1111):

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
  onNostrEntity: (entity) => NostrEntityWidget(entity: entity),
  onHttpUrl: (url) => UrlChipWidget(url: url),
  onMediaUrl: (url) => MediaWidget(url: url),
  onHashtag: (hashtag) => HashtagWidget(hashtag: hashtag),
)
```

#### Layout and Responsiveness

##### flutter_layout_grid

- **When to use**: Dashboard layouts with multiple panels, complex responsive designs requiring specific column/row spanning, when CSS Grid-like behavior is needed.

##### auto_size_text
- **When to use**: User-generated content with varying lengths, responsive cards or tiles with dynamic content, navigation labels that might overflow, any UI where text length is unpredictable and space is limited

#### Progress and File Operations

##### percent_indicator
Perfect for Nostr file operations - file upload/download progress with Blossom protocol, media processing operations, sync operations with relays, any long-running operation with measurable progress

##### table_calendar
Highly customizable calendar widget for any calendar functionality.

### Loading States & Async Patterns

**Use skeleton loading** for structured content (feeds, profiles, forms). **Use spinners** only for buttons or short operations.

**Use `async_button_builder` for ALL async operations** to provide proper user feedback and prevent multiple simultaneous operations.

**Pull-to-refresh guidelines:**
DO NOT use pull-to-refresh when streaming data. Check the query `Source` stream property:

```dart
// ❌ Wrong - streaming data doesn't need pull-to-refresh
final notesState = ref.watch(query<Note>(source: LocalAndRemoteSource(stream: true)));

// ✅ Correct - non-streaming queries can use pull-to-refresh
final notesState = ref.watch(query<Note>(source: LocalAndRemoteSource(stream: false)));
if (!source.stream) {
  return RefreshIndicator(
    onRefresh: () async {
      // Refresh logic here
    },
    child: NotesList(),
  );
}
```

### Design & Theming

**Typography**: Use `google_fonts` package with Material 3 typography accessed through `Theme.of(context).textTheme`.

**Theme System**: Complete light/dark theme system controlled via `brightnessProvider`.

**Recommended Styles:**

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

Always use `Theme.of(context).colorScheme` for consistent theming and test both light/dark variants.

### Media Loading & Display

**Always include `errorBuilder`** to prevent crashes:

```dart
// ✅ Proper image loading with error handling
CachedNetworkImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
  placeholder: (context, url) => Container(
    color: Colors.grey[200],
    child: Center(child: CircularProgressIndicator()),
  ),
  errorBuilder: (context, error, stackTrace) => Container(
    color: Colors.grey[300],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.broken_image, color: Colors.grey[600], size: 48),
        SizedBox(height: 8),
        Text('Failed to load image', style: TextStyle(color: Colors.grey[600])),
      ],
    ),
  ),
)

// ✅ Profile avatars with fallback
CircleAvatar(
  radius: 24,
  backgroundImage: author?.pictureUrl != null
      ? CachedNetworkImageProvider(
          author!.pictureUrl!,
          errorListener: (error) => debugPrint('Avatar failed: $error'),
        )
      : null,
  child: author?.pictureUrl == null 
    ? Icon(Icons.person, size: 24)
    : null,
)
```

For video playback, use the `chewie` package. For audio playback, use the `just_audio` package. For viewing larger images with zoom, use the `easy_image_viewer` package.

## Essential Nostr Integration

This project uses the `models` and `purplebase` packages as the ONLY way to interact with the Nostr network.

### ⚠️ CRITICAL: Model vs Direct Event Manipulation

**ALWAYS use model constructors, setters, and relationships instead of direct `model.event` manipulation.**

**❌ WRONG - Direct event manipulation:**
```dart
// Don't do this - bypasses model interface and breaks abstraction
note.event.addTag('custom', ['value']);
note.event.content = 'modified content';
```

**✅ CORRECT - Use model interface:**
```dart
// Use proper model constructors with parameters
final partialNote = PartialNote("content", tags: {'farming'});

// Use model setters and methods
final partialProfile = PartialProfile()
  ..displayName = 'New Name'
  ..about = 'Updated bio';
```

### ⚠️ CRITICAL: Use Existing Models First

**BEFORE implementing ANY Nostr feature:**

1. **Check existing models** via purplestack MCP server (`search_docs models`)
2. **Search all NIPs** using `mcp_nostr_read_nips_index` tool
3. **Investigate thoroughly** with `mcp_nostr_read_nip` for relevant NIPs
4. **Only create custom kinds** after proving no existing solution works

**Custom kinds sacrifice interoperability** - use as last resort only.

### Basic Query Provider Usage

The `query` provider has a filter-like API for querying Nostr events:

```dart
import 'package:models/models.dart';

final state = ref.watch(query<Note>(authors: {pubkey1}, limit: 10));
```

**Use `ref.storage` extension**: `await ref.storage.save({model});` instead of verbose provider syntax.

Use the `and` operator to load relationships efficiently. Never call query inside loops!

### Authentication Basics

Always use `amber_signer` package first for NIP-55 compatible authentication. See recipe: `search_recipes amber-authentication`.

### Publishing Basics

Use `storage.publish(...)` for relay publishing. Note that `storage.save()` and `storage.publish()` are independent - call both for local+remote storage.

### NIP-19 Identifiers

Nostr identifiers (`npub`, `nsec`, `note`, `nprofile`, `nevent`, `naddr`) can be encoded/decoded via `Utils.encodeShareableIdentifier` and `Utils.decodeShareableIdentifier`.

## Advanced Nostr Features

For detailed implementations of advanced Nostr features, search for recipes:

- **Custom Event Kinds**
- **File Uploads**
- **Lightning Zaps**
- **Direct Messages & Encryption**
- **Feed Building**
- **DVM Integration**
- **Engagement UI**
- **Async UI Patterns**

There are many more.

### Signing in a Profile

Authentication implementation with Amber signer. See recipe.

### Displaying Engagement Information

Social engagement metrics (likes, reposts, zaps) for Nostr notes. See recipe.

### Uploading Files on Nostr

File upload implementation using the Blossom protocol. See recipe.

### Nostr Encryption and Decryption

NIP-44 and NIP-04 encryption for direct messages. See recipe.

### Custom Data Storage

Use the `CustomData` model for storing user preferences, app settings, and configuration data. Use encryption (NIP-44 > NIP-04) for sensitive data (NWC strings, cashu tokens).

## Error Handling and Debugging

### Automatic Error Handling

The `purplebase` package automatically handles all low-level Nostr protocol errors including relay connections, malformed events, signature verification, network timeouts, and rate limiting.

### Debug Information Provider

For debugging and monitoring, Purplebase exposes the `infoNotifierProvider` which streams diagnostic messages about operations. This is one helpful tool for debugging storage and relay pool issues.

**Use `infoNotifierProvider` for debugging:**
- **Storage operations**: Database queries, saves, and cache hits
- **Relay pool status**: Connection states, subscription management, publishing results

**Pro tip**: Create a debug overlay or dedicated debug screen in development builds to continuously monitor the `infoNotifierProvider` information.

## Code Guidelines

### Code Style

- Use latest Dart features and idioms (pattern matching, switch statements, sealed classes, collection operators)
- Always use meaningful variable and function names
- Fix ALL compiler warnings and errors immediately - goal is ZERO compiler messages
- Never use artificial waits (`Future.delayed`) - properly await futures instead
- **NEVER use polling** - always subscribe to listeners and streams
- Use Flutter best practices

### Architecture

- Local-first architecture: data from local storage, continuously synced from remote sources
- State management: **Always use `flutter_hooks` for widget-local state**, **Riverpod providers for global state**
- **Never use StatefulWidgets** - hooks provide better composition
- Component-based architecture with shared components in `lib/widgets`
- **SafeArea**: Always use by default to handle device notches and system UI
- Use Dart constants for magic numbers and strings (`kConstant`)

### Git Guidelines

**NEVER commit code changes on behalf of the user.** Always let the user review and commit their own changes.

### Common Widget Architecture

The widgets in `widgets/common` are generic, reusable components that must remain pure and framework-agnostic.

**Do not modify common widgets with app-specific behavior** - use their callback systems for customization instead.

**✅ Generic (belongs in `/common/`):**
- Takes data through parameters, never hardcodes app-specific values
- Uses callback functions for handling actions
- Focuses on rendering and interaction patterns, not business logic
- Configurable through props and styling parameters

**❌ App-Specific (belongs in app screens/widgets):**
- Hardcoded business rules or app-specific behavior
- Direct navigation to specific screens
- App-specific styling that can't be configured

**Current Generic Widgets (DO NOT MODIFY):**
1. `NoteParser` - Parses Nostr content with customizable callbacks
2. `EngagementRow` - Social engagement metrics with callback-based interaction
3. `TimeUtils` & `TimeAgoText` - Time formatting utilities
4. `ProfileAvatar` - Avatar component with Profile model and styling parameters

### Testing

**⚠️ DO NOT WRITE TESTS** unless the user is experiencing a specific problem or explicitly requests tests. Focus on building functionality that works.

### Performance

- Optimize images and assets
- Use const constructors where possible
- Implement proper error handling
- Consider lazy loading for large lists

### Utility Functions

Always check for existing utilities before creating new ones:
- **TimeUtils & TimeAgoText**: For timestamp formatting (generic components)
- **Utils (from models package)**: For Nostr-related utilities
- **NoteParser**: REQUIRED for displaying note content (generic component)

Always use available MCP servers before searching the web.

## Security and Environment

### API Key Management

**No API keys are required** in Purplestack projects. The Nostr protocol is decentralized.

### Private Key Security

Default: Private keys handled in-memory only with `Bip340PrivateKeySigner`. For persistent nsec storage, see recipe: `search_recipes secure-nsec-storage`.

## Releasing to Production

For correct app renaming and icon generation, use: `search_recipes renaming`.

When building for Android distribution: `fvm flutter build apk --target-platform android-arm64`

Consider using [Zapstore](https://zapstore.dev) for distribution.

### README Guidelines

Update README to be short and concise:
- Remove "Purplestack" from title
- Include 1-2 paragraphs describing app and features  
- Brief development instructions
- Footer: "Powered by [Purplestack](https://purplestack.io)"