# Community Model

**Kind:** 10222 (Replaceable Event)  
**NIP:** NIP-72  
**Class:** `Community extends ReplaceableModel<Community>`

## Overview

The Community model represents moderated communities in the Nostr protocol, similar to Reddit-style forums. Communities provide a way to organize content around specific topics with defined rules, content sections, and moderation capabilities. They support various content types, payment requirements, and integration with external services.

## Properties

### Core Properties
- **`name: String?`** - Community name (falls back to author name if not set)
- **`description: String?`** - Community description or rules
- **`relayUrls: Set<String>`** - Recommended relays for this community
- **`contentSections: Set<CommunityContentSection>`** - Defined content categories

### Content Sections
Each community can define multiple content sections with:
- **Content type** - Description of allowed content
- **Event kinds** - Specific Nostr event kinds allowed
- **Fees** - Payment requirements in satoshis

## Relationships

### Direct Relationships
- **`chatMessages: HasMany<ChatMessage>`** - Messages posted to this community

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The community owner/creator
- **`reactions: HasMany<Reaction>`** - Reactions to the community
- **`zaps: HasMany<Zap>`** - Zaps sent to the community
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this community
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this community

## Usage Examples

### Creating a Community

```dart
final partialCommunity = PartialCommunity(
  name: 'Nostr Development',
  description: '''
A community for Nostr protocol developers and enthusiasts.

Rules:
1. Stay on topic - discussions should relate to Nostr development
2. Be respectful and constructive
3. No spam or promotional content
4. Technical questions and help requests are welcome
  ''',
  relayUrls: {
    'wss://relay.damus.io',
    'wss://relay.primal.net',
    'wss://relay.nostr.band',
  },
  contentSections: {
    CommunityContentSection(
      content: 'General Discussion',
      kinds: {1}, // Text notes only
      feeInSats: null, // Free
    ),
    CommunityContentSection(
      content: 'Technical Articles',
      kinds: {30023}, // Long-form articles
      feeInSats: 100, // 100 sats to post
    ),
    CommunityContentSection(
      content: 'Project Announcements',
      kinds: {1, 30023}, // Notes and articles
      feeInSats: 500, // 500 sats to post
    ),
  },
);

final signedCommunity = await partialCommunity.signWith(signer);
await signedCommunity.publish();
```

### Querying Communities

```dart
// Get all communities
final communitiesState = ref.watch(
  query<Community>(
    limit: 50,
    and: (community) => {
      community.author,
      community.chatMessages,
    },
  ),
);

// Get communities by a specific moderator
final moderatedCommunitiesState = ref.watch(
  query<Community>(
    authors: {moderatorPubkey},
    and: (community) => {
      community.chatMessages,
    },
  ),
);

// Search communities by name/description
final searchResults = ref.watch(
  query<Community>(
    search: 'bitcoin development',
    limit: 20,
    and: (community) => {
      community.author,
    },
  ),
);
```

### Community Discovery

```dart
Widget buildCommunityList(List<Community> communities) {
  return ListView.builder(
    itemCount: communities.length,
    itemBuilder: (context, index) {
      final community = communities[index];
      final messageCount = community.chatMessages.length;
      
      return CommunityCard(
        name: community.name ?? 'Unnamed Community',
        description: community.description,
        moderator: community.author.value?.nameOrNpub ?? 'Unknown',
        messageCount: messageCount,
        memberCount: estimateMemberCount(community),
        onTap: () => navigateToCommunity(community),
      );
    },
  );
}

// Estimate member count from recent activity
int estimateMemberCount(Community community) {
  final recentMessages = community.chatMessages.toList()
    .where((msg) => msg.createdAt.isAfter(
      DateTime.now().subtract(Duration(days: 30)),
    ));
  
  final uniqueAuthors = recentMessages
    .map((msg) => msg.author.value?.pubkey)
    .where((pubkey) => pubkey != null)
    .toSet();
  
  return uniqueAuthors.length;
}
```

### Posting to Communities

```dart
// Post a message to a community
Future<void> postToCommunity(
  Community community,
  String content,
  Signer signer,
) async {
  // Check if content type is allowed
  final allowsTextNotes = community.contentSections
    .any((section) => section.kinds.contains(1));
  
  if (!allowsTextNotes) {
    throw Exception('Text notes not allowed in this community');
  }
  
  // Check fee requirements
  final textNoteSection = community.contentSections
    .firstWhere((section) => section.kinds.contains(1));
  
  if (textNoteSection.feeInSats != null) {
    // Handle payment requirement
    await handleCommunityFee(community, textNoteSection.feeInSats!);
  }
  
  final partialMessage = PartialChatMessage(
    content,
    community: community,
  );
  
  final signedMessage = await partialMessage.signWith(signer);
  await signedMessage.publish();
}

// Post an article to a community
Future<void> postArticleToCommunity(
  Community community,
  String title,
  String content,
  Signer signer,
) async {
  // Check if articles are allowed
  final allowsArticles = community.contentSections
    .any((section) => section.kinds.contains(30023));
  
  if (!allowsArticles) {
    throw Exception('Articles not allowed in this community');
  }
  
  // Create targeted publication
  final partialPublication = PartialTargetedPublication(
    identifier: 'article-${DateTime.now().millisecondsSinceEpoch}',
    targetedKind: 30023,
    communityPubkeys: {community.author.value!.pubkey},
    relayUrls: community.relayUrls,
  );
  
  final signedPublication = await partialPublication.signWith(signer);
  await signedPublication.publish();
  
  // Create the actual article
  final partialArticle = PartialArticle(
    title: title,
    content: content,
    slug: 'community-article-${DateTime.now().millisecondsSinceEpoch}',
  );
  
  final signedArticle = await partialArticle.signWith(signer);  
  await signedArticle.publish();
}
```

