# Repost Model

**Kind:** 6 (Regular Event)  
**NIP:** NIP-18  
**Class:** `Repost extends RegularModel<Repost>`

## Overview

The Repost model represents note reposts in the Nostr protocol. Reposts allow users to share existing notes with their followers, similar to retweets on Twitter. They reference the original note and its author, optionally including additional commentary.

## Properties

### Core Properties
- **`content: String`** - Optional additional commentary on the repost
- **`repostedNoteId: String?`** - ID of the original note being reposted
- **`repostedNotePubkey: String?`** - Public key of the original note's author
- **`relayUrl: String?`** - Relay URL where the original note can be found

## Relationships

### Direct Relationships
- **`repostedNote: BelongsTo<Note>`** - The original note being reposted
- **`repostedNoteAuthor: BelongsTo<Profile>`** - The author of the original note

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The profile that created this repost
- **`reactions: HasMany<Reaction>`** - Reactions to this repost
- **`zaps: HasMany<Zap>`** - Zaps sent to this repost
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this repost
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this repost

## Usage Examples

### Creating a Simple Repost

```dart
// Repost without additional commentary
final partialRepost = PartialRepost(
  repostedNote: originalNote,
  repostedNoteAuthor: originalNote.author.value,
);

final signedRepost = await partialRepost.signWith(signer);
await signedRepost.publish();
```

### Creating a Repost with Commentary

```dart
// Repost with additional commentary
final partialRepost = PartialRepost(
  content: 'This is an excellent analysis of the Lightning Network!',
  repostedNote: originalNote,
  repostedNoteAuthor: originalNote.author.value,
  relayUrl: 'wss://relay.damus.io', // Optional relay hint
);

final signedRepost = await partialRepost.signWith(signer);
await signedRepost.publish();
```

### Querying Reposts

```dart
// Get all reposts by a specific user
final repostsState = ref.watch(
  query<Repost>(
    authors: {userPubkey},
    limit: 50,
    and: (repost) => {
      repost.repostedNote,
      repost.repostedNoteAuthor,
      repost.author,
    },
  ),
);

// Get all reposts of a specific note
final noteRepostsState = ref.watch(
  query<Repost>(
    tags: {
      '#e': {noteId},
    },
    and: (repost) => {
      repost.author,
      repost.repostedNoteAuthor,
    },
  ),
);

// Get recent reposts with commentary
final commentedRepostsState = ref.watch(
  query<Repost>(
    since: DateTime.now().subtract(Duration(hours: 24)),
    where: (repost) => repost.content.isNotEmpty,
    limit: 20,
    and: (repost) => {
      repost.repostedNote,
      repost.author,
    },
  ),
);
```

### Working with Reposts

```dart
// Display repost in feed
Widget buildRepostCard(Repost repost) {
  final originalNote = repost.repostedNote.value;
  final originalAuthor = repost.repostedNoteAuthor.value;
  final reposterProfile = repost.author.value;
  
  return Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Repost header
        Row(
          children: [
            Icon(Icons.repeat, size: 16, color: Colors.green),
            SizedBox(width: 8),
            Text(
              '${reposterProfile?.nameOrNpub ?? 'Unknown'} reposted',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Spacer(),
            Text(formatTimestamp(repost.createdAt)),
          ],
        ),
        
        // Additional commentary (if any)
        if (repost.content.isNotEmpty) ...[
          SizedBox(height: 8),
          Text(
            repost.content,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          Divider(),
        ],
        
        // Original note content
        if (originalNote != null) ...[
          Row(
            children: [
              CircleAvatar(
                backgroundImage: originalAuthor?.pictureUrl != null
                  ? NetworkImage(originalAuthor!.pictureUrl!)
                  : null,
                child: originalAuthor?.pictureUrl == null
                  ? Text(originalAuthor?.nameOrNpub[0] ?? '?')
                  : null,
              ),
              SizedBox(width: 8),
              Text(
                originalAuthor?.nameOrNpub ?? 'Unknown',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(originalNote.content),
        ] else ...[
          Text(
            'Original note not available',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
        ],
        
        // Engagement buttons
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.favorite_border),
              onPressed: () => reactToRepost(repost),
            ),
            IconButton(
              icon: Icon(Icons.flash_on),
              onPressed: () => zapRepost(repost),
            ),
            IconButton(
              icon: Icon(Icons.repeat),
              onPressed: () => repostRepost(repost),
            ),
          ],
        ),
      ],
    ),
  );
}
```

### Repost Analytics

