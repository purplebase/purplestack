# Note Model

**Kind:** 1 (Regular Event)  
**NIP:** NIP-01, NIP-10  
**Class:** `Note extends RegularModel<Note>`

## Overview

The Note model represents text posts in the Nostr protocol. Notes are the fundamental content type for social interactions, supporting threading, replies, hashtags, and various forms of engagement through reactions and zaps.

## Properties

### Core Properties
- **`content: String`** - The text content of the note
- **`isRoot: bool`** - Whether this note is a root post (not a reply)

### Threading Properties
- **`root: BelongsTo<Note>`** - The root note in a thread (if this is a reply)
- **`replyTo: BelongsTo<Note>`** - The immediate parent note being replied to

## Relationships

### Direct Relationships
- **`replies: HasMany<Note>`** - Direct replies to this note
- **`allReplies: HasMany<Note>`** - All replies in the thread (including nested)
- **`reposts: HasMany<Repost>`** - Reposts of this note

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The profile that authored this note
- **`reactions: HasMany<Reaction>`** - Reactions (likes, etc.) to this note
- **`zaps: HasMany<Zap>`** - Lightning payments to this note
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this note
- **`genericReposts: HasMany<GenericRepost>`** - Generic reposts of this note

## Threading Logic

Notes implement NIP-10 threading with the following tag structure:

- **Root marker**: `['e', <root_id>, <relay_url>, 'root']` - References the root of the thread
- **Reply marker**: `['e', <reply_id>, <relay_url>, 'reply']` - References the immediate parent
- **Single 'e' tag**: When only one `e` tag exists, it references both root and parent

The threading logic handles various scenarios:
- Root posts have no `e` tags
- Direct replies to root have one `e` tag with 'root' marker
- Nested replies have both 'root' and 'reply' markers
- Legacy threading without markers is supported

## Usage Examples

### Creating a Root Note

```dart
final partialNote = PartialNote(
  'Hello Nostr! This is my first post.',
  tags: {'nostr', 'introduction'},
);

final signedNote = await partialNote.signWith(signer);
await signedNote.save();
```

### Creating a Reply

```dart
// Reply to a root note
final replyToRoot = PartialNote(
  'Great to see you here!',
  replyTo: originalNote,
  root: originalNote, // Same as replyTo for root replies
);

// Reply to a nested comment
final nestedReply = PartialNote(
  'I agree with this point.',
  replyTo: someReply,
  root: originalNote, // Always reference the thread root
);

final signedReply = await nestedReply.signWith(signer);
await signedReply.publish();
```

### Querying Notes

```dart
// Get recent notes from specific authors
final notesState = ref.watch(
  query<Note>(
    authors: {pubkey1, pubkey2},
    limit: 50,
    since: DateTime.now().subtract(Duration(days: 7)),
    and: (note) => {
      note.author,
      note.reactions,
      note.zaps,
    },
  ),
);

// Get notes with specific hashtags
final taggedNotes = ref.watch(
  query<Note>(
    tags: {
      '#t': {'nostr', 'flutter'},
    },
    limit: 20,
  ),
);

// Get a thread (root note with all replies)
final threadState = ref.watch(
  query<Note>(
    ids: {rootNoteId},
    and: (note) => {
      note.allReplies,
      note.author,
    },
  ),
);
```

### Working with Threads

```dart
// Check if a note is part of a thread
if (!note.isRoot) {
  final rootNote = note.root.value;
  final parentNote = note.replyTo.value;
  
  print('This is a reply to: ${parentNote?.content}');
  print('Root of thread: ${rootNote?.content}');
}

// Get all replies to a note
final replies = note.replies.toList();
for (final reply in replies) {
  print('Reply: ${reply.content}');
  print('Author: ${reply.author.value?.nameOrNpub}');
}
```

### Search and Filtering

```dart
// Text search within notes
final searchResults = ref.watch(
  query<Note>(
    search: 'bitcoin',
    limit: 30,
    since: DateTime.now().subtract(Duration(hours: 24)),
  ),
);

// Notes with high engagement
final popularNotes = ref.watch(
  query<Note>(
    authors: followingPubkeys,
    limit: 20,
    and: (note) => {
      note.reactions,
      note.zaps,
    },
    where: (note) {
      // Filter in-memory for high engagement
      return note.reactions.length > 5 || 
             note.zaps.length > 0;
    },
  ),
);
```

## Content Guidelines

### Hashtags
Notes can include hashtags using `#t` tags:
```dart
final noteWithTags = PartialNote(
  'Excited about #nostr development! #opensource #freedom',
  tags: {'nostr', 'opensource', 'freedom'},
);
```

### Mentions
Reference other users with `#p` tags:
```dart
// The framework handles this automatically when using linkProfile()
partialNote.linkProfile(mentionedUser);
```

### Links and Media
- URLs in content are automatically linkified by clients
- Media can be referenced via URLs or NIP-94 file metadata events

## Related Models

- **[Profile](profile.md)** - Authors of notes
- **[Reaction](reaction.md)** - Likes and emoji reactions
- **[Zap](zap.md)** - Lightning payments to notes
- **[Repost](repost.md)** - Note reposts (NIP-18)
- **[Comment](comment.md)** - Structured comments (NIP-22)

## Implementation Notes

- Notes use NIP-10 for proper threading support
- Content is stored as plain text in the event content field
- Hashtags are stored as `t` tags for discoverability
- The threading logic supports both modern (with markers) and legacy threading
- Root detection is based on the presence of `e` tags with 'root' markers
- Reply relationships are established through `e` tags with appropriate markers 