### Community Moderation

```dart
class CommunityModerator {
  final Community community;
  final Signer moderatorSigner;
  
  CommunityModerator(this.community, this.moderatorSigner);
  
  // Check if user is the community moderator
  bool isModeratedBy(String pubkey) {
    return community.author.value?.pubkey == pubkey;
  }
  
  // Remove inappropriate content (NIP-09 deletion)
  Future<void> removeMessage(ChatMessage message, String reason) async {
    if (!isModeratedBy(moderatorSigner.pubkey)) {
      throw Exception('Not authorized to moderate this community');
    }
    
    final deletionEvent = PartialDeletion(
      eventIds: {message.id},
      reason: reason,
    );
    
    final signedDeletion = await deletionEvent.signWith(moderatorSigner);
    await signedDeletion.publish();
  }
  
  // Update community rules or settings
  Future<void> updateCommunity({
    String? name,
    String? description,
    Set<String>? relayUrls,
    Set<CommunityContentSection>? contentSections,
  }) async {
    final updatedCommunity = PartialCommunity(
      name: name ?? community.name!,
      description: description ?? community.description,
      relayUrls: relayUrls ?? community.relayUrls,
      contentSections: contentSections ?? community.contentSections,
    );
    
    final signedUpdate = await updatedCommunity.signWith(moderatorSigner);
    await signedUpdate.publish();
  }
}
```

### Community Analytics

```dart
class CommunityAnalytics {
  final Community community;
  
  CommunityAnalytics(this.community);
  
  Map<String, dynamic> getStats() {
    final messages = community.chatMessages.toList();
    final now = DateTime.now();
    
    // Activity over time periods
    final last24h = messages.where((m) => 
      m.createdAt.isAfter(now.subtract(Duration(days: 1))));
    final last7d = messages.where((m) => 
      m.createdAt.isAfter(now.subtract(Duration(days: 7))));
    final last30d = messages.where((m) => 
      m.createdAt.isAfter(now.subtract(Duration(days: 30))));
    
    // Unique contributors
    final uniqueContributors = messages
      .map((m) => m.author.value?.pubkey)
      .where((pubkey) => pubkey != null)
      .toSet()
      .length;
    
    // Top contributors
    final contributorCounts = <String, int>{};
    for (final message in messages) {
      final authorPubkey = message.author.value?.pubkey;
      if (authorPubkey != null) {
        contributorCounts[authorPubkey] = 
          (contributorCounts[authorPubkey] ?? 0) + 1;
      }
    }
    
    final topContributors = contributorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return {
      'total_messages': messages.length,
      'messages_24h': last24h.length,
      'messages_7d': last7d.length,
      'messages_30d': last30d.length,
      'unique_contributors': uniqueContributors,
      'top_contributors': topContributors.take(10).map((e) => {
        'pubkey': e.key,
        'message_count': e.value,
      }).toList(),
      'growth_rate': calculateGrowthRate(messages),
    };
  }
  
  double calculateGrowthRate(List<ChatMessage> messages) {
    final now = DateTime.now();
    final thisWeek = messages.where((m) => 
      m.createdAt.isAfter(now.subtract(Duration(days: 7)))).length;
    final lastWeek = messages.where((m) => 
      m.createdAt.isBefore(now.subtract(Duration(days: 7))) &&
      m.createdAt.isAfter(now.subtract(Duration(days: 14)))).length;
    
    if (lastWeek == 0) return thisWeek.toDouble();
    return ((thisWeek - lastWeek) / lastWeek) * 100;
  }
}
```

### Content Section Configuration

```dart
// Define different types of content sections
final discussionSection = CommunityContentSection(
  content: 'General Discussion',
  kinds: {1}, // Only text notes
  feeInSats: null, // Free to post
);

final mediaSection = CommunityContentSection(
  content: 'Media Sharing',
  kinds: {1, 1063}, // Notes and file metadata
  feeInSats: 50, // Small fee to prevent spam
);

final premiumSection = CommunityContentSection(
  content: 'Premium Content',
  kinds: {30023}, // Long-form articles only
  feeInSats: 1000, // Higher fee for quality content
);

// Helper to check if content type is allowed
bool isContentAllowed(Community community, int eventKind) {
  return community.contentSections
    .any((section) => section.kinds.contains(eventKind));
}

// Get fee for content type
int? getFeeForContentType(Community community, int eventKind) {
  final section = community.contentSections
    .firstWhereOrNull((section) => section.kinds.contains(eventKind));
  
  return section?.feeInSats;
}
```

## Related Models

- **[ChatMessage](chat-message.md)** - Messages posted to communities
- **[Profile](profile.md)** - Community creators and members
- **[TargetedPublication](targeted-publication.md)** - Content published to communities
- **[Article](article.md)** - Long-form content in communities

## Implementation Notes

- Communities are replaceable events (kind 10222) with no `d` tag
- Content sections are defined using sequential `content`, `k`, and `fee` tags
- The `r` tags specify recommended relays for the community
- Payment integration requires Lightning infrastructure for fee collection
- Moderation is handled by the community creator (author)
- Communities can integrate with external services via tags (blossom, cashu, etc.)
- Privacy: Community membership and activity are public by design 