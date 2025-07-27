# Direct Messages & Encryption

Create encrypted direct messages using **NIP-44 (preferred)** or NIP-04 (legacy only).

**⚠️ ALWAYS use NIP-44 encryption** unless the user specifically requests NIP-04 compatibility. NIP-44 provides superior security, forward secrecy, and metadata protection.

## Creating Encrypted Messages

```dart
// ✅ PREFERRED: Create a message with NIP-44 encryption (default)
final dm = PartialDirectMessage(
  content: 'Hello, this is a secret message!',
  receiver: 'npub1abc123...', // Recipient's npub
  useNip44: true, // ✅ DEFAULT: Use secure NIP-44 encryption
);

// ⚠️ LEGACY ONLY: Use NIP-04 only when specifically needed
final legacyDm = PartialDirectMessage(
  content: 'Legacy message for compatibility',
  receiver: 'npub1abc123...',
  useNip44: false, // ⚠️ Only use when required for compatibility
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

## Encryption Standards Comparison

**NIP-44 (ALWAYS USE THIS):**
- ✅ Modern encryption with superior security
- ✅ Forward secrecy protection
- ✅ Metadata protection
- ✅ Recommended for all new applications

**NIP-04 (LEGACY ONLY):**
- ⚠️ Older encryption method with known security limitations
- ⚠️ Less secure than NIP-44
- ⚠️ Only use when specifically requested for compatibility