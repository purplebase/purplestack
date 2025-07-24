# ChatMessage Model

**Kind:** 9 (Regular Event)  
**NIP:** NIP-28  
**Class:** `ChatMessage extends RegularModel<ChatMessage>`

## Overview

The ChatMessage model represents messages in public chat channels or communities. Unlike direct messages, chat messages are public and can be seen by anyone. They support quoting other messages and are often associated with specific communities or chat channels.

## Properties

### Core Properties
- **`content: String`** - The text content of the chat message

## Relationships

### Direct Relationships
- **`quotedMessage: BelongsTo<ChatMessage>`** - Another chat message being quoted/replied to
- **`community: BelongsTo<Community>`** - The community this message belongs to (if any)

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The profile that sent this message
- **`reactions: HasMany<Reaction>`** - Reactions to this message
- **`zaps: HasMany<Zap>`** - Zaps sent to this message
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this message
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this message

## Usage Examples

### Sending Basic Chat Messages

```dart
// Simple chat message
final partialMessage = PartialChatMessage(
  'Hello everyone! Great to be here.',
);

final signedMessage = await partialMessage.signWith(signer);
await signedMessage.publish();
```

### Sending Community Messages

```dart
// Message to a specific community
final partialMessage = PartialChatMessage(
  'Has anyone tried the new Nostr client?',
  community: developerCommunity,
);

final signedMessage = await partialMessage.signWith(signer);
await signedMessage.publish();
```

### Quoting Messages

```dart
// Quote/reply to another message
final partialReply = PartialChatMessage(
  'I totally agree with this point!',
  quotedMessage: originalMessage,
  community: sameCommunity,
);

final signedReply = await partialReply.signWith(signer);
await signedReply.publish();
```

### Querying Chat Messages

```dart
// Get messages from a specific community
final communityMessagesState = ref.watch(
  query<ChatMessage>(
    tags: {
      '#h': {communityId},
    },
    limit: 100,
    and: (message) => {
      message.author,
      message.quotedMessage,
    },
  ),
);

// Get recent global chat messages
final globalChatState = ref.watch(
  query<ChatMessage>(
    since: DateTime.now().subtract(Duration(hours: 2)),
    limit: 50,
    and: (message) => {
      message.author,
      message.community,
    },
  ),
);

// Get messages by a specific user
final userMessagesState = ref.watch(
  query<ChatMessage>(
    authors: {userPubkey},
    limit: 100,
    and: (message) => {
      message.community,
      message.quotedMessage,
    },
  ),
);
```

### Building a Chat Interface

```dart
class ChatScreen extends ConsumerWidget {
  final Community? community;
  
  const ChatScreen({this.community});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesState = ref.watch(
      query<ChatMessage>(
        tags: community != null ? {'#h': {community!.id}} : null,
        limit: 100,
        and: (message) => {
          message.author,
          message.quotedMessage,
        },
      ),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text(community?.name ?? 'Global Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesState.when(
              data: (messages) => ChatMessageList(messages: messages),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
          ChatInputBar(
            onSendMessage: (text) => sendMessage(ref, text),
            community: community,
          ),
        ],
      ),
    );
  }
  
  Future<void> sendMessage(WidgetRef ref, String text) async {
    final signer = ref.read(Signer.activeSignerProvider);
    if (signer == null) return;
    
    final partialMessage = PartialChatMessage(
      text,
      community: community,
    );
    
    final signedMessage = await partialMessage.signWith(signer);
    await signedMessage.publish();
  }
}
```

### Message List Widget

```dart
class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  
  const ChatMessageList({required this.messages});
  
  @override
  Widget build(BuildContext context) {
    // Sort messages by timestamp
    final sortedMessages = messages.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    return ListView.builder(
      itemCount: sortedMessages.length,
      itemBuilder: (context, index) {
        final message = sortedMessages[index];
        final quotedMessage = message.quotedMessage.value;
        
        return ChatMessageCard(
          message: message,
          quotedMessage: quotedMessage,
          onQuote: () => _onQuoteMessage(context, message),
          onReact: () => _onReactToMessage(message),
        );
      },
    );
  }
  
  void _onQuoteMessage(BuildContext context, ChatMessage message) {
    // Show input dialog or navigate to reply interface
    showDialog(
      context: context,
      builder: (context) => QuoteMessageDialog(
        quotedMessage: message,
        onSend: (replyText) => _sendQuotedMessage(message, replyText),
      ),
    );
  }
  
  Future<void> _sendQuotedMessage(ChatMessage quoted, String replyText) async {
    final partialReply = PartialChatMessage(
      replyText,
      quotedMessage: quoted,
      community: quoted.community.value,
    );
    
    // Send the reply...
  }
}
```

### Message Card Widget

