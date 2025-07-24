# Direct Messages & Encryption

Create encrypted direct messages using NIP-04 and NIP-44.

## Creating Encrypted Messages

```dart
// Create a message with automatic encryption
final dm = PartialDirectMessage(
  content: 'Hello, this is a secret message!',
  receiver: 'npub1abc123...', // Recipient's npub
  useNip44: true, // Use NIP-44 (more secure) or false for NIP-04
);

// Sign and encrypt the message
final signedDm = await dm.signWith(signer);

// Save to storage
await ref.storage.save({signedDm});
```

## Decrypting Messages

```dart
// Query for direct messages
final dmsState = ref.watch(
  query<DirectMessage>(
    authors: {signer.pubkey}, // Messages we sent
    tags: {'#p': {recipientPubkey}}, // Messages to specific recipient
  ),
);

// In your UI, decrypt messages asynchronously
class MessageTile extends StatelessWidget {
  final DirectMessage dm;
  
  const MessageTile({required this.dm, super.key});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: dm.decryptContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text('Decrypting...'),
            subtitle: Text(dm.encryptedContent),
          );
        }
        
        return ListTile(
          title: Text(snapshot.data ?? 'Failed to decrypt'),
          subtitle: Text(dm.createdAt.toString()),
        );
      },
    );
  }
}
```

## Message Threads

```dart
// Create a conversation view
class ConversationView extends ConsumerWidget {
  final String otherPubkey;
  
  const ConversationView({required this.otherPubkey, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesState = ref.watch(
      query<DirectMessage>(
        authors: {signer.pubkey, otherPubkey},
        tags: {'#p': {signer.pubkey, otherPubkey}},
        limit: 100,
      ),
    );
    
    return switch (messagesState) {
      StorageLoading() => Center(child: CircularProgressIndicator()),
      StorageError() => Center(child: Text('Error loading messages')),
      StorageData() => ListView.builder(
        reverse: true,
        itemCount: messagesState.models.length,
        itemBuilder: (context, index) {
          final dm = messagesState.models[index];
          final isFromMe = dm.event.pubkey == signer.pubkey;
          
          return MessageBubble(
            message: dm,
            isFromMe: isFromMe,
          );
        },
      ),
    };
  }
}
```

## Pre-encrypted Messages

```dart
// For messages already encrypted by external systems
final preEncryptedDm = PartialDirectMessage.encrypted(
  encryptedContent: 'A1B2C3...', // Already encrypted content
  receiver: 'npub1abc123...',
);

final signedDm = await preEncryptedDm.signWith(signer);
``` 