# App Renaming Script

A powerful Dart script that renames your Flutter app across all platforms with intelligent string replacement and icon generation.

## Overview

The `tools/bin/rename_app.dart` script performs a comprehensive rename of your Flutter application by:

1. **Universal String Replacement**: Searches all project files and replaces app identifiers
2. **Smart pubspec.yaml Handling**: Specifically updates name, description, and version fields
3. **Icon Generation**: Creates platform-specific icons using `icons_launcher`
4. **Dependency Management**: Automatically cleans and reinstalls dependencies
5. **Multi-Platform Support**: Updates configuration for Android, iOS, macOS, Linux, Windows

## Usage

### Basic Usage

```bash
dart tools/bin/rename_app.dart --name "Your App Name" --app-id "com.yourcompany.yourapp"
```

### Full Example

```bash
dart tools/bin/rename_app.dart \
  --name "Task Manager Pro" \
  --app-id "com.mycompany.taskmanager" \
  --description "A professional task management application" \
  --version "1.0.0" \
  --icon "assets/icons/app_icon.png" \
  --adaptive-background "assets/icons/adaptive_bg.png" \
  --adaptive-foreground "assets/icons/adaptive_fg.png" \
  --adaptive-monochrome "assets/icons/adaptive_mono.png" \
  --notification-icon "assets/icons/notification.png"
```

## Command Line Options

| Option | Short | Description | Required | Default |
|--------|-------|-------------|----------|---------|
| `--name` | `-n` | App display name | ✅ | - |
| `--app-id` | `-i` | App ID in reverse domain notation | ✅ | - |
| `--description` | `-d` | App description for pubspec.yaml | ❌ | - |
| `--version` | `-v` | App version | ❌ | `0.1.0` |
| `--icon` | | Main app icon image path | ❌ | - |
| `--adaptive-background` | | Android adaptive background image | ❌ | - |
| `--adaptive-foreground` | | Android adaptive foreground image | ❌ | - |
| `--adaptive-monochrome` | | Android adaptive monochrome image | ❌ | - |
| `--notification-icon` | | Android notification icon image | ❌ | - |
| `--help` | `-h` | Show usage information | ❌ | - |

## What Gets Replaced

The script performs these **exact string replacements** in a specific order:

### 1. String Replacement Order (Critical!)

1. **`com.example.purplestack`** → your new app ID **(FIRST)**
2. **`Purplestack`** → your new app name
3. **`purplestack`** → your new app name in snake_case
4. **`com.example`** → your new app name **(LAST)**

> **Why This Order Matters**: App ID replacement must happen first to avoid conflicts when the app ID contains the app name.

### 2. Files Searched

The script searches **ALL files** in these directories:
- `android/` - Android configuration files
- `ios/` - iOS configuration files
- `lib/` - Dart source code
- `linux/` - Linux configuration files
- `macos/` - macOS configuration files
- `test/` - Test files
- `windows/` - Windows configuration files

**Excluded**: `tools/` directory (to protect the script itself)

### 3. Special pubspec.yaml Handling

For `pubspec.yaml`, the script does **NOT** use generic string replacement. Instead:

- **`name:`** field → Updated to snake_case version of your app name
- **`description:`** field → Updated to your description (if provided)
- **`version:`** field → Updated to your version (defaults to `0.1.0`)

## Icon Generation

When icon paths are provided, the script:

1. **Temporarily modifies** `pubspec.yaml` with `icons_launcher` configuration
2. **Runs** `dart run icons_launcher:create`
3. **Restores** the original `pubspec.yaml` content

### Supported Platforms

Icons are generated for:
- ✅ **Android** (including adaptive icons)
- ✅ **iOS**
- ✅ **macOS**
- ✅ **Windows**
- ✅ **Linux**
- ❌ **Web** (disabled)

### Icon Requirements

| Icon Type | Recommended Size | Format |
|-----------|------------------|---------|
| Main Icon | 1024×1024px | PNG |
| Adaptive Background | 432×432px | PNG |
| Adaptive Foreground | 432×432px | PNG |
| Adaptive Monochrome | 432×432px | PNG |
| Notification Icon | 192×192px | PNG |

## Input Validation

The script validates:

- **App ID Format**: Must be reverse domain notation (`com.company.app`)
  - Only lowercase letters, numbers, and dots
  - Each segment must start with a letter
- **Version Format**: Must be `x.y.z` or `x.y.z+build` (e.g., `1.0.0`, `1.2.3+4`)
- **Icon Files**: All provided icon paths must exist

## Process Flow

