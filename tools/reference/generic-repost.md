# GenericRepost Model

**Kind:** 16 (Regular Event)  
**NIP:** NIP-18 (Extension)  
**Class:** `GenericRepost extends RegularModel<GenericRepost>`

## Overview

The GenericRepost model represents reposts of any type of Nostr event, not just notes. While the standard Repost model (kind 6) is specifically for notes, GenericRepost (kind 16) can handle articles, profiles, communities, and other event types. This provides a unified reposting mechanism across all content types.

## Properties

### Core Properties
- **`content: String`** - Optional commentary on the repost
- **`repostedEventId: String?`** - ID of the event being reposted
- **`repostedEventPubkey: String?`** - Public key of the original event's author
- **`repostedEventKind: int?`** - Kind of the event being reposted
- **`relayUrl: String?`** - Relay URL where the original event can be found

## Relationships

### Direct Relationships
- **`repostedEvent: BelongsTo<Model>`** - The original event being reposted (any type)
- **`repostedEventAuthor: BelongsTo<Profile>`** - The author of the original event

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The profile that created this repost
- **`reactions: HasMany<Reaction>`** - Reactions to this repost
- **`zaps: HasMany<Zap>`** - Zaps sent to this repost
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this repost
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this repost

## Usage Examples

### Reposting Articles

```dart
// Repost a long-form article
final partialRepost = PartialGenericRepost(
  content: 'This is an excellent deep dive into Lightning Network routing algorithms!',
  repostedEvent: article,
  repostedEventAuthor: article.author.value,
  repostedEventKind: 30023, // Article kind
);

final signedRepost = await partialRepost.signWith(signer);
await signedRepost.publish();
```

### Reposting Profiles

```dart
// Repost/recommend a profile
final partialRepost = PartialGenericRepost(
  content: 'One of the most insightful Bitcoin developers on Nostr. Definitely worth following!',
  repostedEvent: profile,
  repostedEventAuthor: profile, // Profile is self-authored
  repostedEventKind: 0, // Profile kind
);

final signedRepost = await partialRepost.signWith(signer);
await signedRepost.publish();
```

### Reposting Communities

```dart
// Repost a community to recommend it
final partialRepost = PartialGenericRepost(
  content: 'Great community for Lightning developers. Active discussions and helpful members.',
  repostedEvent: community,
  repostedEventAuthor: community.author.value,
  repostedEventKind: 10222, // Community kind
);

final signedRepost = await partialRepost.signWith(signer);
await signedRepost.publish();
```

### Querying Generic Reposts

```dart
// Get all reposts by a specific user
final userRepostsState = ref.watch(
  query<GenericRepost>(
    authors: {userPubkey},
    limit: 50,
    and: (repost) => {
      repost.repostedEvent,
      repost.repostedEventAuthor,
    },
  ),
);

// Get reposts of a specific event
final eventRepostsState = ref.watch(
  query<GenericRepost>(
    tags: {
      '#e': {eventId},
    },
    and: (repost) => {
      repost.author,
      repost.repostedEvent,
    },
  ),
);

// Get reposts by content type
final articleRepostsState = ref.watch(
  query<GenericRepost>(
    tags: {
      '#k': {'30023'}, // Article kind
    },
    limit: 20,
    and: (repost) => {
      repost.repostedEvent,
      repost.author,
    },
  ),
);
```

### Working with Generic Reposts

```dart
// Display repost with content type awareness
Widget buildGenericRepostCard(GenericRepost repost) {
  final author = repost.author.value;
  final originalEvent = repost.repostedEvent.value;
  final originalAuthor = repost.repostedEventAuthor.value;
  final eventKind = repost.repostedEventKind;
  
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Repost header with content type
          Row(
            children: [
              Icon(Icons.repeat, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text(
                '${author?.nameOrNpub ?? 'Unknown'} reposted ${_getContentTypeName(eventKind)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Spacer(),
              Text(formatTimestamp(repost.createdAt)),
            ],
          ),
          
          // Commentary
          if (repost.content.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              repost.content,
              style: TextStyle(fontSize: 16),
            ),
            Divider(),
          ],
          
          // Original content preview
          if (originalEvent != null) ...[
            _buildContentPreview(originalEvent, originalAuthor),
          ] else ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Original ${_getContentTypeName(eventKind)} not available',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
          
          // Engagement
          SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.favorite_border, size: 16),
                onPressed: () => _reactToRepost(repost),
              ),
              Text('${repost.reactions.length}'),
              SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.flash_on, size: 16),
                onPressed: () => _zapRepost(repost),
              ),
              Text('${repost.zaps.length}'),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildContentPreview(Model content, Profile? author) {
  switch (content.runtimeType) {
    case Article:
      final article = content as Article;
      return _buildArticlePreview(article, author);
    case Note:
      final note = content as Note;
      return _buildNotePreview(note, author);
    case Profile:
      final profile = content as Profile;
      return _buildProfilePreview(profile);
    case Community:
      final community = content as Community;
      return _buildCommunityPreview(community, author);
    default:
      return _buildGenericPreview(content, author);
  }
}

String _getContentTypeName(int? kind) {
  switch (kind) {
    case 0: return 'profile';
    case 1: return 'note';
    case 3: return 'contact list';
    case 6: return 'repost';
    case 7: return 'reaction';
    case 9: return 'chat message';
    case 1063: return 'file';
    case 1111: return 'comment';
    case 9735: return 'zap';
    case 10222: return 'community';
    case 30023: return 'article';
    case 30063: return 'release';
    default: return 'content';
  }
}
```

### Repost Analytics

