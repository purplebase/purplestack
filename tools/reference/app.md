# App Model

**Kind:** 32267 (Parameterizable Replaceable Event)  
**NIP:** Not standardized  
**Class:** `App extends ParameterizableReplaceableModel<App>`

## Overview

The App model represents software applications and their metadata in the Nostr ecosystem. It serves as a decentralized app store entry, containing information about applications, their descriptions, platforms, and related releases. Apps are identified by a unique identifier and can have multiple releases associated with them.

## Properties

### Core Properties
- **`name: String?`** - Display name of the application
- **`description: String`** - Full description from event content
- **`summary: String?`** - Short summary or tagline
- **`url: String?`** - Homepage or main URL for the application
- **`repository: String?`** - Source code repository URL
- **`license: String?`** - Software license (e.g., "MIT", "GPL-3.0")

### Media and Platform
- **`icons: Set<String>`** - Set of icon URLs for different sizes
- **`images: Set<String>`** - Screenshots and promotional images
- **`platforms: Set<String>`** - Supported platforms (e.g., "android", "ios", "web", "windows")

## Relationships

### Direct Relationships
- **`releases: HasMany<Release>`** - All releases for this application
- **`latestRelease: BelongsTo<Release>`** - Most recent release

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The developer/organization profile
- **`reactions: HasMany<Reaction>`** - Reactions to this app
- **`zaps: HasMany<Zap>`** - Zaps sent to this app
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this app
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this app

## Usage Examples

### Creating an App Listing

```dart
// Create a new app listing
final partialApp = PartialApp(
  identifier: 'my-awesome-app', // Unique app identifier
  name: 'My Awesome App',
  summary: 'The most awesome app you\'ll ever use',
  description: '''
# My Awesome App

A revolutionary application that changes everything!

## Features
- Feature 1: Amazing functionality
- Feature 2: Incredible performance  
- Feature 3: Beautiful design

## How to Use
1. Download the app
2. Create an account
3. Start being awesome

Built with love using Flutter and Nostr.
  ''',
  url: 'https://myawesomeapp.com',
  repository: 'https://github.com/developer/my-awesome-app',
  license: 'MIT',
);

// Add platform support
partialApp.addPlatform('android');
partialApp.addPlatform('ios');
partialApp.addPlatform('web');

// Add media assets
partialApp.addIcon('https://myawesomeapp.com/icon-512.png');
partialApp.addIcon('https://myawesomeapp.com/icon-256.png');
partialApp.addImage('https://myawesomeapp.com/screenshot1.png');
partialApp.addImage('https://myawesomeapp.com/screenshot2.png');

final signedApp = await partialApp.signWith(signer);
await signedApp.publish();
```

### Querying Apps

```dart
// Get all apps by a developer
final developerAppsState = ref.watch(
  query<App>(
    authors: {developerPubkey},
    and: (app) => {
      app.author,
      app.latestRelease,
    },
  ),
);

// Search apps by platform
final androidAppsState = ref.watch(
  query<App>(
    tags: {
      '#f': {'android'},
    },
    limit: 50,
    and: (app) => {
      app.author,
      app.releases,
    },
  ),
);

// Get featured apps (with many reactions/zaps)
final featuredAppsState = ref.watch(
  query<App>(
    limit: 20,
    and: (app) => {
      app.author,
      app.reactions,
      app.zaps,
      app.latestRelease,
    },
    where: (app) {
      // Filter for apps with engagement
      return app.reactions.length > 5 || app.zaps.length > 1;
    },
  ),
);
```

### Working with App Data

