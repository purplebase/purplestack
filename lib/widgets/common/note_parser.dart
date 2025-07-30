import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:models/models.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:purplestack/widgets/common/time_utils.dart';
import 'package:purplestack/widgets/common/profile_avatar.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

/// Enum for different media types
enum MediaType { image, video, audio, none }

/// Helper function to launch URLs with robust error handling
Future<void> _launchUrlSafely(String url, {String? context}) async {
  try {
    // Clean and validate the URL
    String cleanUrl = url.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    final uri = Uri.parse(cleanUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Try alternative launch mode
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e2) {
        // Silently fail - both launch modes failed
      }
    }
  } catch (e) {
    // Silently handle URL launch errors
  }
}

/// A utility for parsing Nostr note content and replacing entities with custom widgets.
class NoteParser {
  // Regex patterns for different content types
  static final RegExp nip19Regex = RegExp(
    r'(?:nostr:)?(npub|nsec|note|nprofile|nevent|naddr|nrelay)1[02-9ac-hj-np-z]+',
    caseSensitive: false,
  );

  static final RegExp httpUrlPattern = RegExp(
    r'https?://[^\s<>"\[\]{}|\\^`]+',
    caseSensitive: false,
  );

  // Hashtag pattern - matches #word (letters, numbers, underscores)
  static final RegExp _hashtagPattern = RegExp(
    r'#[a-zA-Z0-9_]+',
    caseSensitive: false,
  );