```dart
class GenericRepostAnalytics {
  static Map<String, dynamic> analyzeReposts(List<GenericRepost> reposts) {
    // Content type breakdown
    final kindCounts = <int, int>{};
    for (final repost in reposts) {
      final kind = repost.repostedEventKind ?? 0;
      kindCounts[kind] = (kindCounts[kind] ?? 0) + 1;
    }
    
    // Popular content types
    final popularTypes = kindCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Repost engagement
    final withCommentary = reposts.where((r) => r.content.isNotEmpty);
    final totalEngagement = reposts.fold<int>(
      0, 
      (sum, repost) => sum + repost.reactions.length + repost.zaps.length,
    );
    
    // Time analysis
    final now = DateTime.now();
    final recent = reposts.where((r) => 
      r.createdAt.isAfter(now.subtract(Duration(days: 7))));
    
    return {
      'total_reposts': reposts.length,
      'recent_reposts': recent.length,
      'with_commentary': withCommentary.length,
      'commentary_rate': reposts.isEmpty 
        ? 0.0 
        : withCommentary.length / reposts.length,
      'total_engagement': totalEngagement,
      'average_engagement': reposts.isEmpty 
        ? 0.0 
        : totalEngagement / reposts.length,
      'content_type_breakdown': popularTypes.map((e) => {
        'kind': e.key,
        'type_name': _getContentTypeName(e.key),
        'count': e.value,
      }).toList(),
    };
  }
  
  static String _getContentTypeName(int kind) {
    // Same implementation as above
    switch (kind) {
      case 0: return 'profile';
      case 1: return 'note';
      case 30023: return 'article';
      case 10222: return 'community';
      default: return 'other';
    }
  }
}
```

### Content Discovery

```dart
// Find trending reposts across content types
final trendingRepostsState = ref.watch(
  query<GenericRepost>(
    since: DateTime.now().subtract(Duration(hours: 24)),
    limit: 50,
    and: (repost) => {
      repost.repostedEvent,
      repost.author,
      repost.reactions,
    },
    where: (repost) {
      // Filter for reposts with engagement
      return repost.reactions.length > 1;
    },
  ),
);

// Discover content by repost volume
Future<List<Model>> getPopularContentByReposts(Ref ref, int kind, int days) async {
  final reposts = await ref.storage.query(
    RequestFilter<GenericRepost>(
      tags: {
        '#k': {kind.toString()},
      },
      since: DateTime.now().subtract(Duration(days: days)),
    ).toRequest(),
  );
  
  // Count reposts per event
  final eventCounts = <String, int>{};
  for (final repost in reposts) {
    final eventId = repost.repostedEventId;
    if (eventId != null) {
      eventCounts[eventId] = (eventCounts[eventId] ?? 0) + 1;
    }
  }
  
  // Get top events by repost count
  final topEvents = eventCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  // Fetch the actual events
  final topEventIds = topEvents.take(20).map((e) => e.key).toSet();
  return await ref.storage.query(
    RequestFilter<Model>(ids: topEventIds).toRequest(),
  );
}
```

### Repost Validation

```dart
// Prevent duplicate reposts
Future<bool> hasAlreadyReposted(
  Model content, 
  Signer signer, 
  Ref ref,
) async {
  final existingReposts = await ref.storage.query(
    RequestFilter<GenericRepost>(
      authors: {signer.pubkey},
      tags: {
        '#e': {content.id},
      },
    ).toRequest(),
  );
  
  return existingReposts.isNotEmpty;
}

// Smart repost creation
Future<GenericRepost?> createSmartRepost(
  Model content,
  String commentary,
  Signer signer,
  Ref ref,
) async {
  // Check for duplicates
  if (await hasAlreadyReposted(content, signer, ref)) {
    throw Exception('Already reposted this content');
  }
  
  // Check if reposting own content
  if (content.author.value?.pubkey == signer.pubkey) {
    throw Exception('Cannot repost your own content');
  }
  
  final partialRepost = PartialGenericRepost(
    content: commentary,
    repostedEvent: content,
    repostedEventAuthor: content.author.value,
    repostedEventKind: content.event.kind,
  );
  
  final signedRepost = await partialRepost.signWith(signer);
  await signedRepost.publish();
  
  return signedRepost;
}
```

## Best Practices

### Content Guidelines
- Add meaningful commentary that provides value
- Respect the original creator's intent
- Use appropriate reposts for content discovery
- Avoid excessive reposting (spam prevention)

### Technical Considerations
```dart
// Always include proper metadata
final partialRepost = PartialGenericRepost(
  repostedEvent: content,           // Creates 'e' tag
  repostedEventAuthor: author,      // Creates 'p' tag
  repostedEventKind: content.kind,  // Creates 'k' tag
  // Optional relay hint for discoverability
  relayUrl: 'wss://relay.example.com',
);
```

### User Experience
- Show clear content type indicators
- Provide easy access to original content
- Display repost context and commentary
- Handle unavailable content gracefully

## Related Models

- **[Repost](repost.md)** - Specific repost model for notes (kind 6)
- **[Article](article.md)** - Articles that can be reposted
- **[Profile](profile.md)** - Profiles that can be recommended
- **[Community](community.md)** - Communities that can be shared
- **[Reaction](reaction.md)** - Reactions to reposts
- **[Zap](zap.md)** - Lightning payments to reposts

## Implementation Notes

- Generic reposts use regular events (kind 16) as an extension of NIP-18
- The `e` tag MUST contain the ID of the reposted event
- The `p` tag SHOULD contain the pubkey of the original author
- The `k` tag contains the kind of the reposted event for filtering
- Content field can contain commentary or be empty
- Works with any Nostr event type, not just notes
- Enables cross-content-type discovery and recommendation
- Consider implementing repost limits to prevent spam 