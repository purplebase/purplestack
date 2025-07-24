# FileMetadata Model

**Kind:** 1063 (Regular Event)  
**NIP:** NIP-94  
**Class:** `FileMetadata extends RegularModel<FileMetadata>`

## Overview

The FileMetadata model represents file information and metadata in the Nostr ecosystem. It contains details about downloadable files such as applications, documents, or media. FileMetadata events are typically associated with software releases and provide essential information for secure file distribution including URLs, hashes, sizes, and platform compatibility.

## Properties

### Core Properties
- **`urls: Set<String>`** - Set of download URLs for the file
- **`mimeType: String?`** - MIME type of the file (e.g., "application/vnd.android.package-archive")
- **`hash: String`** - SHA-256 hash of the file for integrity verification
- **`size: int?`** - File size in bytes

### Application Properties
- **`repository: String?`** - Source code repository URL
- **`platforms: Set<String>`** - Supported platforms (e.g., "android", "ios")
- **`executables: Set<String>`** - Executable file names within the package
- **`appIdentifier: String`** - Application identifier
- **`version: String`** - Application version

### Platform-Specific Properties
- **`minSdkVersion: String`** - Minimum SDK version required
- **`targetSdkVersion: String`** - Target SDK version

### Android-Specific Properties
- **`versionCode: int?`** - Android version code
- **`apkSignatureHash: String?`** - APK signature hash for verification

## Relationships

### Direct Relationships
- **`release: BelongsTo<Release>`** - The software release this file belongs to

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The profile that published this file metadata
- **`reactions: HasMany<Reaction>`** - Reactions to this file
- **`zaps: HasMany<Zap>`** - Zaps sent for this file
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this file
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this file

## Usage Examples

### Creating File Metadata

```dart
// Create metadata for an Android APK
final partialFileMetadata = PartialFileMetadata(
  urls: {
    'https://cdn.example.com/myapp-v1.2.3.apk',
    'https://github.com/dev/myapp/releases/download/v1.2.3/myapp-v1.2.3.apk',
  },
  mimeType: 'application/vnd.android.package-archive',
  hash: 'a1b2c3d4e5f6789...', // SHA-256 hash
  size: 15728640, // 15MB in bytes
  appIdentifier: 'com.example.myapp',
  version: '1.2.3',
  minSdkVersion: '21', // Android 5.0
  targetSdkVersion: '34', // Android 14
  versionCode: 10203,
  apkSignatureHash: 'def456...',
);

// Add platform and executable info
partialFileMetadata.addPlatform('android');
partialFileMetadata.addExecutable('myapp');

final signedFileMetadata = await partialFileMetadata.signWith(signer);
await signedFileMetadata.publish();
```

### Creating Metadata for Different File Types

```dart
// iOS App Bundle
final iosFileMetadata = PartialFileMetadata(
  urls: {'https://cdn.example.com/MyApp.ipa'},
  mimeType: 'application/octet-stream',
  hash: 'sha256hash...',
  size: 25165824, // 24MB
  appIdentifier: 'com.example.myapp',
  version: '1.2.3',
  minSdkVersion: '12.0',
  targetSdkVersion: '17.0',
);
partialFileMetadata.addPlatform('ios');

// Windows Executable
final windowsFileMetadata = PartialFileMetadata(
  urls: {'https://cdn.example.com/MyApp-Setup.exe'},
  mimeType: 'application/x-msdownload',
  hash: 'sha256hash...',
  size: 52428800, // 50MB
  appIdentifier: 'com.example.myapp',
  version: '1.2.3',
);
partialFileMetadata.addPlatform('windows');
partialFileMetadata.addExecutable('MyApp.exe');

// macOS DMG
final macFileMetadata = PartialFileMetadata(
  urls: {'https://cdn.example.com/MyApp-1.2.3.dmg'},
  mimeType: 'application/x-apple-diskimage',
  hash: 'sha256hash...',
  size: 31457280, // 30MB
  appIdentifier: 'com.example.myapp',
  version: '1.2.3',
);
partialFileMetadata.addPlatform('macos');

// Linux AppImage
final linuxFileMetadata = PartialFileMetadata(
  urls: {'https://cdn.example.com/MyApp-1.2.3.AppImage'},
  mimeType: 'application/x-executable',
  hash: 'sha256hash...',
  size: 41943040, // 40MB
  appIdentifier: 'com.example.myapp',
  version: '1.2.3',
);
partialFileMetadata.addPlatform('linux');
partialFileMetadata.addExecutable('MyApp');
```

