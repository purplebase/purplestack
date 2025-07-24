# Zap Model

**Kind:** 9735 (Regular Event) - Zap Receipt  
**NIP:** NIP-57  
**Class:** `Zap extends RegularModel<Zap>`

## Overview

The Zap model represents Lightning payment receipts in the Nostr protocol. Zaps are a way to send Bitcoin micropayments to content creators, combining social interaction with monetary value. A zap consists of a payment request (ZapRequest) and a payment receipt (Zap).

## Properties

### Core Properties
- **`amount: int`** - Payment amount in satoshis

## Relationships

### Direct Relationships
- **`wallet: BelongsTo<Profile>`** - The Lightning wallet that processed the payment
- **`recipient: BelongsTo<Profile>`** - The profile receiving the zap
- **`zappedModel: BelongsTo<Model>`** - The content (note, article, etc.) being zapped
- **`zapRequest: BelongsTo<ZapRequest>`** - The original payment request

### Special Author Relationship
- **`author: BelongsTo<Profile>`** - Overridden to reference the zap sender (from description)

### Inherited Relationships
- **`reactions: HasMany<Reaction>`** - Reactions to this zap
- **`zaps: HasMany<Zap>`** - Zaps sent to this zap (rare)
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this zap
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this zap

## Usage Examples

### Creating a Zap Request

```dart
// First create a zap request (kind 9734)
final zapRequest = PartialZapRequest(
  comment: 'Great content! 🚀',
  recipientPubkey: authorPubkey,
  targetEventId: noteId,
  amount: 1000, // sats
);

final signedZapRequest = await zapRequest.signWith(signer);

// Get Lightning invoice from recipient's lud16 address
final recipientProfile = await ref.storage.get<Profile>(authorPubkey);
final invoice = await recipientProfile?.createLightningInvoice(
  amountSats: 1000,
  comment: signedZapRequest.toMap().toString(),
);

if (invoice != null) {
  // Pay the invoice through your Lightning wallet
  // The wallet will create the zap receipt (kind 9735)
}
```

### Querying Zaps

```dart
// Get all zaps for a specific note
final zapsState = ref.watch(
  query<Zap>(
    tags: {
      '#e': {noteId},
    },
    and: (zap) => {
      zap.author, // The sender
      zap.recipient,
      zap.wallet,
    },
  ),
);

// Get zaps sent by a specific user
final sentZapsState = ref.watch(
  query<Zap>(
    where: (zap) => zap.author.value?.pubkey == userPubkey,
    limit: 50,
    and: (zap) => {
      zap.zappedModel,
      zap.recipient,
    },
  ),
);

// Get zaps received by a user
final receivedZapsState = ref.watch(
  query<Zap>(
    tags: {
      '#p': {userPubkey},
    },
    and: (zap) => {
      zap.author,
      zap.zappedModel,
    },
  ),
);
```

### Working with Zaps

```dart
// Calculate total zaps for content
final zaps = note.zaps.toList();
final totalSats = zaps.fold<int>(
  0, 
  (sum, zap) => sum + zap.amount,
);

print('Total zapped: $totalSats sats');

// Group zaps by sender
final zapsBySender = <String, List<Zap>>{};
for (final zap in zaps) {
  final senderPubkey = zap.author.value?.pubkey ?? 'unknown';
  zapsBySender.putIfAbsent(senderPubkey, () => []).add(zap);
}

// Show zap leaderboard
final sortedSenders = zapsBySender.entries.toList()
  ..sort((a, b) {
    final aTotal = a.value.fold<int>(0, (sum, zap) => sum + zap.amount);
    final bTotal = b.value.fold<int>(0, (sum, zap) => sum + zap.amount);
    return bTotal.compareTo(aTotal);
  });

for (final entry in sortedSenders.take(10)) {
  final totalAmount = entry.value.fold<int>(0, (sum, zap) => sum + zap.amount);
  print('${entry.key}: $totalAmount sats');
}
```

### Zap Analytics

```dart
// Zap statistics for a profile
final profileZaps = profile.zaps.toList();
final stats = {
  'total_received': profileZaps.fold<int>(0, (sum, zap) => sum + zap.amount),
  'zap_count': profileZaps.length,
  'average_zap': profileZaps.isEmpty 
    ? 0 
    : profileZaps.fold<int>(0, (sum, zap) => sum + zap.amount) ~/ profileZaps.length,
  'top_zapper': profileZaps.isEmpty
    ? null
    : profileZaps
        .groupBy((zap) => zap.author.value?.pubkey)
        .entries
        .map((e) => MapEntry(
          e.key,
          e.value.fold<int>(0, (sum, zap) => sum + zap.amount),
        ))
        .reduce((a, b) => a.value > b.value ? a : b)
        .key,
};

print('Profile zap stats: $stats');
```

## ZapRequest Model

**Kind:** 9734 (Regular Event)  
**Class:** `ZapRequest extends RegularModel<ZapRequest>`

The ZapRequest represents the initial payment request before the actual zap.

### Properties
- **`comment: String?`** - Optional comment/message with the zap

### Creating Zap Requests
```dart
final zapRequest = PartialZapRequest(
  comment: 'Thanks for this insight!',
  // Additional metadata set automatically
);
```

## Integration Notes

### Lightning Wallet Integration
Zaps require integration with Lightning wallets that support NIP-57:
- The wallet generates zap receipts after successful payments
- Receipts contain the original zap request in the description
- Amount is parsed from the BOLT11 invoice

### Client Implementation
```dart
// Check if a profile supports zaps
if (profile.lud16 != null) {
  // Profile can receive zaps via Lightning address
  final invoice = await profile.createLightningInvoice(
    amountSats: zapAmount,
    comment: zapComment,
  );
  
  if (invoice != null) {
    // Present invoice to user for payment
    await payInvoice(invoice);
  }
}
```

## Related Models

- **[Profile](profile.md)** - Zap senders and recipients
- **[Note](note.md)** - Notes that can be zapped
- **[Article](article.md)** - Articles that can be zapped
- **[Reaction](reaction.md)** - Alternative form of engagement

## Implementation Notes

- Zaps are created by Lightning wallets, not directly by clients
- The amount is extracted from the BOLT11 invoice in the receipt
- Zap receipts reference the original ZapRequest via the description tag
- Metadata processing extracts payment amount and original author
- The `transformMap()` method removes sensitive payment data for local storage
- Zaps to replaceable events should use `a` tags instead of `e` tags 