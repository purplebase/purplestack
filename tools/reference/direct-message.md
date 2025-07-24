# DirectMessage Model

**Kind:** 4 (Regular Event)  
**NIP:** NIP-04, NIP-44  
**Class:** `DirectMessage extends RegularModel<DirectMessage>`

## Overview

The DirectMessage model represents encrypted private messages between users in the Nostr protocol. It supports both NIP-04 (legacy) and NIP-44 (modern) encryption standards, providing end-to-end encrypted communication that is stored on relays but can only be decrypted by the intended participants.

## Properties

### Core Properties
- **`content: String`** - Raw encrypted content (use `decryptContent()` for plaintext)
- **`receiver: String`** - Recipient's public key in npub format
- **`encryptedContent: String`** - Alias for raw encrypted content
- **`isEncrypted: bool`** - Whether the content appears to be encrypted

### Async Properties
- **`decryptContent(): Future<String>`** - Decrypts and returns the plaintext message

## Relationships

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The sender of the message
- **`reactions: HasMany<Reaction>`** - Reactions to this message (rare for DMs)
- **`zaps: HasMany<Zap>`** - Zaps sent to this message
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this message
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this message (rare for DMs)

## Usage Examples

### Sending Direct Messages

```dart
// Create encrypted direct message using NIP-44 (recommended)
final partialDM = PartialDirectMessage(
  receiverPubkey: recipientPubkey,
  content: 'Hello! This is a private message.',
  encryptionType: EncryptionType.nip44, // Modern encryption
);

final signedDM = await partialDM.signWith(signer);
await signedDM.publish();

// Using NIP-04 (legacy) for backward compatibility
final legacyDM = PartialDirectMessage(
  receiverPubkey: recipientPubkey,
  content: 'This uses older encryption.',
  encryptionType: EncryptionType.nip04,
);

final signedLegacyDM = await legacyDM.signWith(signer);
await signedLegacyDM.publish();
```

### Querying Direct Messages

```dart
// Get conversation between two users
final conversationState = ref.watch(
  query<DirectMessage>(
    // Messages I sent to them OR they sent to me
    where: (dm) {
      final senderPubkey = dm.author.value?.pubkey;
      final receiverPubkey = dm.receiver;
      
      return (senderPubkey == myPubkey && receiverPubkey == theirNpub) ||
             (senderPubkey == theirPubkey && receiverPubkey == myNpub);
    },
    limit: 100,
    and: (dm) => {
      dm.author,
    },
  ),
);

// Get all my received messages
final receivedMessagesState = ref.watch(
  query<DirectMessage>(
    tags: {
      '#p': {myPubkey}, // Messages sent to me
    },
    limit: 50,
    and: (dm) => {
      dm.author,
    },
  ),
);

// Get all my sent messages
final sentMessagesState = ref.watch(
  query<DirectMessage>(
    authors: {myPubkey}, // Messages I sent
    limit: 50,
  ),
);
```

### Decrypting Messages

```dart
// Decrypt a single message
Future<String> getMessageText(DirectMessage dm) async {
  try {
    return await dm.decryptContent();
  } catch (e) {
    return '[Failed to decrypt message]';
  }
}

// Decrypt multiple messages
Future<List<DecryptedMessage>> decryptConversation(
  List<DirectMessage> messages,
) async {
  final decrypted = <DecryptedMessage>[];
  
  for (final dm in messages) {
    try {
      final plaintext = await dm.decryptContent();
      decrypted.add(DecryptedMessage(
        message: dm,
        plaintext: plaintext,
        decryptedSuccessfully: true,
      ));
    } catch (e) {
      decrypted.add(DecryptedMessage(
        message: dm,
        plaintext: '[Decryption failed]',
        decryptedSuccessfully: false,
      ));
    }
  }
  
  return decrypted;
}

class DecryptedMessage {
  final DirectMessage message;
  final String plaintext;
  final bool decryptedSuccessfully;
  
  DecryptedMessage({
    required this.message,
    required this.plaintext,
    required this.decryptedSuccessfully,
  });
}
```

### Building a Chat Interface

```dart
class ChatScreen extends ConsumerWidget {
  final String otherUserPubkey;
  
  const ChatScreen({required this.otherUserPubkey});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationState = ref.watch(
      query<DirectMessage>(
        // Query for conversation
        where: (dm) => isInConversation(dm, myPubkey, otherUserPubkey),
        and: (dm) => {dm.author},
      ),
    );
    
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: conversationState.when(
              data: (messages) => ChatMessageList(messages: messages),
              loading: () => CircularProgressIndicator(),
              error: (_, __) => Text('Error loading messages'),
            ),
          ),
          ChatInput(
            onSendMessage: (text) => sendMessage(ref, text, otherUserPubkey),
          ),
        ],
      ),
    );
  }
  
  bool isInConversation(DirectMessage dm, String myPubkey, String otherPubkey) {
    final senderPubkey = dm.author.value?.pubkey;
    final receiverNpub = dm.receiver;
    final otherNpub = Utils.encodeShareableFromString(otherPubkey, type: 'npub');
    final myNpub = Utils.encodeShareableFromString(myPubkey, type: 'npub');
    
    return (senderPubkey == myPubkey && receiverNpub == otherNpub) ||
           (senderPubkey == otherPubkey && receiverNpub == myNpub);
  }
  
  Future<void> sendMessage(WidgetRef ref, String text, String recipientPubkey) async {
    final signer = ref.read(Signer.activeSignerProvider);
    if (signer == null) return;
    
    final partialDM = PartialDirectMessage(
      receiverPubkey: recipientPubkey,
      content: text,
    );
    
    final signedDM = await partialDM.signWith(signer);
    await signedDM.publish();
  }
}
```