### Querying File Metadata

```dart
// Get file metadata for a specific release
final releaseFilesState = ref.watch(
  query<FileMetadata>(
    tags: {
      '#i': {appIdentifier},
      '#version': {version},
    },
    and: (file) => {
      file.release,
      file.author,
    },
  ),
);

// Get files by platform
final androidFilesState = ref.watch(
  query<FileMetadata>(
    tags: {
      '#f': {'android'},
    },
    limit: 50,
    and: (file) => {
      file.release,
    },
  ),
);

// Get recent file uploads
final recentFilesState = ref.watch(
  query<FileMetadata>(
    since: DateTime.now().subtract(Duration(days: 7)),
    limit: 20,
    and: (file) => {
      file.author,
      file.release,
    },
  ),
);
```

### Working with File Downloads

```dart
// File download and verification
class FileDownloader {
  static Future<File> downloadAndVerify(FileMetadata fileMetadata) async {
    final urls = fileMetadata.urls.toList();
    Exception? lastException;
    
    // Try each URL until one succeeds
    for (final url in urls) {
      try {
        final file = await _downloadFromUrl(url);
        
        // Verify file integrity
        if (await _verifyFileHash(file, fileMetadata.hash)) {
          return file;
        } else {
          throw Exception('Hash verification failed for $url');
        }
      } catch (e) {
        lastException = e as Exception;
        continue;
      }
    }
    
    throw lastException ?? Exception('All download URLs failed');
  }
  
  static Future<File> _downloadFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Download failed: ${response.statusCode}');
    }
    
    final filename = url.split('/').last;
    final file = File('${Directory.systemTemp.path}/$filename');
    await file.writeAsBytes(response.bodyBytes);
    
    return file;
  }
  
  static Future<bool> _verifyFileHash(File file, String expectedHash) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString() == expectedHash.toLowerCase();
  }
}

// Display file information
Widget buildFileMetadataCard(FileMetadata fileMetadata) {
  final release = fileMetadata.release.value;
  final author = fileMetadata.author.value;
  
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File header
          Row(
            children: [
              Icon(_getFileIcon(fileMetadata.mimeType), size: 48),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFileName(fileMetadata),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${fileMetadata.appIdentifier} v${fileMetadata.version}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (fileMetadata.size != null)
                      Text(
                        _formatFileSize(fileMetadata.size!),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Platform badges
          if (fileMetadata.platforms.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              children: fileMetadata.platforms.map((platform) {
                return Chip(
                  label: Text(platform.toUpperCase()),
                  backgroundColor: _getPlatformColor(platform),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
          ],
          
          // Technical details
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Technical Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                _buildDetailRow('MIME Type', fileMetadata.mimeType),
                _buildDetailRow('SHA-256', fileMetadata.hash, isHash: true),
                if (fileMetadata.minSdkVersion.isNotEmpty)
                  _buildDetailRow('Min SDK', fileMetadata.minSdkVersion),
                if (fileMetadata.targetSdkVersion.isNotEmpty)
                  _buildDetailRow('Target SDK', fileMetadata.targetSdkVersion),
                if (fileMetadata.versionCode != null)
                  _buildDetailRow('Version Code', fileMetadata.versionCode.toString()),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Download options
          Text(
            'Download Links',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...fileMetadata.urls.map((url) {
            return Card(
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text(_getUrlDisplayName(url)),
                subtitle: Text(url),
                trailing: IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(url),
                ),
                onTap: () => _downloadFile(fileMetadata, url),
              ),
            );
          }).toList(),
          
          // Actions
          SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.download),
                label: Text('Download & Verify'),
                onPressed: () => _downloadAndVerify(fileMetadata),
              ),
              SizedBox(width: 8),
              TextButton.icon(
                icon: Icon(Icons.security),
                label: Text('Verify Hash'),
                onPressed: () => _showHashVerification(fileMetadata),
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

Widget _buildDetailRow(String label, String? value, {bool isHash = false}) {
  if (value == null || value.isEmpty) return SizedBox.shrink();
  
  return Padding(
    padding: EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: SelectableText(
            isHash ? '${value.substring(0, 16)}...' : value,
            style: TextStyle(
              fontFamily: isHash ? 'monospace' : null,
              fontSize: isHash ? 12 : 14,
            ),
          ),
        ),
      ],
    ),
  );
}

String _getFileName(FileMetadata fileMetadata) {
  if (fileMetadata.urls.isNotEmpty) {
    final url = fileMetadata.urls.first;
    return url.split('/').last;
  }
  return '${fileMetadata.appIdentifier}-${fileMetadata.version}';
}

String _getUrlDisplayName(String url) {
  final uri = Uri.parse(url);
  return uri.host;
}

IconData _getFileIcon(String? mimeType) {
  if (mimeType == null) return Icons.file_copy;
  
  if (mimeType.contains('android') || mimeType.contains('vnd.android')) return Icons.android;
  if (mimeType.contains('apple') || mimeType.contains('x-apple')) return Icons.laptop_mac;
  if (mimeType.contains('msdownload') || mimeType.contains('x-msdownload')) return Icons.laptop_windows;
  if (mimeType.contains('executable')) return Icons.laptop;
  if (mimeType.contains('zip') || mimeType.contains('archive')) return Icons.archive;
  if (mimeType.contains('image')) return Icons.image;
  if (mimeType.contains('video')) return Icons.video_file;
  if (mimeType.contains('audio')) return Icons.audio_file;
  
  return Icons.file_copy;
}

Color _getPlatformColor(String platform) {
  switch (platform.toLowerCase()) {
    case 'android': return Colors.green[100]!;
    case 'ios': return Colors.blue[100]!;
    case 'windows': return Colors.blue[700]!.withOpacity(0.2);
    case 'macos': return Colors.grey[300]!;
    case 'linux': return Colors.purple[100]!;
    case 'web': return Colors.orange[100]!;
    default: return Colors.grey[100]!;
  }
}

String _formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
```

