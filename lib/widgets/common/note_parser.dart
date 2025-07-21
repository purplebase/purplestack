import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:models/models.dart';
import 'package:purplestack/widgets/common/time_utils.dart';
import 'package:purplestack/widgets/common/profile_avatar.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper function to launch URLs with robust error handling
Future<void> _launchUrlSafely(String url, {String? context}) async {
  try {
    final prefix = context != null ? '$context: ' : '';
    debugPrint('${prefix}Attempting to launch URL: $url');

    // Clean and validate the URL
    String cleanUrl = url.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
      debugPrint('${prefix}Added https:// prefix. New URL: $cleanUrl');
    }

    final uri = Uri.parse(cleanUrl);
    debugPrint('${prefix}Parsed URI: $uri');

    if (await canLaunchUrl(uri)) {
      debugPrint('${prefix}canLaunchUrl returned true, launching...');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      debugPrint('${prefix}Launch successful');
    } else {
      debugPrint('${prefix}canLaunchUrl returned false for: $cleanUrl');
      // Try alternative launch mode
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
        debugPrint('${prefix}Launch successful with platformDefault mode');
      } catch (e2) {
        debugPrint('${prefix}Both launch modes failed: $e2');
      }
    }
  } catch (e) {
    final prefix = context != null ? '$context: ' : '';
    debugPrint('${prefix}Error launching URL: $e');
    debugPrint('${prefix}Original URL: $url');
  }
}

/// A utility for parsing Nostr note content and replacing entities with custom widgets.
class NoteParser {
  // Regex patterns for different content types
  static final RegExp _nip19Regex = RegExp(
    r'(?:nostr:)?(npub|nsec|note|nprofile|nevent|naddr|nrelay)1[02-9ac-hj-np-z]+',
    caseSensitive: false,
  );

  static final RegExp _httpUrlPattern = RegExp(
    r'https?://[^\s<>"\[\]{}|\\^`]+',
    caseSensitive: false,
  );

