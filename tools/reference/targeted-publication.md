# TargetedPublication Model

**Kind:** 30222 (Parameterizable Replaceable Event)  
**NIP:** Not standardized  
**Class:** `TargetedPublication extends ParameterizableReplaceableModel<TargetedPublication>`

## Overview

The TargetedPublication model represents content published to specific communities or audiences in the Nostr ecosystem. It acts as a bridge between regular content (notes, articles, releases, etc.) and the communities where that content should be distributed. This enables content creators to target their publications to relevant audiences while maintaining community-specific distribution.

## Properties

### Core Properties
- **`targetedKind: int`** - The kind of the targeted content (e.g., 1 for notes, 30023 for articles)
- **`relayUrls: Set<String>`** - Relay URLs where the content should be distributed
- **`communityPubkeys: Set<String>`** - Public keys of communities this content targets

## Relationships

### Direct Relationships
- **`model: BelongsTo<Model>`** - The content being published (note, article, etc.)
- **`communities: HasMany<Community>`** - Communities this publication targets

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The profile that created this targeted publication
- **`reactions: HasMany<Reaction>`** - Reactions to this publication
- **`zaps: HasMany<Zap>`** - Zaps sent to this publication
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this publication
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this publication

## Usage Examples

### Publishing Articles to Communities

```dart
// Publish an article to specific developer communities
final communities = {
  bitcoinDevCommunity,
  lightningCommunity,
  nostrDevCommunity,
};

final partialTargetedPublication = PartialTargetedPublication(
  article, // The article to publish
  communities: communities,
  relayUrls: {
    'wss://relay.damus.io',
    'wss://nos.lol',
    'wss://relay.primal.net',
  },
);

final signedPublication = await partialTargetedPublication.signWith(signer);
await signedPublication.publish();
```

### Publishing Notes to Interest Groups

```dart
// Publish a note to hobby communities
final hobbyGroups = {
  photographyCommunity,
  travelCommunity,
};

final partialTargetedPublication = PartialTargetedPublication(
  note,
  communities: hobbyGroups,
);

final signedPublication = await partialTargetedPublication.signWith(signer);
await signedPublication.publish();
```

### Publishing Software Releases

```dart
// Announce a new software release to relevant communities
final techCommunities = {
  openSourceCommunity,
  rustDevCommunity,
  webDevCommunity,
};

final partialTargetedPublication = PartialTargetedPublication(
  release,
  communities: techCommunities,
  relayUrls: {
    'wss://relay.damus.io',
    'wss://nostr.wine',
  },
);

final signedPublication = await partialTargetedPublication.signWith(signer);
await signedPublication.publish();
```

### Querying Targeted Publications

```dart
// Get publications targeting a specific community
final communityPublicationsState = ref.watch(
  query<TargetedPublication>(
    tags: {
      '#p': {communityPubkey},
    },
    and: (publication) => {
      publication.model,
      publication.author,
      publication.communities,
    },
  ),
);

// Get publications by content type
final articlePublicationsState = ref.watch(
  query<TargetedPublication>(
    tags: {
      '#k': {'30023'}, // Article kind
    },
    limit: 20,
    and: (publication) => {
      publication.model,
      publication.communities,
    },
  ),
);

// Get recent publications from followed authors
final followedPublicationsState = ref.watch(
  query<TargetedPublication>(
    authors: followingPubkeys,
    since: DateTime.now().subtract(Duration(days: 7)),
    and: (publication) => {
      publication.model,
      publication.author,
      publication.communities,
    },
  ),
);
```

### Working with Targeted Publications

