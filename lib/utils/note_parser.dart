import 'package:flutter/material.dart';
import 'package:models/models.dart';

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
  /// [onNip19Entity] - Optional callback for replacing NIP-19 entities (npub, note, etc.)
  /// [onHttpUrl] - Optional callback for replacing HTTP URLs
  /// [onMediaUrl] - Optional callback specifically for media URLs (images, videos, etc.)
  /// [textStyle] - Default text style for regular text
  /// [linkStyle] - Text style for unhandled links (when callback returns null)
  static Widget parse(
    String content, {
    Widget? Function(String nip19Entity)? onNip19Entity,
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
          replacement = onNip19Entity?.call(match.cleanEntity);
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