  // Common media file extensions
  static final Set<String> _mediaExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
    'svg',
    'mp4',
    'webm',
    'avi',
    'mov',
    'mkv',
    'mp3',
    'wav',
    'ogg',
  };

  /// Parses note content and returns a RichText widget with custom entity replacements.
  ///
  /// [context] - The build context for accessing theme
  /// [content] - The note text content to parse
  /// [onNostrEntity] - Optional callback for replacing NIP-19 entities (npub, note, etc.)
  /// [onHttpUrl] - Optional callback for replacing HTTP URLs
  /// [onMediaUrl] - Optional callback specifically for media URLs (images, videos, etc.)
  /// [onProfileTap] - Optional callback for when a profile is tapped
  /// [textStyle] - Default text style for regular text
  /// [linkStyle] - Text style for unhandled links (when callback returns null)
  static Widget parse(
    BuildContext context,
    String content, {
    Widget? Function(String entity)? onNostrEntity,
    Widget? Function(String httpUrl)? onHttpUrl,
    Widget? Function(String mediaUrl)? onMediaUrl,
    void Function(String pubkey)? onProfileTap,
    TextStyle? textStyle,
    TextStyle? linkStyle,
  }) {
    if (content.isEmpty) {
      return Text('', style: textStyle);
    }

    final List<InlineSpan> spans = [];
    final List<_EntityMatch> matches = [];

    // Find all NIP-19 entities
    for (final match in _nip19Regex.allMatches(content)) {
      final entity = match.group(0)!;
      final nip19Entity = entity.replaceFirst('nostr:', '');

      matches.add(
        _EntityMatch(
          start: match.start,
          end: match.end,
          text: entity,
          type: _EntityType.nip19,
          cleanEntity: nip19Entity,
        ),
      );
    }

    // Find all HTTP URLs
    for (final match in _httpUrlPattern.allMatches(content)) {
      final url = match.group(0)!;
      final isMedia = _isMediaUrl(url);

      matches.add(
        _EntityMatch(
          start: match.start,
          end: match.end,
          text: url,
          type: isMedia ? _EntityType.media : _EntityType.http,
          cleanEntity: url,
        ),
      );
    }

    // Sort matches by position
    matches.sort((a, b) => a.start.compareTo(b.start));

    // Build spans
    int currentPos = 0;

    for (final match in matches) {
      // Add text before this match
      if (match.start > currentPos) {
        final textBefore = content.substring(currentPos, match.start);
        spans.add(TextSpan(text: textBefore, style: textStyle));
      }

      // Handle the entity
      Widget? replacement;

      switch (match.type) {
        case _EntityType.nip19:
          replacement = onNostrEntity?.call(match.cleanEntity);
          break;
        case _EntityType.media:
          replacement =
              onMediaUrl?.call(match.text) ?? onHttpUrl?.call(match.text);
          break;
        case _EntityType.http:
          replacement = onHttpUrl?.call(match.text);
          break;
      }

      if (replacement != null) {
        spans.add(
          WidgetSpan(
            child: replacement,
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
          ),
        );
      } else {
        // Fallback to styled text
        final style =
            linkStyle ??
            textStyle?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            );
        spans.add(TextSpan(text: match.text, style: style));
      }

      currentPos = match.end;
    }

    // Add remaining text
    if (currentPos < content.length) {
      final remainingText = content.substring(currentPos);
      spans.add(TextSpan(text: remainingText, style: textStyle));
    }

    // If no entities found, return simple text
    if (spans.isEmpty) {
      return Text(content, style: textStyle);
    }

    return RichText(text: TextSpan(children: spans));
  }

  /// Checks if a URL is likely a media URL based on file extension
  static bool _isMediaUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();
      final extension = path.split('.').last;
      return _mediaExtensions.contains(extension);
    } catch (e) {
      return false;
    }
  }

  /// Validates if a string is a valid NIP-19 entity
  static bool isValidNip19Entity(String entity) {
    try {
      Utils.decodeShareableIdentifier(entity);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Extracts all NIP-19 entities from text
  @protected
  @visibleForTesting
  static List<String> extractNip19Entities(String content) {
    return _nip19Regex
        .allMatches(content)
        .map((match) => match.group(0)!.replaceFirst('nostr:', ''))
        .where((entity) => isValidNip19Entity(entity))
        .toList();
  }

  /// Extracts all HTTP URLs from text
  @protected
  @visibleForTesting
  static List<String> extractHttpUrls(String content) {
    return _httpUrlPattern
        .allMatches(content)
        .map((match) => match.group(0)!)
        .toList();
  }

  /// Extracts all media URLs from text
  @protected
  @visibleForTesting
  static List<String> extractMediaUrls(String content) {
    return extractHttpUrls(content).where((url) => _isMediaUrl(url)).toList();
  }
}

/// Internal class for tracking entity matches
class _EntityMatch {
  final int start;
  final int end;
  final String text;
  final _EntityType type;
  final String cleanEntity;

  _EntityMatch({
    required this.start,
    required this.end,
    required this.text,
    required this.type,
    required this.cleanEntity,
  });
}

/// Internal enum for entity types
enum _EntityType { nip19, http, media }

// Widgets

class NostrEntityWidget extends StatelessWidget {
  final String entity;
  final List<Color> colorPair;
  final void Function(String pubkey)? onProfileTap;

  const NostrEntityWidget({
    super.key,
    required this.entity,
    required this.colorPair,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final decoded = Utils.decodeShareableIdentifier(entity);

      return switch (decoded) {
        ProfileData() => ProfileEntityWidget(
          profileData: decoded,
          colorPair: colorPair,
          onProfileTap: onProfileTap,
        ),
        EventData() => EventEntityWidget(
          eventData: decoded,
          colorPair: colorPair,
          onProfileTap: onProfileTap,
        ),
        AddressData() => AddressEntityWidget(
          addressData: decoded,
          colorPair: colorPair,
        ),
      };
    } catch (e) {
      return GenericNip19Widget(entity: entity, colorPair: colorPair);
    }
  }
}

class ProfileEntityWidget extends ConsumerWidget {
  final ProfileData profileData;
  final List<Color> colorPair;
  final void Function(String pubkey)? onProfileTap;

  const ProfileEntityWidget({
    super.key,
    required this.profileData,
    required this.colorPair,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(
      query<Profile>(authors: {profileData.pubkey}, limit: 1),
    );

    final profile = profileState.models.firstOrNull;
    final displayName =
        profile?.nameOrNpub ?? '${profileData.pubkey.substring(0, 8)}...';

    return GestureDetector(
      onTap: onProfileTap != null
          ? () => onProfileTap!(profileData.pubkey)
          : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorPair[0].withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            displayName,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w500,
              color: colorPair[0],
            ),
          ),
        ),
      ),
    );
  }
}