```dart
// Display app card
Widget buildAppCard(App app) {
  final author = app.author.value;
  final latestRelease = app.latestRelease.value;
  
  return Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App icon and basic info
        ListTile(
          leading: app.icons.isNotEmpty 
            ? CircleAvatar(
                backgroundImage: NetworkImage(app.icons.first),
              )
            : CircleAvatar(
                child: Text(app.name?[0] ?? '?'),
              ),
          title: Text(
            app.name ?? app.identifier,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(app.summary ?? ''),
          trailing: author != null 
            ? Chip(
                avatar: CircleAvatar(
                  backgroundImage: author.pictureUrl != null 
                    ? NetworkImage(author.pictureUrl!)
                    : null,
                  child: author.pictureUrl == null 
                    ? Text(author.nameOrNpub[0])
                    : null,
                ),
                label: Text(author.nameOrNpub),
              )
            : null,
        ),
        
        // Screenshots
        if (app.images.isNotEmpty) ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: app.images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      app.images.elementAt(index),
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
        ],
        
        // Platform badges
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: app.platforms.map((platform) {
              return Chip(
                label: Text(platform.toUpperCase()),
                backgroundColor: _getPlatformColor(platform),
              );
            }).toList(),
          ),
        ),
        
        // Description preview
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            _extractPlainText(app.description),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Latest release info
        if (latestRelease != null) ...[
          Divider(),
          ListTile(
            leading: Icon(Icons.new_releases),
            title: Text('Version ${latestRelease.version}'),
            subtitle: Text('Latest Release'),
            trailing: TextButton(
              onPressed: () => _downloadLatestRelease(latestRelease),
              child: Text('Download'),
            ),
          ),
        ],
        
        // Actions
        ButtonBar(
          children: [
            TextButton.icon(
              icon: Icon(Icons.favorite_border),
              label: Text('${app.reactions.length}'),
              onPressed: () => _reactToApp(app),
            ),
            TextButton.icon(
              icon: Icon(Icons.flash_on),
              label: Text('${app.zaps.length}'),
              onPressed: () => _zapApp(app),
            ),
            if (app.url != null)
              TextButton.icon(
                icon: Icon(Icons.open_in_new),
                label: Text('Website'),
                onPressed: () => _openUrl(app.url!),
              ),
          ],
        ),
      ],
    ),
  );
}

Color _getPlatformColor(String platform) {
  switch (platform.toLowerCase()) {
    case 'android': return Colors.green;
    case 'ios': return Colors.blue;
    case 'web': return Colors.orange;
    case 'windows': return Colors.blue[700]!;
    case 'macos': return Colors.grey;
    case 'linux': return Colors.purple;
    default: return Colors.grey;
  }
}

String _extractPlainText(String markdown) {
  // Simple markdown-to-text conversion
  return markdown
    .replaceAll(RegExp(r'#+ '), '')
    .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1')
    .replaceAll(RegExp(r'\*\*([^\*]+)\*\*'), r'$1')
    .replaceAll(RegExp(r'\*([^\*]+)\*'), r'$1')
    .trim();
}
```

### App Discovery and Categories

```dart
class AppStore {
  static Future<List<App>> getPopularApps(Ref ref, {int limit = 20}) async {
    final apps = await ref.storage.query(
      RequestFilter<App>(
        limit: limit * 3, // Get more to filter
      ).toRequest(),
    );
    
    // Sort by engagement (reactions + zaps)
    apps.sort((a, b) {
      final aScore = a.reactions.length + a.zaps.length * 2; // Zaps worth more
      final bScore = b.reactions.length + b.zaps.length * 2;
      return bScore.compareTo(aScore);
    });
    
    return apps.take(limit).toList();
  }
  
  static Future<List<App>> getAppsByCategory(
    Ref ref, 
    String platform, {
    int limit = 50,
  }) async {
    return await ref.storage.query(
      RequestFilter<App>(
        tags: {
          '#f': {platform},
        },
        limit: limit,
      ).toRequest(),
    );
  }
  
  static Future<List<App>> searchApps(
    Ref ref, 
    String query, {
    int limit = 30,
  }) async {
    final allApps = await ref.storage.query(
      RequestFilter<App>(limit: 500).toRequest(),
    );
    
    // Simple text search
    final searchTerms = query.toLowerCase().split(' ');
    final matchingApps = allApps.where((app) {
      final searchText = [
        app.name?.toLowerCase() ?? '',
        app.summary?.toLowerCase() ?? '',
        app.description.toLowerCase(),
        app.identifier.toLowerCase(),
      ].join(' ');
      
      return searchTerms.every((term) => searchText.contains(term));
    }).toList();
    
    return matchingApps.take(limit).toList();
  }
}
```

### App Analytics