```dart
// Display targeted publication
Widget buildTargetedPublicationCard(TargetedPublication publication) {
  final author = publication.author.value;
  final targetedModel = publication.model.value;
  final communities = publication.communities.toList();
  
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Publication header
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
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author?.nameOrNpub ?? 'Unknown',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'published ${_getContentTypeName(publication.targetedKind)} to ${communities.length} communities',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(formatTimestamp(publication.createdAt)),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Target communities
          if (communities.isNotEmpty) ...[
            Text(
              'Communities:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: communities.map((community) {
                return Chip(
                  avatar: CircleAvatar(
                    child: Icon(Icons.group, size: 16),
                  ),
                  label: Text(community.name ?? 'Unnamed Community'),
                  onDeleted: null, // Read-only view
                );
              }).toList(),
            ),
            SizedBox(height: 12),
          ],
          
          // Content preview
          if (targetedModel != null) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _buildContentPreview(targetedModel),
            ),
            SizedBox(height: 12),
          ],
          
          // Relay distribution info
          if (publication.relayUrls.isNotEmpty) ...[
            ExpansionTile(
              title: Text('Distribution (${publication.relayUrls.length} relays)'),
              children: publication.relayUrls.map((relay) {
                return ListTile(
                  leading: Icon(Icons.router, size: 16),
                  title: Text(relay),
                  dense: true,
                );
              }).toList(),
            ),
          ],
          
          // Actions
          Row(
            children: [
              TextButton.icon(
                icon: Icon(Icons.favorite_border),
                label: Text('${publication.reactions.length}'),
                onPressed: () => _reactToPublication(publication),
              ),
              TextButton.icon(
                icon: Icon(Icons.flash_on),
                label: Text('${publication.zaps.length}'),
                onPressed: () => _zapPublication(publication),
              ),
              Spacer(),
              TextButton.icon(
                icon: Icon(Icons.open_in_new),
                label: Text('View Original'),
                onPressed: () => _viewOriginalContent(targetedModel),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildContentPreview(Model content) {
  switch (content.runtimeType) {
    case Note:
      final note = content as Note;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, size: 16, color: Colors.blue),
              SizedBox(width: 4),
              Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 4),
          Text(
            note.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    
    case Article:
      final article = content as Article;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.article, size: 16, color: Colors.green),
              SizedBox(width: 4),
              Text('Article', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 4),
          Text(
            article.title ?? 'Untitled Article',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          if (article.summary != null) ...[
            SizedBox(height: 2),
            Text(
              article.summary!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      );
    
    case Release:
      final release = content as Release;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.new_releases, size: 16, color: Colors.orange),
              SizedBox(width: 4),
              Text('Release', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 4),
          Text(
            '${release.appIdentifier} v${release.version}',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          if (release.releaseNotes != null) ...[
            SizedBox(height: 2),
            Text(
              release.releaseNotes!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      );
    
    default:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, size: 16),
              SizedBox(width: 4),
              Text(_getContentTypeName(content.event.kind)),
            ],
          ),
          SizedBox(height: 4),
          Text('Content preview not available'),
        ],
      );
  }
}

String _getContentTypeName(int kind) {
  switch (kind) {
    case 0: return 'Profile';
    case 1: return 'Note';
    case 6: return 'Repost';
    case 7: return 'Reaction';
    case 9735: return 'Zap';
    case 30023: return 'Article';
    case 30063: return 'Release';
    case 10222: return 'Community';
    default: return 'Content (kind $kind)';
  }
}
```

### Community Management

```dart
// Community-specific publication management
class CommunityPublicationManager {
  static Future<List<TargetedPublication>> getPublicationsForCommunity(
    Ref ref,
    Community community, {
    Duration? since,
    int limit = 50,
  }) async {
    return await ref.storage.query(
      RequestFilter<TargetedPublication>(
        tags: {
          '#p': {community.event.pubkey},
        },
        since: since != null 
          ? DateTime.now().subtract(since)
          : null,
        limit: limit,
      ).toRequest(),
    );
  }
  
  static Future<Map<String, int>> getContentTypeDistribution(
    List<TargetedPublication> publications,
  ) async {
    final distribution = <String, int>{};
    
    for (final publication in publications) {
      final typeName = _getContentTypeName(publication.targetedKind);
      distribution[typeName] = (distribution[typeName] ?? 0) + 1;
    }
    
    return distribution;
  }
  
  static Future<List<Profile>> getTopPublishers(
    Ref ref,
    Community community, {
    Duration period = const Duration(days: 30),
    int limit = 10,
  }) async {
    final publications = await getPublicationsForCommunity(
      ref, 
      community,
      since: period,
    );
    
    // Count publications per author
    final authorCounts = <String, int>{};
    for (final publication in publications) {
      final authorPubkey = publication.author.value?.pubkey ?? 'unknown';
      authorCounts[authorPubkey] = (authorCounts[authorPubkey] ?? 0) + 1;
    }
    
    // Get top authors
    final topAuthorPubkeys = authorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topPubkeys = topAuthorPubkeys
      .take(limit)
      .map((e) => e.key)
      .where((key) => key != 'unknown')
      .toSet();
    
    return await ref.storage.query(
      RequestFilter<Profile>(ids: topPubkeys).toRequest(),
    );
  }
}
```

### Publication Analytics

