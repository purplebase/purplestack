# Using the `and` Operator for Relationships

The `and` operator enables reactive relationship loading and updates.

## Basic Relationship Loading

```dart
// Load notes with their authors and reactions
final notesState = ref.watch(
  query<Note>(
    limit: 20,
    and: (note) => {
      note.author,      // Load author profile
      note.reactions,   // Load reactions
      note.zaps,        // Load zaps
    },
  ),
);
```

## Nested Relationships

```dart
// Load notes with nested relationship data
final notesState = ref.watch(
  query<Note>(
    limit: 20,
    and: (note) => {
      note.author,      // Author profile
      note.reactions,   // Reactions
      ...note.reactions.map((reaction) => reaction.author), // Reaction authors
      note.zaps,        // Zaps
      ...note.zaps.map((zap) => zap.author), // Zap authors
    },
  ),
);
```

## Conditional Relationship Loading

```dart
// Only load relationships for notes with content
final notesState = ref.watch(
  query<Note>(
    limit: 20,
    and: (note) => {
      if (note.content.isNotEmpty) ...[
        note.author,
        note.reactions,
      ],
    },
  ),
);
```

## Relationship Updates

```dart
// When a new reaction is added, all queries watching that note
// will automatically update thanks to the relationship system

final newReaction = await PartialReaction(
  reactedOn: note,
  emojiTag: ('+', 'https://example.com/plus.png'),
).signWith(signer);

await ref.storage.save({newReaction});

// The note's reactions relationship will automatically update
// and any UI watching it will rebuild
```

## Community Chat Messages

```dart
// Load a community with its chat messages
final communityState = ref.watch(
  query<Community>(
    ids: {communityId},
    and: (community) => {
      community.chatMessages, // Load associated chat messages
    },
  ),
);

// Access the chat messages
final community = communityState.models.first;
final messages = community.chatMessages.toList();
``` 