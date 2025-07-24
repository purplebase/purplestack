# Highlight Model

**Kind:** 9802 (Regular Event)  
**NIP:** Not standardized  
**Class:** `Highlight extends RegularModel<Highlight>`

## Overview

The Highlight model represents text highlights on content in the Nostr protocol. Users can highlight specific portions of articles, notes, or external web content, optionally adding commentary. Highlights are useful for creating annotations, bookmarks, and sharing interesting excerpts with others.

## Properties

### Core Properties
- **`content: String`** - The highlighted text or commentary about the highlight
- **`context: String?`** - Additional context around the highlight
- **`referencedUrl: String?`** - External URL being highlighted (for web content)

### Content References
- **`referencedEventId: String?`** - ID of the Nostr event being highlighted
- **`referencedAddress: String?`** - Address of replaceable event being highlighted
- **`originalAuthorPubkey: String?`** - Public key of the original content author

### Content Type Detection
- **`isNostrHighlight: bool`** - Whether this highlight references Nostr content
- **`isUrlHighlight: bool`** - Whether this highlight references external content

## Relationships

### Direct Relationships
- **`referencedNote: BelongsTo<Note>`** - The note being highlighted (if applicable)
- **`referencedArticle: BelongsTo<Article>`** - The article being highlighted (if applicable)

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The profile that created this highlight
- **`reactions: HasMany<Reaction>`** - Reactions to this highlight
- **`zaps: HasMany<Zap>`** - Zaps sent to this highlight
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this highlight
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this highlight

## Usage Examples

### Highlighting Nostr Articles

```dart
// Highlight text from a long-form article
final partialHighlight = PartialHighlight(
  content: 'The key insight about network effects in decentralized systems',
  context: 'This perfectly explains why adoption matters more than features',
  referencedArticle: article,
  originalAuthor: article.author.value,
);

final signedHighlight = await partialHighlight.signWith(signer);
await signedHighlight.publish();
```

### Highlighting Notes

```dart
// Highlight a specific note
final partialHighlight = PartialHighlight(
  content: 'Bitcoin fixes this',
  context: 'Great point about monetary policy',
  referencedNote: note,
  originalAuthor: note.author.value,
);

final signedHighlight = await partialHighlight.signWith(signer);
await signedHighlight.save();
```

### Highlighting External Content

```dart
// Highlight web content
final partialHighlight = PartialHighlight(
  content: 'Lightning Network adoption is accelerating faster than expected',
  context: 'From the latest Bitcoin development report',
  referencedUrl: 'https://blog.lightning.engineering/posts/2024-report/',
);

final signedHighlight = await partialHighlight.signWith(signer);
await signedHighlight.publish();
```

### Querying Highlights

```dart
// Get highlights on a specific article
final articleHighlightsState = ref.watch(
  query<Highlight>(
    tags: {
      '#a': {articleId},
    },
    and: (highlight) => {
      highlight.author,
      highlight.referencedArticle,
    },
  ),
);

// Get all highlights by a user
final userHighlightsState = ref.watch(
  query<Highlight>(
    authors: {userPubkey},
    limit: 50,
    and: (highlight) => {
      highlight.referencedNote,
      highlight.referencedArticle,
    },
  ),
);

// Get recent highlights with commentary
final commentedHighlightsState = ref.watch(
  query<Highlight>(
    since: DateTime.now().subtract(Duration(days: 7)),
    where: (highlight) => highlight.context != null,
    limit: 20,
  ),
);
```

### Working with Highlights

```dart
// Display highlight in a list
Widget buildHighlightCard(Highlight highlight) {
  final author = highlight.author.value;
  final isExternal = highlight.isUrlHighlight;
  
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          Row(
            children: [
              CircleAvatar(
                backgroundImage: author?.pictureUrl != null
                  ? NetworkImage(author!.pictureUrl!)
                  : null,
                child: author?.pictureUrl == null
                  ? Text(author?.nameOrNpub[0] ?? '?')
                  : null,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author?.nameOrNpub ?? 'Unknown',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'highlighted ${isExternal ? 'web content' : 'Nostr content'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(formatTimestamp(highlight.createdAt)),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Highlighted content
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: Colors.yellow[600]!, width: 4),
              ),
            ),
            child: Text(
              highlight.content,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16,
              ),
            ),
          ),
          
          // Context/commentary
          if (highlight.context != null) ...[
            SizedBox(height: 8),
            Text(
              highlight.context!,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
          
          // Source info
          SizedBox(height: 8),
          if (isExternal) ...[
            Row(
              children: [
                Icon(Icons.link, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    highlight.referencedUrl!,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ] else if (highlight.referencedNote.value != null) ...[
            Text(
              'From note by ${highlight.referencedNote.value!.author.value?.nameOrNpub ?? 'Unknown'}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ] else if (highlight.referencedArticle.value != null) ...[
            Text(
              'From article: ${highlight.referencedArticle.value!.title ?? 'Untitled'}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          
          // Actions
          SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.favorite_border, size: 16),
                onPressed: () => _reactToHighlight(highlight),
              ),
              Text('${highlight.reactions.length}'),
              SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.flash_on, size: 16),
                onPressed: () => _zapHighlight(highlight),
              ),
              Text('${highlight.zaps.length}'),
            ],
          ),
        ],
      ),
    ),
  );
}
```