```dart
// Get repost statistics for a note
class RepostAnalytics {
  static Future<Map<String, dynamic>> getRepostStats(Note note, Ref ref) async {
    final reposts = await ref.storage.query(
      RequestFilter<Repost>(
        tags: {
          '#e': {note.id},
        },
      ).toRequest(),
    );
    
    // Group by time periods
    final now = DateTime.now();
    final last24h = reposts.where((r) => 
      r.createdAt.isAfter(now.subtract(Duration(days: 1))));
    final last7d = reposts.where((r) => 
      r.createdAt.isAfter(now.subtract(Duration(days: 7))));
    
    // Count reposts with commentary
    final withCommentary = reposts.where((r) => r.content.isNotEmpty);
    
    // Top reposters
    final reposterCounts = <String, int>{};
    for (final repost in reposts) {
      final reposterPubkey = repost.author.value?.pubkey ?? 'unknown';
      reposterCounts[reposterPubkey] = 
        (reposterCounts[reposterPubkey] ?? 0) + 1;
    }
    
    final topReposters = reposterCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return {
      'total_reposts': reposts.length,
      'reposts_24h': last24h.length,
      'reposts_7d': last7d.length,
      'with_commentary': withCommentary.length,
      'commentary_rate': reposts.isEmpty 
        ? 0.0 
        : withCommentary.length / reposts.length,
      'top_reposters': topReposters.take(5).map((e) => {
        'pubkey': e.key,
        'repost_count': e.value,
      }).toList(),
      'viral_score': calculateViralScore(reposts),
    };
  }
  
  static double calculateViralScore(List<Repost> reposts) {
    if (reposts.isEmpty) return 0.0;
    
    final now = DateTime.now();
    var score = 0.0;
    
    for (final repost in reposts) {
      final hoursAgo = now.difference(repost.createdAt).inHours;
      final timeDecay = 1.0 / (1.0 + hoursAgo * 0.1); // Decay over time
      final commentaryBonus = repost.content.isNotEmpty ? 1.5 : 1.0;
      
      score += timeDecay * commentaryBonus;
    }
    
    return score;
  }
}
```

### Repost Discovery

```dart
// Find trending reposts
final trendingRepostsState = ref.watch(
  query<Repost>(
    since: DateTime.now().subtract(Duration(hours: 12)),
    limit: 100,
    and: (repost) => {
      repost.repostedNote,
      repost.author,
      repost.reactions,
    },
    where: (repost) {
      // Filter for reposts with engagement
      return repost.reactions.length > 2;
    },
  ),
);

// Find reposts by followed users
final followingRepostsState = ref.watch(
  query<Repost>(
    authors: followingPubkeys,
    limit: 50,
    and: (repost) => {
      repost.repostedNote,
      repost.repostedNoteAuthor,
      repost.author,
    },
  ),
);
```

### Repost Validation

```dart
// Validate repost before creation
Future<bool> validateRepost(Note originalNote, Signer signer) async {
  // Check if user is trying to repost their own note
  if (originalNote.author.value?.pubkey == signer.pubkey) {
    throw Exception('Cannot repost your own note');
  }
  
  // Check if user has already reposted this note
  final existingReposts = await ref.storage.query(
    RequestFilter<Repost>(
      authors: {signer.pubkey},
      tags: {
        '#e': {originalNote.id},
      },
    ).toRequest(),
  );
  
  if (existingReposts.isNotEmpty) {
    throw Exception('Note already reposted');
  }
  
  return true;
}

// Remove repost (delete event)
Future<void> removeRepost(Repost repost, Signer signer) async {
  if (repost.author.value?.pubkey != signer.pubkey) {
    throw Exception('Can only delete your own reposts');
  }
  
  final deletionEvent = PartialDeletion(
    eventIds: {repost.id},
    reason: 'Removing repost',
  );
  
  final signedDeletion = await deletionEvent.signWith(signer);
  await signedDeletion.publish();
}
```

### Integration with Notes

```dart
// Add repost functionality to notes
extension NoteRepostExtension on Note {
  Future<Repost> createRepost(Signer signer, {String? commentary}) async {
    final partialRepost = PartialRepost(
      content: commentary ?? '',
      repostedNote: this,
      repostedNoteAuthor: author.value,
    );
    
    final signedRepost = await partialRepost.signWith(signer);
    await signedRepost.publish();
    
    return signedRepost;
  }
  
  Future<List<Repost>> getReposts(Ref ref) async {
    return await ref.storage.query(
      RequestFilter<Repost>(
        tags: {
          '#e': {id},
        },
      ).toRequest(),
    );
  }
}
```

## Best Practices

### Content Guidelines
- Keep additional commentary concise and relevant
- Add value with your commentary rather than just amplifying
- Consider the original author's intent and context

### Technical Considerations
```dart
// Always include required tags
final partialRepost = PartialRepost(
  repostedNote: originalNote, // Creates 'e' tag
  repostedNoteAuthor: originalAuthor, // Creates 'p' tag
  // Optional relay hint for better discoverability
  relayUrl: 'wss://relay.damus.io',
);
```

### User Experience
- Show clear attribution to original author
- Distinguish reposts from original content in feeds
- Provide easy access to original note context
- Handle cases where original note is unavailable

## Related Models

- **[Note](note.md)** - Original notes that can be reposted
- **[Profile](profile.md)** - Repost authors and original note authors
- **[GenericRepost](generic-repost.md)** - Generic reposts for other content types
- **[Reaction](reaction.md)** - Reactions to reposts
- **[Zap](zap.md)** - Lightning payments to reposts

## Implementation Notes

- Reposts use regular events (kind 6) following NIP-18
- The `e` tag MUST contain the ID of the reposted note
- The `p` tag SHOULD contain the pubkey of the original author
- Optional relay URL can be included in the `e` tag for better connectivity
- Content field can contain additional commentary or be empty
- Reposts can themselves be reposted, creating repost chains
- Consider implementing anti-spam measures for excessive reposting 