```dart
class AppAnalytics {
  static Map<String, dynamic> analyzeApp(App app) {
    // Platform distribution
    final platformCounts = <String, int>{};
    for (final platform in app.platforms) {
      platformCounts[platform] = (platformCounts[platform] ?? 0) + 1;
    }
    
    // Engagement metrics
    final totalReactions = app.reactions.length;
    final totalZaps = app.zaps.length;
    final totalZapAmount = app.zaps.fold<int>(
      0, 
      (sum, zap) => sum + (zap.amount ?? 0),
    );
    
    // Release frequency
    final releases = app.releases.toList();
    releases.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    Duration? averageReleaseInterval;
    if (releases.length > 1) {
      final totalDuration = releases.last.createdAt.difference(releases.first.createdAt);
      averageReleaseInterval = Duration(
        milliseconds: totalDuration.inMilliseconds ~/ (releases.length - 1),
      );
    }
    
    return {
      'engagement': {
        'total_reactions': totalReactions,
        'total_zaps': totalZaps,
        'total_zap_amount': totalZapAmount,
        'engagement_score': totalReactions + (totalZaps * 2),
      },
      'platforms': platformCounts,
      'releases': {
        'total_releases': releases.length,
        'latest_version': app.latestRelease.value?.version,
        'average_release_interval_days': averageReleaseInterval?.inDays,
      },
      'media': {
        'icon_count': app.icons.length,
        'screenshot_count': app.images.length,
      },
      'metadata': {
        'has_repository': app.repository != null,
        'has_license': app.license != null,
        'has_website': app.url != null,
        'description_length': app.description.length,
      },
    };
  }
  
  static Map<String, dynamic> compareApps(List<App> apps) {
    final platformUsage = <String, int>{};
    final licenseUsage = <String, int>{};
    
    for (final app in apps) {
      // Platform statistics
      for (final platform in app.platforms) {
        platformUsage[platform] = (platformUsage[platform] ?? 0) + 1;
      }
      
      // License statistics
      if (app.license != null) {
        licenseUsage[app.license!] = (licenseUsage[app.license!] ?? 0) + 1;
      }
    }
    
    return {
      'total_apps': apps.length,
      'platform_distribution': platformUsage,
      'license_distribution': licenseUsage,
      'average_engagement': apps.isEmpty ? 0.0 : apps.fold<double>(
        0.0,
        (sum, app) => sum + app.reactions.length + app.zaps.length,
      ) / apps.length,
      'apps_with_releases': apps.where((app) => app.releases.isNotEmpty).length,
    };
  }
}
```

### Updating Apps

```dart
// Update app information
Future<App> updateApp(App existingApp, Map<String, dynamic> updates) async {
  final partialApp = PartialApp.fromMap(existingApp.event.data);
  
  // Update fields
  if (updates.containsKey('name')) {
    partialApp.name = updates['name'];
  }
  
  if (updates.containsKey('summary')) {
    partialApp.summary = updates['summary'];
  }
  
  if (updates.containsKey('description')) {
    partialApp.description = updates['description'];
  }
  
  if (updates.containsKey('url')) {
    partialApp.url = updates['url'];
  }
  
  if (updates.containsKey('repository')) {
    partialApp.repository = updates['repository'];
  }
  
  // Update platforms
  if (updates.containsKey('platforms')) {
    partialApp.platforms = Set<String>.from(updates['platforms']);
  }
  
  // Update icons
  if (updates.containsKey('icons')) {
    partialApp.icons = Set<String>.from(updates['icons']);
  }
  
  // Update images
  if (updates.containsKey('images')) {
    partialApp.images = Set<String>.from(updates['images']);
  }
  
  final signedApp = await partialApp.signWith(signer);
  await signedApp.publish();
  
  return signedApp;
}
```

## Best Practices

### App Listing Guidelines
- Use clear, descriptive names and summaries
- Provide comprehensive descriptions with features and usage
- Include high-quality icons and screenshots
- Specify accurate platform support
- Keep repository and website URLs current
- Use standard license identifiers (SPDX format)

### Technical Considerations
```dart
// Use consistent app identifiers
final partialApp = PartialApp(
  identifier: 'com.company.appname', // Use reverse domain notation
  name: 'App Name',
  // ... other fields
);

// Properly categorize platforms
partialApp.addPlatform('android');   // Mobile Android
partialApp.addPlatform('ios');       // Mobile iOS
partialApp.addPlatform('web');       // Web application
partialApp.addPlatform('windows');   // Desktop Windows
partialApp.addPlatform('macos');     // Desktop macOS
partialApp.addPlatform('linux');     // Desktop Linux
```

### User Experience
- Show clear platform availability
- Display engagement metrics (reactions, zaps)
- Provide easy access to downloads and websites
- Include developer information and credibility
- Support app discovery through categories and search

## Related Models

- **[Release](release.md)** - Software releases for this app
- **[FileMetadata](file-metadata.md)** - File information for app releases
- **[Profile](profile.md)** - Developer profiles and organizations
- **[Reaction](reaction.md)** - User reactions to apps
- **[Zap](zap.md)** - Lightning payments to app developers
- **[GenericRepost](generic-repost.md)** - App recommendations and sharing

## Implementation Notes

- Apps use parameterizable replaceable events (kind 32267) - not yet standardized
- The identifier serves as the unique app ID and should be stable
- Platform tags (`f`) use lowercase platform names
- Icon and image URLs should be accessible and permanent
- Repository URLs help with open-source verification
- Apps can be updated by the same author with the same identifier
- Consider implementing app verification for official listings
- Support for app categories could be added via additional tags 