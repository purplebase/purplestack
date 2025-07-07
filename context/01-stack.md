# Purplestack

Development stack designed for AI agents to build Nostr-enabled Flutter applications. It includes a complete tech stack with Purplebase and Riverpod, documentation and recipes for common implementation scenarios.

**Important for AI Assistants**: The AI assistant's behavior and knowledge is defined by the CONTEXT.md file, which serves as the system prompt. ALWAYS refer to this document and follow these rules and recommendations.

## Technology Stack

- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Riverpod / hooks_riverpod**: State management and dependency injection
- **Flutter Hooks**: React-style hooks for Flutter
- **Purplebase**: Local-first Nostr SDK with storage and relay pool
- **models**: Domain models for Nostr events
- **GoRouter**: Declarative routing
- **Forui**: UI component library
- **google_fonts**: Font management
- **cached_network_image**: Image caching
- **flutter_markdown**: Markdown rendering
- **auto_size_text**: Responsive text sizing
- **skeletonizer**: Skeleton loading states
- **percent_indicator**: Progress indicators
- **easy_image_viewer**: Image viewing
- **flutter_layout_grid**: Grid layouts
- **background_downloader**: Background file downloads
- **install_plugin**: Android APK installation
- **android_package_manager**: Query installed packages
- **permission_handler**: Runtime permissions

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

The project uses [Forui](https://forui.dev/).

**Forui Components:**
- **Accordion**: Expand/collapse content panels
- **Alert**: Display important messages
- **Avatar**: User profile images
- **Badge**: Status indicators
- **Banner**: Prominent message bar
- **BottomSheet**: Modal bottom sheet
- **Breadcrumbs**: Navigation hierarchy
- **Button**: Action buttons
- **Card**: Content containers
- **Checkbox**: Boolean input
- **Chip**: Compact elements for input, filter, or action
- **CircularProgress**: Circular loading indicator
- **Collapse**: Show/hide content
- **DatePicker**: Date selection
- **Dialog**: Modal dialogs
- **Divider**: Visual separator
- **Drawer**: Side navigation
- **Dropdown**: Select from a list
- **ExpansionPanel**: Expandable content
- **Fab**: Floating action button
- **IconButton**: Button with icon
- **Input**: Text input field
- **ListTile**: List item with leading/trailing widgets
- **Menu**: Popup menu
- **Pagination**: Page navigation
- **Popover**: Floating content overlay
- **ProgressBar**: Linear progress indicator
- **Radio**: Single-choice input
- **SegmentedControl**: Segmented selection
- **Select**: Dropdown selection
- **Sheet**: Modal sheet
- **Skeleton**: Loading placeholder
- **Slider**: Range input
- **Snackbar**: Temporary message
- **Stepper**: Multi-step process
- **Switch**: Toggle input
- **TabBar**: Tab navigation
- **Table**: Data table
- **Tabs**: Tabbed interface
- **Textarea**: Multi-line text input
- **Toast**: Toast notification
- **ToggleButton**: Toggleable button
- **Tooltip**: Informational hover text

## Configuration

See "Storage Configuration" in `models` package reference below in this document.

The default relay group includes: `'wss://relay.damus.io', 'wss://relay.primal.net', 'wss://nos.lol'`.

## Routing

The project uses a GoRouter with a centralized routing configuration in `router.dart`. To add new routes:

1. Create your screen in `screens`
2. Import it in `router.dart`

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

**Tailor the site's look and feel based on the user's specific request.** This includes:

- **Color schemes**: Incorporate the user's color preferences when specified, and choose an appropriate scheme that matches the application's purpose and aesthetic
- **Typography**: Choose fonts that match the requested aesthetic (modern, elegant, playful, etc.)
- **Layout**: Follow the requested structure (bottom navigation bar, drawer, grid, etc)
- **Component styling**: Use appropriate border radius, shadows, and spacing for the desired feel
- **Interactive elements**: Style buttons, forms, and hover states to match the theme

### Using Fonts

Use the `google_fonts` package.

### Loading and displaying images

Use the `cached_network_image` package.

For viewing larger images with zoom, etc use the `easy_image_viewer` package.

### Recommended Styles by Use Case

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

The project includes a complete light/dark theme system. The theme can be controlled via `themeModeProvider` provider for programmatic theme switching.

### Color Scheme Implementation

When users specify color schemes do it via Forui "Theme Color"
- Apply colors consistently across components (buttons, links, accents)
- Test both light and dark mode variants

### Component Styling Patterns

- Follow Forui patterns for component variants
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