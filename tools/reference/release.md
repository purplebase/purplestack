# Release Model

**Kind:** 30063 (Parameterizable Replaceable Event)  
**NIP:** Not standardized  
**Class:** `Release extends ParameterizableReplaceableModel<Release>`

## Overview

The Release model represents software releases in the Nostr ecosystem. Each release is associated with an application and contains version information, release notes, and references to downloadable files. Releases enable decentralized software distribution and version management.

## Properties

### Core Properties
- **`releaseNotes: String?`** - Release notes and changelog from event content
- **`url: String?`** - Download URL or release page
- **`channel: String?`** - Release channel (e.g., "stable", "beta", "alpha")
- **`commitId: String?`** - Git commit ID or revision identifier
- **`appIdentifier: String`** - Identifier of the associated application
- **`version: String`** - Version string (e.g., "1.2.3", "v2.0.0-beta")
- **`identifier: String`** - Combined app@version identifier

## Relationships

### Direct Relationships
- **`app: BelongsTo<App>`** - The application this release belongs to
- **`fileMetadatas: HasMany<FileMetadata>`** - File metadata for downloadable files
- **`softwareAssets: HasMany<SoftwareAsset>`** - Binary assets for this release

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The developer/organization profile
- **`reactions: HasMany<Reaction>`** - Reactions to this release
- **`zaps: HasMany<Zap>`** - Zaps sent to this release
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this release
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this release

## Usage Examples

### Creating a Release

```dart
// Create a new software release
final partialRelease = PartialRelease(
  identifier: 'my-awesome-app@1.2.3', // app-id@version
  releaseNotes: '''
# Release 1.2.3

## New Features
- Added dark mode support
- Implemented offline mode
- New sharing capabilities

## Bug Fixes
- Fixed crash on startup
- Resolved memory leak in image loading
- Improved performance on older devices

## Breaking Changes
- Minimum Android version is now 6.0
- API endpoint changes (see migration guide)

## Download
Available for Android, iOS, and Web.
  ''',
  url: 'https://github.com/developer/my-awesome-app/releases/tag/v1.2.3',
  channel: 'stable',
  commitId: 'abc123def456',
);

// Set app identifier and version separately
partialRelease.setTagValue('i', 'my-awesome-app');
partialRelease.setTagValue('version', '1.2.3');

// Link to file metadata for downloadable files
partialRelease.addTagValue('e', fileMetadata1.id);
partialRelease.addTagValue('e', fileMetadata2.id);

final signedRelease = await partialRelease.signWith(signer);
await signedRelease.publish();
```

### Querying Releases

```dart
// Get all releases for an app
final appReleasesState = ref.watch(
  query<Release>(
    tags: {
      '#i': {appIdentifier},
    },
    and: (release) => {
      release.app,
      release.fileMetadatas,
      release.author,
    },
  ),
);

// Get latest releases across all apps
final latestReleasesState = ref.watch(
  query<Release>(
    since: DateTime.now().subtract(Duration(days: 30)),
    limit: 20,
    and: (release) => {
      release.app,
      release.fileMetadatas,
    },
    where: (release) => release.channel == 'stable',
  ),
);

// Get beta releases for testing
final betaReleasesState = ref.watch(
  query<Release>(
    tags: {
      '#c': {'beta'},
    },
    limit: 10,
    and: (release) => {
      release.app,
      release.author,
    },
  ),
);
```

### Working with Releases