### Message List Widget

```dart
class ChatMessageList extends StatelessWidget {
  final List<DirectMessage> messages;
  
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
        return FutureBuilder<String>(
          future: message.decryptContent(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ChatBubble(
                text: snapshot.data!,
                isFromMe: message.author.value?.pubkey == myPubkey,
                timestamp: message.createdAt,
              );
            } else if (snapshot.hasError) {
              return ChatBubble(
                text: '[Failed to decrypt]',
                isFromMe: message.author.value?.pubkey == myPubkey,
                timestamp: message.createdAt,
                isError: true,
              );
            } else {
              return ChatBubble(
                text: '[Decrypting...]',
                isFromMe: message.author.value?.pubkey == myPubkey,
                timestamp: message.createdAt,
                isLoading: true,
              );
            }
          },
        );
      },
    );
  }
}
```

### Encryption Types

```dart
enum EncryptionType {
  nip04, // Legacy encryption (less secure)
  nip44, // Modern encryption (recommended)
}

// Helper to determine encryption type
EncryptionType detectEncryptionType(DirectMessage dm) {
  final content = dm.encryptedContent;
  
  // NIP-44 messages start with 'A' and don't contain '?'
  if (content.startsWith('A') && !content.contains('?')) {
    return EncryptionType.nip44;
  }
  
  // NIP-04 messages contain '?iv='
  if (content.contains('?')) {
    return EncryptionType.nip04;
  }
  
  // Default assumption
  return EncryptionType.nip04;
}
```

### Conversation Management

```dart
class ConversationManager {
  final Ref ref;
  
  ConversationManager(this.ref);
  
  // Get list of unique conversation partners
  Future<List<String>> getConversationPartners(String myPubkey) async {
    final allDMs = await ref.storage.query(
      // Get all DMs involving me
      RequestFilter<DirectMessage>(
        // This would need custom implementation as standard filters
        // don't support OR conditions easily
      ).toRequest(),
    );
    
    final partners = <String>{};
    
    for (final dm in allDMs) {
      final senderPubkey = dm.author.value?.pubkey;
      final receiverNpub = dm.receiver;
      final receiverPubkey = Utils.decodeShareableToString(receiverNpub);
      
      if (senderPubkey == myPubkey) {
        partners.add(receiverPubkey);
      } else if (receiverPubkey == myPubkey) {
        partners.add(senderPubkey);
      }
    }
    
    return partners.toList();
  }
  
  // Get last message in conversation
  Future<DirectMessage?> getLastMessage(String myPubkey, String otherPubkey) async {
    final messages = await ref.storage.query(
      RequestFilter<DirectMessage>(
        // Query for conversation messages
        limit: 1,
        // Would need custom filtering
      ).toRequest(),
    );
    
    return messages.isNotEmpty ? messages.first : null;
  }
  
  // Mark conversation as read (custom implementation)
  Future<void> markConversationAsRead(String otherPubkey) async {
    // Implementation depends on how you track read status
    // Could use a local database or custom events
  }
}
```

## Security Considerations

### Encryption Standards
- **NIP-44** (recommended): Modern encryption with better security properties
- **NIP-04** (legacy): Older standard, less secure but more widely supported

### Best Practices
```dart
// Always check if signer is available before decryption
Future<String> safeDecrypt(DirectMessage dm) async {
  final signer = ref.read(Signer.activeSignerProvider);
  if (signer == null) {
    throw Exception('No active signer for decryption');
  }
  
  return await dm.decryptContent();
}

// Handle decryption failures gracefully
Future<String> decryptWithFallback(DirectMessage dm) async {
  try {
    return await dm.decryptContent();
  } catch (e) {
    return '[Message could not be decrypted]';
  }
}
```

### Privacy Notes
- Messages are stored on relays in encrypted form
- Metadata (sender, recipient, timestamp) is public
- Content is only readable by sender and recipient
- Message timing and frequency patterns are visible

## Related Models

- **[Profile](profile.md)** - Message senders and recipients
- **[Signer](#)** - Required for encryption/decryption

## Implementation Notes

- Direct messages use regular events (kind 4)
- Content is encrypted using recipient's public key
- The `p` tag contains the recipient's public key
- Both NIP-04 and NIP-44 encryption are supported
- Decryption requires access to the private key via a signer
- Messages can only be decrypted by the sender or recipient
- Relay selection is important for privacy (avoid logging relays) 