```dart
class ChatMessageCard extends StatelessWidget {
  final ChatMessage message;
  final ChatMessage? quotedMessage;
  final VoidCallback onQuote;
  final VoidCallback onReact;
  
  const ChatMessageCard({
    required this.message,
    this.quotedMessage,
    required this.onQuote,
    required this.onReact,
  });
  
  @override
  Widget build(BuildContext context) {
    final author = message.author.value;
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author and timestamp
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: author?.pictureUrl != null
                    ? NetworkImage(author!.pictureUrl!)
                    : null,
                  child: author?.pictureUrl == null
                    ? Text(author?.nameOrNpub[0] ?? '?')
                    : null,
                ),
                SizedBox(width: 8),
                Text(
                  author?.nameOrNpub ?? 'Unknown',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  formatTimestamp(message.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            // Quoted message (if any)
            if (quotedMessage != null) ...[
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border(
                    left: BorderSide(color: Colors.blue, width: 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quotedMessage!.author.value?.nameOrNpub ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      quotedMessage!.content,
                      style: TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
            ],
            
            // Message content
            Text(message.content),
            
            SizedBox(height: 8),
            
            // Action buttons
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border, size: 16),
                  onPressed: onReact,
                  tooltip: 'React',
                ),
                Text('${message.reactions.length}'),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.reply, size: 16),
                  onPressed: onQuote,
                  tooltip: 'Quote',
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.flash_on, size: 16),
                  onPressed: () => _zapMessage(message),
                  tooltip: 'Zap',
                ),
                Text('${message.zaps.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _zapMessage(ChatMessage message) {
    // Implement zap functionality
  }
}
```

### Chat Analytics

```dart
class ChatAnalytics {
  static Map<String, dynamic> analyzeCommunityChat(Community community) {
    final messages = community.chatMessages.toList();
    final now = DateTime.now();
    
    // Time-based analysis
    final last24h = messages.where((m) => 
      m.createdAt.isAfter(now.subtract(Duration(days: 1))));
    final last7d = messages.where((m) => 
      m.createdAt.isAfter(now.subtract(Duration(days: 7))));
    
    // User activity
    final userCounts = <String, int>{};
    for (final message in messages) {
      final authorPubkey = message.author.value?.pubkey ?? 'unknown';
      userCounts[authorPubkey] = (userCounts[authorPubkey] ?? 0) + 1;
    }
    
    final activeUsers = userCounts.length;
    final topUsers = userCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Quote/reply analysis
    final quotedMessages = messages.where((m) => m.quotedMessage.value != null);
    
    return {
      'total_messages': messages.length,
      'messages_24h': last24h.length,
      'messages_7d': last7d.length,
      'active_users': activeUsers,
      'quoted_messages': quotedMessages.length,
      'reply_rate': messages.isEmpty 
        ? 0.0 
        : quotedMessages.length / messages.length,
      'top_contributors': topUsers.take(10).map((e) => {
        'pubkey': e.key,
        'message_count': e.value,
      }).toList(),
      'average_messages_per_user': activeUsers == 0 
        ? 0.0 
        : messages.length / activeUsers,
    };
  }
  
  static List<String> extractMentions(String content) {
    final mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    return matches.map((m) => m.group(1)!).toList();
  }
  
  static List<String> extractHashtags(String content) {
    final hashtagRegex = RegExp(r'#(\w+)');
    final matches = hashtagRegex.allMatches(content);
    return matches.map((m) => m.group(1)!).toList();
  }
}
```

### Message Moderation

```dart
class ChatModerator {
  final Community community;
  final Signer moderatorSigner;
  
  ChatModerator(this.community, this.moderatorSigner);
  
  Future<void> deleteMessage(ChatMessage message, String reason) async {
    // Only community owner can moderate
    if (community.author.value?.pubkey != moderatorSigner.pubkey) {
      throw Exception('Not authorized to moderate this community');
    }
    
    final deletionEvent = PartialDeletion(
      eventIds: {message.id},
      reason: reason,
    );
    
    final signedDeletion = await deletionEvent.signWith(moderatorSigner);
    await signedDeletion.publish();
  }
  
  bool isSpam(ChatMessage message) {
    final content = message.content.toLowerCase();
    
    // Simple spam detection
    if (content.contains('buy now') || 
        content.contains('click here') ||
        content.split(' ').length < 3) {
      return true;
    }
    
    // Check for excessive links
    final linkCount = RegExp(r'https?://').allMatches(content).length;
    if (linkCount > 2) return true;
    
    return false;
  }
}
```

## Related Models

- **[Community](community.md)** - Communities that host chat messages
- **[Profile](profile.md)** - Message authors
- **[Reaction](reaction.md)** - Reactions to messages
- **[Zap](zap.md)** - Lightning payments to messages
- **[DirectMessage](direct-message.md)** - Private messaging alternative

## Implementation Notes

- Chat messages use regular events (kind 9) following NIP-28
- The `h` tag references the community/channel ID
- The `q` tag references quoted messages
- Messages are public and visible to all relay subscribers
- No built-in encryption (use DirectMessage for private communication)
- Communities can set posting fees and content rules
- Moderation is handled by community owners
- Real-time updates depend on relay WebSocket connections 