```dart
// Display release information
Widget buildReleaseCard(Release release) {
  final app = release.app.value;
  final author = release.author.value;
  
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Release header
          Row(
            children: [
              if (app != null && app.icons.isNotEmpty)
                CircleAvatar(
                  backgroundImage: NetworkImage(app.icons.first),
                  radius: 20,
                )
              else
                CircleAvatar(
                  child: Text(app?.name?[0] ?? '?'),
                  radius: 20,
                ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${app?.name ?? release.appIdentifier} v${release.version}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Chip(
                          label: Text(release.channel ?? 'stable'),
                          backgroundColor: _getChannelColor(release.channel),
                        ),
                        if (release.commitId != null) ...[
                          SizedBox(width: 8),
                          Text(
                            release.commitId!.substring(0, 7),
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(formatTimestamp(release.createdAt)),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Release notes
          if (release.releaseNotes != null) ...[
            Text(
              'Release Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: MarkdownBody(
                data: release.releaseNotes!,
                selectable: true,
              ),
            ),
            SizedBox(height: 16),
          ],
          
          // Download files
          if (release.fileMetadatas.isNotEmpty) ...[
            Text(
              'Downloads',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...release.fileMetadatas.map((fileMetadata) {
              return Card(
                child: ListTile(
                  leading: Icon(_getFileIcon(fileMetadata.mimeType)),
                  title: Text(_getFileName(fileMetadata)),
                  subtitle: Text(
                    '${_formatFileSize(fileMetadata.size)} • ${fileMetadata.platforms.join(', ')}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () => _downloadFile(fileMetadata),
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 16),
          ],
          
          // Actions
          Row(
            children: [
              TextButton.icon(
                icon: Icon(Icons.favorite_border),
                label: Text('${release.reactions.length}'),
                onPressed: () => _reactToRelease(release),
              ),
              TextButton.icon(
                icon: Icon(Icons.flash_on),
                label: Text('${release.zaps.length}'),
                onPressed: () => _zapRelease(release),
              ),
              if (release.url != null)
                TextButton.icon(
                  icon: Icon(Icons.open_in_new),
                  label: Text('Release Page'),
                  onPressed: () => _openUrl(release.url!),
                ),
              Spacer(),
              if (author != null)
                Chip(
                  avatar: CircleAvatar(
                    backgroundImage: author.pictureUrl != null 
                      ? NetworkImage(author.pictureUrl!)
                      : null,
                    child: author.pictureUrl == null 
                      ? Text(author.nameOrNpub[0])
                      : null,
                  ),
                  label: Text(author.nameOrNpub),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

Color _getChannelColor(String? channel) {
  switch (channel?.toLowerCase()) {
    case 'stable': return Colors.green[100]!;
    case 'beta': return Colors.orange[100]!;
    case 'alpha': return Colors.red[100]!;
    case 'nightly': return Colors.purple[100]!;
    default: return Colors.grey[100]!;
  }
}

IconData _getFileIcon(String? mimeType) {
  if (mimeType == null) return Icons.file_copy;
  
  if (mimeType.contains('android')) return Icons.android;
  if (mimeType.contains('application/vnd.android.package-archive')) return Icons.android;
  if (mimeType.contains('zip')) return Icons.archive;
  if (mimeType.contains('dmg')) return Icons.laptop_mac;
  if (mimeType.contains('exe') || mimeType.contains('msi')) return Icons.laptop_windows;
  if (mimeType.contains('deb') || mimeType.contains('rpm')) return Icons.laptop;
  
  return Icons.file_copy;
}

String _getFileName(FileMetadata fileMetadata) {
  if (fileMetadata.urls.isNotEmpty) {
    final url = fileMetadata.urls.first;
    return url.split('/').last;
  }
  return 'Download';
}

String _formatFileSize(int? bytes) {
  if (bytes == null) return 'Unknown size';
  
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
```

### Version Management

```dart
class VersionManager {
  static bool isNewerVersion(String current, String comparison) {
    final currentParts = _parseVersion(current);
    final comparisonParts = _parseVersion(comparison);
    
    for (int i = 0; i < 3; i++) {
      if (comparisonParts[i] > currentParts[i]) return true;
      if (comparisonParts[i] < currentParts[i]) return false;
    }
    
    return false;
  }
  
  static List<int> _parseVersion(String version) {
    final cleaned = version.replaceAll(RegExp(r'[^0-9.]'), '');
    final parts = cleaned.split('.');
    
    return [
      int.tryParse(parts.elementAtOrNull(0) ?? '0') ?? 0,
      int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0,
      int.tryParse(parts.elementAtOrNull(2) ?? '0') ?? 0,
    ];
  }
  
  static List<Release> sortReleasesByVersion(List<Release> releases) {
    final sorted = List<Release>.from(releases);
    sorted.sort((a, b) {
      final aParts = _parseVersion(a.version);
      final bParts = _parseVersion(b.version);
      
      for (int i = 0; i < 3; i++) {
        final compare = bParts[i].compareTo(aParts[i]);
        if (compare != 0) return compare;
      }
      
      return 0;
    });
    
    return sorted;
  }
  
  static Release? getLatestStableRelease(List<Release> releases) {
    final stableReleases = releases.where(
      (r) => r.channel == null || r.channel == 'stable',
    ).toList();
    
    if (stableReleases.isEmpty) return null;
    
    return sortReleasesByVersion(stableReleases).first;
  }
}
```

### Release Analytics