class EventEntityWidget extends ConsumerWidget {
  final EventData eventData;
  final List<Color> colorPair;
  final void Function(String pubkey)? onProfileTap;

  const EventEntityWidget({
    super.key,
    required this.eventData,
    required this.colorPair,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteState = ref.watch(
      query<Note>(
        ids: {eventData.eventId},
        limit: 1,
        and: (note) => {note.author},
      ),
    );

    final note = noteState.models.firstOrNull;

    if (note == null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorPair[0],
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                'Loading note (${eventData.eventId.substring(0, 8)}...)',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onProfileTap != null
                  ? () => onProfileTap!(note.event.pubkey)
                  : null,
              child: Row(
                children: [
                  ProfileAvatar(
                    profile: note.author.value,
                    radius: 12,
                    borderColors: colorPair,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      note.author.value?.nameOrNpub ?? 'Anonymous',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TimeAgoText(
                    note.createdAt,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            ParsedContentWidget(content: note.content, colorPair: colorPair),
          ],
        ),
      ),
    );
  }
}

class AddressEntityWidget extends StatelessWidget {
  final AddressData addressData;
  final List<Color> colorPair;

  const AddressEntityWidget({
    super.key,
    required this.addressData,
    required this.colorPair,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => debugPrint('Navigate to address: ${addressData.identifier}'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorPair[0].withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            addressData.identifier,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w500,
              color: colorPair[0],
            ),
          ),
        ),
      ),
    );
  }
}

class GenericNip19Widget extends StatelessWidget {
  final String entity;
  final List<Color> colorPair;

  const GenericNip19Widget({
    super.key,
    required this.entity,
    required this.colorPair,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorPair[0].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Text(
          entity,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w500,
            color: colorPair[0],
          ),
        ),
      ),
    );
  }
}

class ParsedContentWidget extends StatelessWidget {
  final String content;
  final List<Color> colorPair;
  final void Function(String pubkey)? onProfileTap;

  const ParsedContentWidget({
    super.key,
    required this.content,
    required this.colorPair,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return Text(
        'No content',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.grey[500],
        ),
      );
    }

    return NoteParser.parse(
      context,
      content,
      textStyle: Theme.of(context).textTheme.bodyMedium,
      linkStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: colorPair[0],
        decoration: TextDecoration.underline,
      ),
      onNostrEntity: (entity) => NostrEntityWidget(
        entity: entity,
        colorPair: colorPair,
        onProfileTap: onProfileTap,
      ),
      onHttpUrl: (url) => UrlChipWidget(url: url, colorPair: colorPair),
      onMediaUrl: (url) => MediaWidget(url: url, colorPair: colorPair),
      onProfileTap: onProfileTap,
    );
  }
}

class UrlChipWidget extends StatelessWidget {
  final String url;
  final List<Color> colorPair;

  const UrlChipWidget({super.key, required this.url, required this.colorPair});

  @override
  Widget build(BuildContext context) {
    // Fallback widget for when preview fails
    Widget fallbackWidget = GestureDetector(
      onTap: () => _launchUrlSafely(url, context: 'Fallback'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorPair[0].withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            url,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: colorPair[0],
              decoration: TextDecoration.underline,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: AnyLinkPreview(
        link: url,
        displayDirection: UIDirection.uiDirectionHorizontal,
        showMultimedia: true,
        bodyMaxLines: 2,
        bodyTextOverflow: TextOverflow.ellipsis,
        titleStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        bodyStyle: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(color: Colors.grey[600], fontSize: 12),
        cache: Duration.zero,
        backgroundColor: colorPair[0].withValues(alpha: 0.05),
        borderRadius: 8.0,
        removeElevation: true,
        boxShadow: const [],
        onTap: () => _launchUrlSafely(url, context: 'Link Preview'),
        errorWidget: fallbackWidget,
        errorBody: 'Link preview unavailable',
        errorTitle: 'Unable to load preview',
        errorImage: '',
        placeholderWidget: fallbackWidget,
      ),
    );
  }
}

class MediaWidget extends StatelessWidget {
  final String url;
  final List<Color> colorPair;

  const MediaWidget({super.key, required this.url, required this.colorPair});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: colorPair[0].withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: colorPair[0].withValues(alpha: 0.1),
              child: Center(
                child: CircularProgressIndicator(
                  color: colorPair[0],
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 60,
              color: colorPair[0].withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: colorPair[0]),
                  const SizedBox(width: 8.0),
                  Text(
                    'Media failed to load',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: colorPair[0]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