1. **Validate Inputs** - Check formats and file existence
2. **Update pubspec.yaml** - Specifically modify name, description, version fields
3. **Search & Replace** - Process all files in target directories with exact string replacement
4. **Clean Project** - Run `flutter clean` and `dart pub cache clean`
5. **Get Dependencies** - Run `flutter pub get`
6. **Generate Icons** - Create platform-specific icons (if icon paths provided)

## Example Output

```
Renaming Electric app...
Original App ID: com.example.purplestack → com.mycompany.taskmanager
Original App Name: Purplestack → Task Manager Pro
Original Snake Case: purplestack → task_manager_pro
Description: A professional task management application
Version: 1.0.0
Main Icon: assets/icons/app_icon.png

🔍 Searching and replacing in all files...
  ✓ Updated pubspec.yaml
  ✓ Updated android/app/build.gradle.kts
  ✓ Updated android/app/src/main/AndroidManifest.xml
  ✓ Updated ios/Runner/Info.plist
  ✓ Updated ios/Runner.xcodeproj/project.pbxproj
  ... (more files)
✅ Processed 48 files, changed 15 files

🧹 Cleaning pub cache and getting dependencies...
Running flutter clean...
Running dart pub cache clean...
Running flutter pub get...
✓ Dependencies updated successfully

🎨 Generating app icons...
✅ Icons generated successfully

✅ Electric app renamed successfully!

Next steps:
1. Test the app on your target platforms
2. Commit your changes to version control
```

## Before Running

1. **Backup your project** - Commit to git or create a copy
2. **Close your IDE** - Avoid file conflicts during the rename process  
3. **Prepare icon files** - Ensure all icon paths are correct and files exist
4. **Run from project root** - Execute the script from your Flutter project's root directory

## After Running

1. **Test the app** on your target platforms:
   ```bash
   flutter run -d android
   flutter run -d ios  # macOS only
   flutter run -d macos # macOS only
   flutter run -d linux
   flutter run -d windows
   ```

2. **Commit your changes** to version control
3. **Update app store listings** with new app name and description

## Common Use Cases

### Simple Rename
```bash
dart tools/bin/rename_app.dart \
  --name "My Cool App" \
  --app-id "com.mycoolcompany.mycoolapp"
```

### Production App with Branding
```bash
dart tools/bin/rename_app.dart \
  --name "TaskFlow Pro" \
  --app-id "com.taskflow.pro" \
  --description "Professional task management for teams" \
  --version "1.0.0" \
  --icon "branding/app_icon.png"
```

### Development Version
```bash
dart tools/bin/rename_app.dart \
  --name "TaskFlow Dev" \
  --app-id "com.taskflow.dev" \
  --description "Development build of TaskFlow" \
  --version "0.1.0"
```

## Troubleshooting

### No changes made
- Verify you're in a project with the original identifiers (`com.example.purplestack`, `Purplestack`, `purplestack`)
- Check that you're running from the Flutter project root directory

### Icon generation fails
- Ensure `icons_launcher` is in your `dev_dependencies` in `pubspec.yaml`
- Verify all icon file paths are correct and files exist
- Check that icon files are in supported formats (PNG recommended)

### Build fails after rename
- The script automatically runs `flutter clean` and `flutter pub get`
- If issues persist, try running these commands manually
- Check that all platform-specific files were updated correctly

### App ID validation errors
- Use only lowercase letters, numbers, and dots
- Each segment must start with a letter (not a number)
- Must have at least two segments (e.g., `com.app`)

## Safety Features

- **Exact String Matching**: Only replaces exact strings, preventing accidental changes
- **Binary File Safety**: Automatically skips files that can't be read as text
- **Order Protection**: App ID replacement happens first to avoid conflicts
- **Tools Directory Exclusion**: Never modifies files in the `tools/` directory
- **Validation**: Comprehensive input validation before making any changes
- **Reversible**: Changes can be undone with another rename (using original values)

## Advanced Features

### Custom Version Management
The script always overwrites the version field in `pubspec.yaml`:
- **Default**: `0.1.0` if no `--version` provided
- **Custom**: Any valid semver format (`x.y.z` or `x.y.z+build`)

### Adaptive Icon Support
Full support for Android's adaptive icon system:
- **Background**: Fills the entire safe zone
- **Foreground**: Main app icon content
- **Monochrome**: Single-color version for themed icons

### Multi-Platform Configuration
Automatically updates platform-specific configuration files:
- **Android**: `build.gradle.kts`, `AndroidManifest.xml`, Kotlin package structure
- **iOS**: `Info.plist`, Xcode project files
- **macOS**: App configuration, Xcode project files  
- **Linux**: Desktop entry files, CMake configuration
- **Windows**: Resource files, CMake configuration

This script provides a complete solution for renaming Flutter apps across all supported platforms while maintaining consistency and avoiding common pitfalls. 