```dart
class ReleaseAnalytics {
  static Map<String, dynamic> analyzeReleases(List<Release> releases) {
    if (releases.isEmpty) return {'total_releases': 0};
    
    // Channel distribution
    final channelCounts = <String, int>{};
    for (final release in releases) {
      final channel = release.channel ?? 'stable';
      channelCounts[channel] = (channelCounts[channel] ?? 0) + 1;
    }
    
    // Release frequency
    final sortedReleases = List<Release>.from(releases)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    Duration? averageInterval;
    if (sortedReleases.length > 1) {
      final totalDuration = sortedReleases.last.createdAt
        .difference(sortedReleases.first.createdAt);
      averageInterval = Duration(
        milliseconds: totalDuration.inMilliseconds ~/ (sortedReleases.length - 1),
      );
    }
    
    // File statistics
    final totalFiles = releases.fold<int>(
      0, 
      (sum, release) => sum + release.fileMetadatas.length,
    );
    
    // Engagement
    final totalReactions = releases.fold<int>(
      0, 
      (sum, release) => sum + release.reactions.length,
    );
    
    final totalZaps = releases.fold<int>(
      0, 
      (sum, release) => sum + release.zaps.length,
    );
    
    return {
      'total_releases': releases.length,
      'channel_distribution': channelCounts,
      'release_frequency': {
        'average_interval_days': averageInterval?.inDays,
        'first_release': sortedReleases.first.createdAt.toIso8601String(),
        'latest_release': sortedReleases.last.createdAt.toIso8601String(),
      },
      'files': {
        'total_files': totalFiles,
        'average_files_per_release': releases.isEmpty 
          ? 0.0 
          : totalFiles / releases.length,
      },
      'engagement': {
        'total_reactions': totalReactions,
        'total_zaps': totalZaps,
        'average_reactions_per_release': releases.isEmpty 
          ? 0.0 
          : totalReactions / releases.length,
      },
    };
  }
}
```

### Release Notifications

```dart
class ReleaseNotificationService {
  static Future<void> checkForUpdates(
    Ref ref, 
    String appIdentifier,
    String currentVersion,
  ) async {
    final releases = await ref.storage.query(
      RequestFilter<Release>(
        tags: {
          '#i': {appIdentifier},
          '#c': {'stable'}, // Only stable releases
        },
        limit: 10,
      ).toRequest(),
    );
    
    final sortedReleases = VersionManager.sortReleasesByVersion(releases);
    
    if (sortedReleases.isNotEmpty) {
      final latestVersion = sortedReleases.first.version;
      
      if (VersionManager.isNewerVersion(currentVersion, latestVersion)) {
        _showUpdateNotification(sortedReleases.first);
      }
    }
  }
  
  static void _showUpdateNotification(Release release) {
    // Show update notification UI
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text('Update Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version ${release.version} is now available!'),
            if (release.releaseNotes != null) ...[
              SizedBox(height: 16),
              Text('What\'s New:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                height: 200,
                child: SingleChildScrollView(
                  child: MarkdownBody(data: release.releaseNotes!),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadRelease(release);
            },
            child: Text('Update Now'),
          ),
        ],
      ),
    );
  }
}
```

## Best Practices

### Version Naming
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Include pre-release identifiers for non-stable versions
- Be consistent with version string format
- Tag releases appropriately (stable, beta, alpha, etc.)

### Release Notes
- Write clear, user-focused changelog entries
- Categorize changes (features, fixes, breaking changes)
- Include migration guides for breaking changes
- Mention security updates prominently

### Technical Considerations
```dart
// Consistent identifier format
final partialRelease = PartialRelease(
  identifier: '${appId}@${version}', // Use @ separator
  releaseNotes: releaseNotes,
  channel: 'stable', // Use standard channel names
);

// Standard channel names
'stable'    // Production releases
'beta'      // Feature-complete pre-releases  
'alpha'     // Early development releases
'nightly'   // Automated development builds
```

## Related Models

- **[App](app.md)** - The application this release belongs to
- **[FileMetadata](file-metadata.md)** - Downloadable files for this release
- **[Profile](profile.md)** - Developer profiles and organizations
- **[Reaction](reaction.md)** - User reactions to releases
- **[Zap](zap.md)** - Lightning payments to developers

## Implementation Notes

- Releases use parameterizable replaceable events (kind 30063) - not yet standardized
- The identifier combines app ID and version: `appId@version`
- Channel tag (`c`) indicates release stability level
- File references use `e` tags pointing to FileMetadata events
- Repository commit IDs help with verification and debugging
- Releases can be updated by the same author with the same identifier
- Consider implementing cryptographic signature verification for security 