### Security and Verification

```dart
class FileVerification {
  static Future<bool> verifyFileIntegrity(
    File file, 
    FileMetadata metadata,
  ) async {
    // Verify SHA-256 hash
    final bytes = await file.readAsBytes();
    final actualHash = sha256.convert(bytes).toString();
    
    if (actualHash.toLowerCase() != metadata.hash.toLowerCase()) {
      return false;
    }
    
    // Additional platform-specific verification
    if (metadata.platforms.contains('android')) {
      return await _verifyAndroidApk(file, metadata);
    }
    
    return true;
  }
  
  static Future<bool> _verifyAndroidApk(
    File file, 
    FileMetadata metadata,
  ) async {
    try {
      // Verify APK signature if provided
      if (metadata.apkSignatureHash != null) {
        final signatureValid = await _verifyApkSignature(
          file, 
          metadata.apkSignatureHash!,
        );
        if (!signatureValid) return false;
      }
      
      // Verify minimum requirements are met
      if (metadata.minSdkVersion.isNotEmpty) {
        final minSdk = int.tryParse(metadata.minSdkVersion);
        if (minSdk != null && minSdk < 21) {
          // Warn about very old Android versions
          print('Warning: Minimum SDK version is very old (${metadata.minSdkVersion})');
        }
      }
      
      return true;
    } catch (e) {
      print('APK verification failed: $e');
      return false;
    }
  }
  
  static Future<bool> _verifyApkSignature(File file, String expectedHash) async {
    // Implementation would use Android APK parsing
    // This is a simplified example
    try {
      // Extract signature from APK and compare hash
      // Real implementation would parse the APK file structure
      return true; // Placeholder
    } catch (e) {
      return false;
    }
  }
}
```