### Highlight Analytics

```dart
class HighlightAnalytics {
  static Map<String, dynamic> analyzeContentHighlights(Model content) {
    final highlights = getHighlightsForContent(content);
    
    // Most highlighted sections
    final contentFrequency = <String, int>{};
    for (final highlight in highlights) {
      final text = highlight.content.toLowerCase();
      contentFrequency[text] = (contentFrequency[text] ?? 0) + 1;
    }
    
    final popularHighlights = contentFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Highlighter analysis
    final highlighterCounts = <String, int>{};
    for (final highlight in highlights) {
      final pubkey = highlight.author.value?.pubkey ?? 'unknown';
      highlighterCounts[pubkey] = (highlighterCounts[pubkey] ?? 0) + 1;
    }
    
    return {
      'total_highlights': highlights.length,
      'unique_highlighters': highlighterCounts.length,
      'highlights_with_context': highlights.where((h) => h.context != null).length,
      'popular_excerpts': popularHighlights.take(5).map((e) => {
        'text': e.key,
        'highlight_count': e.value,
      }).toList(),
      'top_highlighters': highlighterCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        .take(5)
        .map((e) => {
          'pubkey': e.key,
          'highlight_count': e.value,
        }).toList(),
    };
  }
  
  static List<Highlight> getHighlightsForContent(Model content) {
    if (content is Article) {
      return content.highlights.toList();
    } else if (content is Note) {
      // Would need to query highlights referencing this note
      return [];
    }
    return [];
  }
}
```

### Highlight Discovery

```dart
// Find trending highlights
final trendingHighlightsState = ref.watch(
  query<Highlight>(
    since: DateTime.now().subtract(Duration(days: 3)),
    limit: 50,
    and: (highlight) => {
      highlight.author,
      highlight.reactions,
      highlight.referencedArticle,
    },
    where: (highlight) {
      // Filter for highlights with engagement
      return highlight.reactions.length > 1;
    },
  ),
);

// Find highlights by followed users
final followingHighlightsState = ref.watch(
  query<Highlight>(
    authors: followingPubkeys,
    limit: 30,
    and: (highlight) => {
      highlight.author,
      highlight.referencedNote,
      highlight.referencedArticle,
    },
  ),
);
```

### Highlight Collections

```dart
// Create a curated collection of highlights
class HighlightCollection {
  final String title;
  final String description;
  final List<Highlight> highlights;
  
  HighlightCollection({
    required this.title,
    required this.description,
    required this.highlights,
  });
  
  // Export highlights as text
  String exportAsText() {
    final buffer = StringBuffer();
    buffer.writeln('# $title');
    buffer.writeln();
    buffer.writeln(description);
    buffer.writeln();
    
    for (final highlight in highlights) {
      buffer.writeln('## ${highlight.author.value?.nameOrNpub ?? 'Unknown'}');
      buffer.writeln();
      buffer.writeln('> ${highlight.content}');
      
      if (highlight.context != null) {
        buffer.writeln();
        buffer.writeln(highlight.context!);
      }
      
      if (highlight.referencedUrl != null) {
        buffer.writeln();
        buffer.writeln('Source: ${highlight.referencedUrl}');
      }
      
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }
    
    return buffer.toString();
  }
}
```

## Best Practices

### Content Guidelines
- Highlight meaningful, substantial excerpts
- Add valuable context or commentary
- Respect copyright and fair use principles
- Attribute original authors properly

### Technical Considerations
```dart
// Always include proper references
final partialHighlight = PartialHighlight(
  content: highlightedText,
  // For Nostr content
  referencedNote: note,  // Creates 'e' tag
  // OR for articles
  referencedArticle: article,  // Creates 'a' tag
  // OR for external content
  referencedUrl: url,  // Creates 'r' tag
  
  // Always include original author when known
  originalAuthor: originalAuthor,  // Creates 'p' tag with 'author' marker
);
```

### User Experience
- Show clear source attribution
- Provide context for highlights
- Enable easy navigation to original content
- Support different highlight visualizations

## Related Models

- **[Article](article.md)** - Long-form content that can be highlighted
- **[Note](note.md)** - Notes that can be highlighted
- **[Profile](profile.md)** - Highlight authors and original content creators
- **[Reaction](reaction.md)** - Reactions to highlights
- **[Zap](zap.md)** - Lightning payments to highlights

## Implementation Notes

- Highlights use regular events (kind 9802) - not yet standardized in NIPs
- Support both Nostr content (`e`/`a` tags) and external URLs (`r` tag)
- The `p` tag with 'author' marker references the original content creator
- Context can be added via the `context` tag for additional commentary
- Highlights can be treated as bookmarks or annotations
- Consider implementing highlight aggregation for popular content
- Respect content creators' preferences regarding highlighting 