  // Image file extensions
  static final Set<String> _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
    'svg',
  };

  // Video file extensions
  static final Set<String> _videoExtensions = {
    'mp4',
    'webm',
    'avi',
    'mov',
    'mkv',
  };

  // Audio file extensions (for future use)
  static final Set<String> _audioExtensions = {'mp3', 'wav', 'ogg'};

  /// Parses note content and returns a RichText widget with custom entity replacements.
  ///
  /// [context] - The build context for accessing theme
  /// [content] - The note text content to parse
  /// [onNostrEntity] - Optional callback for replacing NIP-19 entities (npub, note, etc.)
  /// [onHttpUrl] - Optional callback for replacing HTTP URLs
  /// [onMediaUrl] - Optional callback specifically for media URLs (images, videos, etc.)
  /// [onHashtag] - Optional callback for replacing hashtags (#hashtag)
  /// [onHashtagTap] - Optional callback for when a hashtag is tapped
  /// [onProfileTap] - Optional callback for when a profile is tapped
  /// [textStyle] - Default text style for regular text
  /// [linkStyle] - Text style for unhandled links (when callback returns null)
  static Widget parse(
    BuildContext context,
    String content, {
    Widget? Function(String entity)? onNostrEntity,
    Widget? Function(String httpUrl)? onHttpUrl,
    Widget? Function(String mediaUrl)? onMediaUrl,
    Widget? Function(String hashtag)? onHashtag,
    void Function(String hashtag)? onHashtagTap,
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
    for (final match in nip19Regex.allMatches(content)) {
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
    for (final match in httpUrlPattern.allMatches(content)) {
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

    // Find all hashtags
    for (final match in _hashtagPattern.allMatches(content)) {
      final hashtag = match.group(0)!;

      matches.add(
        _EntityMatch(
          start: match.start,
          end: match.end,
          text: hashtag,
          type: _EntityType.hashtag,
          cleanEntity: hashtag.substring(1), // Remove the # symbol
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
        case _EntityType.hashtag:
          replacement =
              onHashtag?.call(match.cleanEntity) ??
              HashtagWidget(
                hashtag: match.cleanEntity,
                colorPair: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                onTap: onHashtagTap != null
                    ? () => onHashtagTap(match.cleanEntity)
                    : null,
              );
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

  /// Checks if a URL is likely a media URL and returns the media type
  static MediaType _getMediaType(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();
      final extension = path.split('.').last;

      if (_imageExtensions.contains(extension)) {
        return MediaType.image;
      } else if (_videoExtensions.contains(extension)) {
        return MediaType.video;
      } else if (_audioExtensions.contains(extension)) {
        return MediaType.audio;
      } else {
        return MediaType.none;
      }
    } catch (e) {
      return MediaType.none;
    }
  }

  /// Checks if a URL is likely a media URL based on file extension
  static bool _isMediaUrl(String url) {
    return _getMediaType(url) != MediaType.none;
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
    return nip19Regex
        .allMatches(content)
        .map((match) => match.group(0)!.replaceFirst('nostr:', ''))
        .where((entity) => isValidNip19Entity(entity))
        .toList();
  }

  /// Extracts all HTTP URLs from text
  @protected
  @visibleForTesting
  static List<String> extractHttpUrls(String content) {
    return httpUrlPattern
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

  /// Extracts all hashtags from text (without the # symbol)
  @protected
  @visibleForTesting
  static List<String> extractHashtags(String content) {
    return _hashtagPattern
        .allMatches(content)
        .map((match) => match.group(0)!.substring(1)) // Remove # symbol
        .toList();
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
enum _EntityType { nip19, http, media, hashtag }

// Widgets

class NostrEntityWidget extends StatelessWidget {
  final String entity;
  final List<Color> colorPair;
  final void Function(String pubkey)? onProfileTap;
  final void Function(String hashtag)? onHashtagTap;

  const NostrEntityWidget({
    super.key,
    required this.entity,
    required this.colorPair,
    this.onProfileTap,
    this.onHashtagTap,
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
          onHashtagTap: onHashtagTap,
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

    // Show animated npub while profile is being loaded
    if (profileState is StorageLoading ||
        (profile == null && profileState is StorageData)) {
      return GestureDetector(
        onTap: onProfileTap != null
            ? () => onProfileTap!(profileData.pubkey)
            : null,
        child: _AnimatedLoadingChip(
          text: 'npub1${profileData.pubkey.substring(0, 8)}...',
          colorPair: colorPair,
        ),
      );
    }

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
  final void Function(String hashtag)? onHashtagTap;

  const EventEntityWidget({
    super.key,
    required this.eventData,
    required this.colorPair,
    this.onProfileTap,
    this.onHashtagTap,
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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: colorPair[0].withValues(alpha: 0.2),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: colorPair[0].withValues(alpha: 0.05),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skeleton for author info
              Row(
                children: [
                  Skeletonizer(
                    enabled: true,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Skeletonizer(
                      enabled: true,
                      child: Container(
                        width: 100,
                        height: 13,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Skeletonizer(
                    enabled: true,
                    child: Container(
                      width: 40,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Skeleton for note content
              Skeletonizer(
                enabled: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: colorPair[0].withValues(alpha: 0.2),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: colorPair[0].withValues(alpha: 0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onProfileTap != null
                  ? () => onProfileTap!(note.pubkey)
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
                    child: note.author.value?.nameOrNpub != null
                        ? Text(
                            note.author.value!.nameOrNpub,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                          )
                        : _AnimatedLoadingChip(
                            text: 'npub1${note.pubkey.substring(0, 8)}...',
                            colorPair: colorPair,
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
            ParsedContentWidget(
              note: note,
              colorPair: colorPair,
              onProfileTap: onProfileTap,
              onHashtagTap: onHashtagTap,
            ),
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
      onTap: () {
        // Handle address navigation
      },
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

class ParsedContentWidget extends ConsumerWidget {
  final Note note;
  final List<Color> colorPair;
  final void Function(String pubkey)? onProfileTap;
  final void Function(String hashtag)? onHashtagTap;

  const ParsedContentWidget({
    super.key,
    required this.note,
    required this.colorPair,
    this.onProfileTap,
    this.onHashtagTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reply context - show if this note is a reply
        if (note.replyTo.value != null) ...[
          ReplyContextWidget(
            replyingNote: note,
            colorPair: colorPair,
            onProfileTap: onProfileTap,
            onHashtagTap: onHashtagTap,
          ),
          const SizedBox(height: 8),
        ],

        // Original note content
        _buildNoteContent(context),
      ],
    );
  }

  Widget _buildNoteContent(BuildContext context) {
    if (note.content.trim().isEmpty) {
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
      note.content,
      textStyle: Theme.of(context).textTheme.bodyMedium,
      linkStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: colorPair[0],
        decoration: TextDecoration.underline,
      ),
      onNostrEntity: (entity) => NostrEntityWidget(
        entity: entity,
        colorPair: colorPair,
        onProfileTap: onProfileTap,
        onHashtagTap: onHashtagTap,
      ),
      onHttpUrl: (url) => UrlChipWidget(url: url, colorPair: colorPair),
      onMediaUrl: (url) => MediaWidget(url: url, colorPair: colorPair),
      onHashtagTap: onHashtagTap,
      onProfileTap: onProfileTap,
    );
  }
}

/// Internal widget for reply context - now part of the note parser
class ReplyContextWidget extends ConsumerWidget {
  final Note replyingNote;
  final List<Color> colorPair;
  final void Function(String pubkey)? onProfileTap;
  final void Function(String hashtag)? onHashtagTap;

  const ReplyContextWidget({
    super.key,
    required this.replyingNote,
    required this.colorPair,
    this.onProfileTap,
    this.onHashtagTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final replyToNote = replyingNote.replyTo.value;

    if (replyToNote == null) {
      return const SizedBox.shrink();
    }

    // Load the author for the replyTo note
    final authorState = ref.watch(
      query<Profile>(authors: {replyToNote.pubkey}, limit: 1),
    );

    final author = authorState.models.firstOrNull;
    final isAuthorLoading =
        authorState is StorageLoading ||
        (author == null && authorState is StorageData);

    // Check if the reply-to note itself is still being loaded
    final replyToNoteState = ref.watch(
      query<Note>(ids: {replyToNote.id}, limit: 1),
    );

    final isNoteLoading = replyToNoteState is StorageLoading;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: colorPair[0].withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Replying to" indicator
          Row(
            children: [
              Icon(
                Icons.reply,
                size: 14,
                color: colorPair[0].withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Replying to',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorPair[0].withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Parent note preview
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parent note author
                GestureDetector(
                  onTap: onProfileTap != null
                      ? () => onProfileTap!(replyToNote.pubkey)
                      : null,
                  child: Row(
                    children: [
                      ProfileAvatar(
                        profile: author,
                        radius: 10,
                        borderColors: colorPair,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: isAuthorLoading || isNoteLoading
                            ? _AnimatedLoadingChip(
                                text:
                                    'npub1${replyToNote.pubkey.substring(0, 8)}...',
                                colorPair: colorPair,
                              )
                            : Text(
                                author?.nameOrNpub ??
                                    '${replyToNote.pubkey.substring(0, 8)}...',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                              ),
                      ),
                      TimeAgoText(
                        replyToNote.createdAt,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Parent note content with proper loading state handling
                isNoteLoading || isAuthorLoading
                    ? Skeletonizer(
                        enabled: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : replyToNote.content.trim().isEmpty
                    ? Text(
                        'No content',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      )
                    : _buildFullContent(context, replyToNote.content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullContent(BuildContext context, String content) {
    return NoteParser.parse(
      context,
      content,
      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
      linkStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: colorPair[0],
        decoration: TextDecoration.underline,
        fontSize: 12,
      ),
      onNostrEntity: (entity) => NostrEntityWidget(
        entity: entity,
        colorPair: colorPair,
        onProfileTap: onProfileTap,
        onHashtagTap: onHashtagTap,
      ),
      onHttpUrl: (url) => UrlChipWidget(url: url, colorPair: colorPair),
      onMediaUrl: (url) => MediaWidget(url: url, colorPair: colorPair),
      onHashtagTap: onHashtagTap,
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
      child: Material(
        color: Colors.transparent,
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
          bodyStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Colors.grey[600],
            fontSize: 12,
          ),
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
    final mediaType = NoteParser._getMediaType(url);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: colorPair[0].withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: switch (mediaType) {
          MediaType.image => _buildImageWidget(context),
          MediaType.video => _buildVideoWidget(context),
          MediaType.audio => _buildAudioWidget(context),
          MediaType.none => _buildUnsupportedWidget(context),
        },
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 200,
        color: colorPair[0].withValues(alpha: 0.1),
        child: Center(child: CircularProgressIndicator(color: colorPair[0])),
      ),
      errorWidget: (context, url, error) => Container(
        height: 60,
        color: colorPair[0].withValues(alpha: 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: colorPair[0]),
            const SizedBox(width: 8.0),
            Text(
              'Image failed to load',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: colorPair[0]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoWidget(BuildContext context) {
    return VideoPlayerWidget(url: url, colorPair: colorPair);
  }

  Widget _buildAudioWidget(BuildContext context) {
    return AudioPlayerWidget(url: url, colorPair: colorPair);
  }

  Widget _buildUnsupportedWidget(BuildContext context) {
    return Container(
      height: 60,
      color: colorPair[0].withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.help_outline, color: colorPair[0]),
          const SizedBox(width: 8.0),
          Text(
            'Unsupported media type',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: colorPair[0]),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final List<Color> colorPair;

  const VideoPlayerWidget({
    super.key,
    required this.url,
    required this.colorPair,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );
      await _videoPlayerController!.initialize();

      if (mounted) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: false,
          looping: false,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: widget.colorPair[0],
            handleColor: widget.colorPair[0],
            backgroundColor: Colors.grey,
            bufferedColor: widget.colorPair[0].withValues(alpha: 0.3),
          ),
          placeholder: Container(
            color: widget.colorPair[0].withValues(alpha: 0.1),
            child: Center(
              child: CircularProgressIndicator(color: widget.colorPair[0]),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Container(
              color: widget.colorPair[0].withValues(alpha: 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: widget.colorPair[0]),
                  const SizedBox(height: 8.0),
                  Text(
                    'Video failed to load',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: widget.colorPair[0]),
                  ),
                ],
              ),
            );
          },
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 200,
        color: widget.colorPair[0].withValues(alpha: 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: widget.colorPair[0]),
            const SizedBox(height: 8.0),
            Text(
              'Video failed to load',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: widget.colorPair[0]),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: widget.colorPair[0].withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    }

    if (_chewieController == null) {
      return Container(
        height: 200,
        color: widget.colorPair[0].withValues(alpha: 0.1),
        child: Center(
          child: CircularProgressIndicator(color: widget.colorPair[0]),
        ),
      );
    }

    return SizedBox(height: 200, child: Chewie(controller: _chewieController!));
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final List<Color> colorPair;

  const AudioPlayerWidget({
    super.key,
    required this.url,
    required this.colorPair,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      await _player.setUrl(widget.url);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 80,
        color: widget.colorPair[0].withValues(alpha: 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: widget.colorPair[0]),
            const SizedBox(height: 4.0),
            Text(
              'Audio failed to load',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: widget.colorPair[0]),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  _errorMessage,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: widget.colorPair[0].withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 80,
        color: widget.colorPair[0].withValues(alpha: 0.1),
        child: Center(
          child: CircularProgressIndicator(color: widget.colorPair[0]),
        ),
      );
    }

    return Container(
      height: 80,
      color: widget.colorPair[0].withValues(alpha: 0.05),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // Play/Pause Button
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final isPlaying = playerState?.playing ?? false;

              return GestureDetector(
                onTap: () async {
                  if (isPlaying) {
                    await _player.pause();
                  } else {
                    await _player.play();
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.colorPair[0],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // Progress and Duration
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Bar
                StreamBuilder<Duration?>(
                  stream: _player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = _player.duration ?? Duration.zero;
                    final progress = duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;

                    return SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4.0,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 6.0,
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: 14.0,
                        ),
                        activeTrackColor: widget.colorPair[0],
                        inactiveTrackColor: widget.colorPair[0].withValues(
                          alpha: 0.3,
                        ),
                        thumbColor: widget.colorPair[0],
                        overlayColor: widget.colorPair[0].withValues(
                          alpha: 0.2,
                        ),
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (value) async {
                          final duration = _player.duration;
                          if (duration != null) {
                            final position = Duration(
                              milliseconds: (value * duration.inMilliseconds)
                                  .round(),
                            );
                            await _player.seek(position);
                          }
                        },
                      ),
                    );
                  },
                ),

                // Time Display
                StreamBuilder<Duration?>(
                  stream: _player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = _player.duration ?? Duration.zero;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: widget.colorPair[0],
                                fontSize: 11,
                              ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: widget.colorPair[0].withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 11,
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Audio Icon
          Icon(
            Icons.audiotrack,
            color: widget.colorPair[0].withValues(alpha: 0.7),
            size: 20,
          ),
        ],
      ),
    );
  }
}

class HashtagWidget extends StatelessWidget {
  final String hashtag;
  final List<Color> colorPair;
  final VoidCallback? onTap;

  const HashtagWidget({
    super.key,
    required this.hashtag,
    required this.colorPair,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorPair[0].withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
        child: Text(
          '#$hashtag',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: colorPair[0],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Animated loading chip for profile loading states
class _AnimatedLoadingChip extends StatefulWidget {
  final String text;
  final List<Color> colorPair;

  const _AnimatedLoadingChip({required this.text, required this.colorPair});

  @override
  State<_AnimatedLoadingChip> createState() => _AnimatedLoadingChipState();
}

class _AnimatedLoadingChipState extends State<_AnimatedLoadingChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.1,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: widget.colorPair[0].withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              widget.text,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w500,
                color: widget.colorPair[0],
              ),
            ),
          ),
        );
      },
    );
  }
}