```dart
class TargetedPublicationAnalytics {
  static Map<String, dynamic> analyzePublications(
    List<TargetedPublication> publications,
  ) {
    if (publications.isEmpty) return {'total_publications': 0};
    
    // Content type distribution
    final contentTypes = <String, int>{};
    for (final publication in publications) {
      final typeName = _getContentTypeName(publication.targetedKind);
      contentTypes[typeName] = (contentTypes[typeName] ?? 0) + 1;
    }
    
    // Community distribution
    final communityTargets = <String, int>{};
    for (final publication in publications) {
      for (final communityPubkey in publication.communityPubkeys) {
        communityTargets[communityPubkey] = (communityTargets[communityPubkey] ?? 0) + 1;
      }
    }
    
    // Relay distribution
    final relayUsage = <String, int>{};
    for (final publication in publications) {
      for (final relay in publication.relayUrls) {
        relayUsage[relay] = (relayUsage[relay] ?? 0) + 1;
      }
    }
    
    // Engagement analysis
    final totalReactions = publications.fold<int>(
      0, 
      (sum, pub) => sum + pub.reactions.length,
    );
    
    final totalZaps = publications.fold<int>(
      0, 
      (sum, pub) => sum + pub.zaps.length,
    );
    
    return {
      'total_publications': publications.length,
      'content_type_distribution': contentTypes,
      'most_targeted_communities': communityTargets.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        .take(10)
        .map((e) => {
          'community_pubkey': e.key,
          'publication_count': e.value,
        }).toList(),
      'relay_usage': relayUsage,
      'engagement': {
        'total_reactions': totalReactions,
        'total_zaps': totalZaps,
        'average_reactions_per_publication': publications.isEmpty 
          ? 0.0 
          : totalReactions / publications.length,
        'average_zaps_per_publication': publications.isEmpty 
          ? 0.0 
          : totalZaps / publications.length,
      },
    };
  }
}
```

### Content Discovery

```dart
// Discover content through targeted publications
class ContentDiscovery {
  static Future<List<Model>> getPopularContentInCommunities(
    Ref ref,
    Set<Community> communities, {
    Duration period = const Duration(days: 7),
    int limit = 20,
  }) async {
    final communityPubkeys = communities.map((c) => c.event.pubkey).toSet();
    
    final publications = await ref.storage.query(
      RequestFilter<TargetedPublication>(
        tags: {
          '#p': communityPubkeys,
        },
        since: DateTime.now().subtract(period),
        limit: limit * 3, // Get more to filter
      ).toRequest(),
    );
    
    // Score content by engagement
    final contentScores = <String, double>{};
    for (final publication in publications) {
      final modelId = publication.model.value?.id;
      if (modelId != null) {
        final score = publication.reactions.length + (publication.zaps.length * 2.0);
        contentScores[modelId] = (contentScores[modelId] ?? 0) + score;
      }
    }
    
    // Get top content IDs
    final topContentIds = contentScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final contentIds = topContentIds
      .take(limit)
      .map((e) => e.key)
      .toSet();
    
    return await ref.storage.query(
      RequestFilter<Model>(ids: contentIds).toRequest(),
    );
  }
  
  static Future<List<Community>> recommendCommunitiesForContent(
    Ref ref,
    Model content, {
    int limit = 5,
  }) async {
    // Find similar content and see which communities they were published to
    final similarPublications = await ref.storage.query(
      RequestFilter<TargetedPublication>(
        tags: {
          '#k': {content.event.kind.toString()},
        },
        limit: 100,
      ).toRequest(),
    );
    
    // Count community frequency for this content type
    final communityCounts = <String, int>{};
    for (final publication in similarPublications) {
      for (final communityPubkey in publication.communityPubkeys) {
        communityCounts[communityPubkey] = (communityCounts[communityPubkey] ?? 0) + 1;
      }
    }
    
    // Get top communities
    final topCommunityPubkeys = communityCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final communityPubkeys = topCommunityPubkeys
      .take(limit)
      .map((e) => e.key)
      .toSet();
    
    return await ref.storage.query(
      RequestFilter<Community>(authors: communityPubkeys).toRequest(),
    );
  }
}
```

## Best Practices

### Community Selection
- Target relevant communities based on content type and topic
- Avoid spam by only publishing to communities where content adds value
- Consider community guidelines and moderation policies
- Build relationships within communities before mass publishing

### Technical Considerations
```dart
// Always specify the content type being targeted
final partialPublication = PartialTargetedPublication(
  content,
  communities: relevantCommunities,
);
// The targetedKind is automatically set from content.event.kind

// Include relay hints for better distribution
partialPublication.relayUrls = {
  'wss://relay.damus.io',
  'wss://nos.lol',
};
```

### Distribution Strategy
- Use appropriate relay selection for target communities
- Consider geographic and topical relay distribution
- Monitor publication performance and adjust targeting
- Respect community preferences for relay usage

## Related Models

- **[Community](community.md)** - Communities that content is published to
- **[Note](note.md)** - Notes that can be targeted for publication
- **[Article](article.md)** - Articles that can be targeted for publication
- **[Release](release.md)** - Software releases that can be targeted
- **[Profile](profile.md)** - Authors who create targeted publications
- **[Reaction](reaction.md)** - Reactions to targeted publications
- **[Zap](zap.md)** - Lightning payments to targeted publications

## Implementation Notes

- TargetedPublication uses parameterizable replaceable events (kind 30222) - not yet standardized
- The `k` tag specifies the kind of content being targeted
- The `p` tags contain community public keys for targeting
- The `r` tags specify relay URLs for distribution
- Content is referenced via `e` (regular events) or `a` (addressable events) tags
- Publications can target multiple communities simultaneously
- Consider implementing publication approval workflows for sensitive communities
- Monitor community engagement to optimize targeting strategies 