### File Analytics

```dart
class FileAnalytics {
  static Map<String, dynamic> analyzeFiles(List<FileMetadata> files) {
    if (files.isEmpty) return {'total_files': 0};
    
    // Platform distribution
    final platformCounts = <String, int>{};
    for (final file in files) {
      for (final platform in file.platforms) {
        platformCounts[platform] = (platformCounts[platform] ?? 0) + 1;
      }
    }
    
    // File type distribution
    final mimeTypeCounts = <String, int>{};
    for (final file in files) {
      final mimeType = file.mimeType ?? 'unknown';
      mimeTypeCounts[mimeType] = (mimeTypeCounts[mimeType] ?? 0) + 1;
    }
    
    // Size statistics
    final sizes = files.where((f) => f.size != null).map((f) => f.size!).toList();
    sizes.sort();
    
    final totalSize = sizes.fold<int>(0, (sum, size) => sum + size);
    final averageSize = sizes.isEmpty ? 0.0 : totalSize / sizes.length;
    final medianSize = sizes.isEmpty ? 0 : sizes[sizes.length ~/ 2];
    
    return {
      'total_files': files.length,
      'platform_distribution': platformCounts,
      'mime_type_distribution': mimeTypeCounts,
      'size_statistics': {
        'total_size_bytes': totalSize,
        'average_size_bytes': averageSize,
        'median_size_bytes': medianSize,
        'largest_file_bytes': sizes.isEmpty ? 0 : sizes.last,
        'smallest_file_bytes': sizes.isEmpty ? 0 : sizes.first,
      },
      'security': {
        'files_with_hash': files.where((f) => f.hash.isNotEmpty).length,
        'android_files_with_signature': files.where((f) => 
          f.platforms.contains('android') && f.apkSignatureHash != null
        ).length,
      },
    };
  }
  
  static List<FileMetadata> findDuplicateFiles(List<FileMetadata> files) {
    final hashGroups = <String, List<FileMetadata>>{};
    
    for (final file in files) {
      if (file.hash.isNotEmpty) {
        hashGroups.putIfAbsent(file.hash, () => []).add(file);
      }
    }
    
    // Return files that have duplicates
    return hashGroups.values
      .where((group) => group.length > 1)
      .expand((group) => group)
      .toList();
  }
}
```

## Best Practices

### Security Guidelines
- Always include SHA-256 hashes for integrity verification
- Use HTTPS URLs for file downloads
- Include APK signature hashes for Android apps
- Verify minimum SDK requirements are reasonable
- Provide multiple download mirrors for redundancy

### File Organization
```dart
// Use consistent naming conventions
final partialFileMetadata = PartialFileMetadata(
  urls: {
    'https://cdn.example.com/myapp-${version}-${platform}.${extension}',
  },
  appIdentifier: 'com.company.app', // Reverse domain notation
  version: '1.2.3', // Semantic versioning
);
```

### Platform Considerations
- Use standard platform identifiers: `android`, `ios`, `windows`, `macos`, `linux`, `web`
- Include appropriate MIME types for each platform
- Specify realistic SDK version requirements
- Add executable information for desktop platforms

## Related Models

- **[Release](release.md)** - Software releases that contain these files
- **[App](app.md)** - Applications these files belong to
- **[Profile](profile.md)** - Developer profiles who publish files
- **[Reaction](reaction.md)** - User reactions to files
- **[Zap](zap.md)** - Lightning payments for files

## Implementation Notes

- FileMetadata uses regular events (kind 1063) following NIP-94
- SHA-256 hash in the `x` tag is required for security
- URLs in `url` tags should use HTTPS when possible
- Platform tags (`f`) use lowercase platform names
- MIME types help clients handle files appropriately
- Size information helps users plan downloads
- Android-specific fields support APK verification
- Consider implementing automatic hash verification on download
- Multiple URLs provide redundancy and faster downloads 