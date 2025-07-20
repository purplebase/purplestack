import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:models/models.dart';
import 'package:purplestack/utils/app_constants.dart';
import 'package:purplestack/utils/time_utils.dart';
import 'package:purplestack/widgets/common/profile_avatar.dart';

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
  /// [content] - The note text content to parse
  /// [onNostrEntity] - Optional callback for replacing NIP-19 entities (npub, note, etc.)
  /// [onHttpUrl] - Optional callback for replacing HTTP URLs
  /// [onMediaUrl] - Optional callback specifically for media URLs (images, videos, etc.)
  /// [textStyle] - Default text style for regular text
  /// [linkStyle] - Text style for unhandled links (when callback returns null)
  static Widget parse(
    String content, {
    Widget? Function(String entity)? onNostrEntity,
    Widget? Function(String httpUrl)? onHttpUrl,
    Widget? Function(String mediaUrl)? onMediaUrl,
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
        spans.add(WidgetSpan(child: replacement));
      } else {
        // Fallback to styled text
        final style =
            linkStyle ??
            textStyle?.copyWith(
              color: Colors.blue,
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

  const NostrEntityWidget({
    super.key,
    required this.entity,
    required this.colorPair,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final decoded = Utils.decodeShareableIdentifier(entity);

      return switch (decoded) {
        ProfileData() => ProfileEntityWidget(
          profileData: decoded,
          colorPair: colorPair,
        ),
        EventData() => EventEntityWidget(
          eventData: decoded,
          colorPair: colorPair,
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

  const ProfileEntityWidget({
    super.key,
    required this.profileData,
    required this.colorPair,
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
      onTap: () => debugPrint('Navigate to profile: ${profileData.pubkey}'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingS,
          vertical: AppConstants.spacingXS,
        ),
        decoration: BoxDecoration(
          color: colorPair[0].withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileAvatar(profile: profile, radius: 8, borderColors: colorPair),
            const SizedBox(width: AppConstants.spacingXS),
            Text(
              displayName,
              style: AppConstants.bodyStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorPair[0],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventEntityWidget extends ConsumerWidget {
  final EventData eventData;
  final List<Color> colorPair;

  const EventEntityWidget({
    super.key,
    required this.eventData,
    required this.colorPair,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteState = ref.watch(
      query<Note>(ids: {eventData.eventId}, limit: 1),
    );

    final note = noteState.models.firstOrNull;

    if (note == null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.note_alt, size: 16, color: Colors.grey[600]),
            const SizedBox(width: AppConstants.spacingS),
            Expanded(
              child: Text(
                'Referenced note (${eventData.eventId.substring(0, 8)}...)',
                style: AppConstants.captionStyle.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: colorPair[0].withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [AppConstants.getCardShadow(colorPair[0])],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                profile: note.author.value,
                radius: 12,
                borderColors: colorPair,
              ),
              const SizedBox(width: AppConstants.spacingS),
              Expanded(
                child: Text(
                  note.author.value?.nameOrNpub ?? 'Anonymous',
                  style: AppConstants.bodyStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                TimeUtils.formatTimestamp(note.createdAt),
                style: AppConstants.captionStyle.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          ParsedContentWidget(content: note.content, colorPair: colorPair),
        ],
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
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingS,
          vertical: AppConstants.spacingXS,
        ),
        decoration: BoxDecoration(
          color: colorPair[0].withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article, size: 16, color: colorPair[0]),
            const SizedBox(width: AppConstants.spacingXS),
            Text(
              addressData.identifier,
              style: AppConstants.bodyStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorPair[0],
              ),
            ),
          ],
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingS,
        vertical: AppConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: colorPair[0].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Text(
        entity,
        style: AppConstants.bodyStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorPair[0],
        ),
      ),
    );
  }
}

class ParsedContentWidget extends StatelessWidget {
  final String content;
  final List<Color> colorPair;

  const ParsedContentWidget({
    super.key,
    required this.content,
    required this.colorPair,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return Text(
        'No content',
        style: AppConstants.bodyStyle.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.grey[500],
        ),
      );
    }

    return NoteParser.parse(
      content,
      textStyle: AppConstants.bodyStyle.copyWith(fontSize: 15),
      linkStyle: AppConstants.linkStyle.copyWith(
        fontSize: 15,
        color: colorPair[0],
      ),
      onNostrEntity: (entity) =>
          NostrEntityWidget(entity: entity, colorPair: colorPair),
      onHttpUrl: (url) => UrlChipWidget(url: url, colorPair: colorPair),
      onMediaUrl: (url) => MediaWidget(url: url, colorPair: colorPair),
    );
  }
}

class UrlChipWidget extends StatelessWidget {
  final String url;
  final List<Color> colorPair;

  const UrlChipWidget({super.key, required this.url, required this.colorPair});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingXS),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingS,
        vertical: AppConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: colorPair[0].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link, size: 16, color: colorPair[0]),
          const SizedBox(width: AppConstants.spacingXS),
          Flexible(
            child: Text(
              url,
              style: AppConstants.bodyStyle.copyWith(
                fontSize: 14,
                color: colorPair[0],
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
      margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: colorPair[0].withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
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
                  const SizedBox(width: AppConstants.spacingS),
                  Text(
                    'Media failed to load',
                    style: AppConstants.captionStyle.copyWith(
                      color: colorPair[0],
                    ),
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
