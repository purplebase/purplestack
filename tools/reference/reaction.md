# Reaction Model

**Kind:** 7 (Regular Event)  
**NIP:** NIP-25  
**Class:** `Reaction extends RegularModel<Reaction> with EmojiMixin`

## Overview

The Reaction model represents emoji reactions to Nostr events. Users can react to notes, articles, and other content using standard emojis or custom emoji reactions. The most common reaction is the "+" (like/upvote), but any emoji can be used.

## Properties

### Core Properties
- **`content: String`** - The emoji reaction (e.g., "+", "❤️", ":custom_emoji:")

### Emoji Support
- **`emojiTag: (String name, String url)?`** - Custom emoji information from `emoji` tags

## Relationships

### Direct Relationships
- **`reactedOn: BelongsTo<Model>`** - The model (note, article, etc.) being reacted to
- **`reactedOnAuthor: BelongsTo<Profile>`** - The author of the content being reacted to

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The profile that created this reaction
- **`reactions: HasMany<Reaction>`** - Reactions to this reaction (rare)
- **`zaps: HasMany<Zap>`** - Zaps sent to this reaction
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this reaction
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this reaction

## Usage Examples

### Creating Basic Reactions

```dart
// Simple like/upvote
final likeReaction = PartialReaction(
  content: '+',
  reactedOn: targetNote,
  reactedOnAuthor: targetNote.author.value,
);

// Emoji reaction
final heartReaction = PartialReaction(
  content: '❤️',
  reactedOn: targetNote,
  reactedOnAuthor: targetNote.author.value,
);

final signedReaction = await likeReaction.signWith(signer);
await signedReaction.publish();
```

### Custom Emoji Reactions

```dart
// Custom emoji with URL
final customEmojiReaction = PartialReaction(
  emojiTag: ('party', 'https://example.com/party.png'),
  reactedOn: targetNote,
  reactedOnAuthor: targetNote.author.value,
);

final signedCustomReaction = await customEmojiReaction.signWith(signer);
await signedCustomReaction.save();
```

### Querying Reactions

```dart
// Get all reactions to a specific note
final reactionsState = ref.watch(
  query<Reaction>(
    tags: {
      '#e': {noteId},
    },
    and: (reaction) => {
      reaction.author,
      reaction.reactedOnAuthor,
    },
  ),
);

// Get reactions by a specific user
final userReactionsState = ref.watch(
  query<Reaction>(
    authors: {userPubkey},
    limit: 50,
    and: (reaction) => {
      reaction.reactedOn,
      reaction.author,
    },
  ),
);
```

### Working with Reactions

```dart
// Check reaction type
if (reaction.emojiTag != null) {
  final (name, url) = reaction.emojiTag!;
  print('Custom emoji: $name from $url');
} else {
  print('Standard reaction: ${reaction.content}');
}

// Count reactions by type
final reactions = note.reactions.toList();
final reactionCounts = <String, int>{};

for (final reaction in reactions) {
  final emoji = reaction.content;
  reactionCounts[emoji] = (reactionCounts[emoji] ?? 0) + 1;
}

print('Likes: ${reactionCounts['+'] ?? 0}');
print('Hearts: ${reactionCounts['❤️'] ?? 0}');
```

### Removing Reactions

```dart
// Find existing reaction by the same author to the same content
final existingReactions = await ref.storage.query(
  RequestFilter<Reaction>(
    authors: {signer.pubkey},
    tags: {
      '#e': {targetNote.id},
    },
  ).toRequest(),
);

// Delete existing reaction (NIP-09)
if (existingReactions.isNotEmpty) {
  final deletionEvent = PartialDeletion(
    eventIds: {existingReactions.first.id},
    reason: 'Removing reaction',
  );
  
  final signedDeletion = await deletionEvent.signWith(signer);
  await signedDeletion.publish();
}
```

## Reaction Guidelines

### Standard Reactions
- **"+"** - Like/upvote (most common)
- **"-"** - Dislike/downvote
- Standard Unicode emojis (❤️, 👍, 😂, etc.)

### Custom Emojis
- Use the `emoji` tag format: `['emoji', <name>, <url>]`
- Content should be `:name:` format
- URLs should point to valid image files

### Best Practices
- Only create one reaction per user per event
- Remove old reactions before adding new ones to the same content
- Use standard emojis when possible for better client compatibility

## Related Models

- **[Note](note.md)** - Notes that can be reacted to
- **[Profile](profile.md)** - Authors of reactions and reacted content
- **[Article](article.md)** - Articles that can be reacted to
- **[Zap](zap.md)** - Monetary reactions via Lightning

## Implementation Notes

- Reactions use `e` tags to reference the reacted event
- The `p` tag references the author of the reacted content
- Custom emojis are defined via `emoji` tags with name and URL
- Clients typically aggregate reactions by emoji type
- The EmojiMixin provides helper methods for custom emoji handling
- Reactions to replaceable events should use `a` tags instead of `e` tags 