# Lightning Zaps with NWC (Nostr Wallet Connect)

This guide explains how to implement Lightning zaps in your Nostr application using the Nostr Wallet Connect protocol.

## Overview

Lightning zaps allow users to send Bitcoin payments to content creators through the Lightning Network. The implementation uses:
- **NWC (Nostr Wallet Connect)**: Protocol for connecting to Lightning wallets
- **ZapRequest**: Nostr event requesting payment to an invoice
- **Zap**: Nostr event confirming successful payment

## Prerequisites

```dart
import 'package:models/models.dart';
import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
```

## 1. Setting Up NWC Connection

### Connecting a Wallet

Users need to connect their Lightning wallet using an NWC connection string:

```dart
// Get NWC connection string from user (usually from wallet app)
final nwcString = 'nostr+walletconnect://...';

// Store the connection in the signer
final signer = ref.read(Signer.activeSignerProvider);
await signer.setNWCString(nwcString);
```

### Checking Connection Status

```dart
class ConnectionStatusWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signer = ref.watch(Signer.activeSignerProvider);
    final nwcString = useFuture(signer?.getNWCString()).data;
    
    return switch (nwcString) {
      null => Text('Checking wallet connection...'),
      String() when nwcString.isNotEmpty => Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          Text('Lightning wallet connected'),
        ],
      ),
      _ => Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          Text('No wallet connected'),
        ],
      ),
    };
  }
}
```

## 2. Creating and Sending Zaps

### Basic Zap Implementation

```dart
Future<void> sendZap({
  required Model zapTarget, // Article, Note, or other model
  required int satAmount,
  String? comment,
}) async {
  try {
    final signer = ref.read(Signer.activeSignerProvider);
    if (signer == null) {
      throw Exception('No active signer found. Please sign in first.');
    }

    // Check NWC connection
    final nwcString = await signer.getNWCString();
    if (nwcString == null || nwcString.isEmpty) {
      throw Exception('No wallet connected. Please connect a Lightning wallet.');
    }

    // Create zap request
    final zapRequest = PartialZapRequest();
    zapRequest.amount = satAmount * 1000; // Convert sats to millisats
    
    if (comment != null && comment.isNotEmpty) {
      zapRequest.comment = comment;
    }

    // Link to recipient (content author)
    zapRequest.linkProfileByPubkey(zapTarget.event.pubkey);
    
    // Link to the content being zapped
    zapRequest.linkModel(zapTarget);
    
    // Add relay information for better delivery
    zapRequest.relays = ref
        .read(storageNotifierProvider.notifier)
        .config
        .getRelays()
        .toList();

    // Sign and send the zap
    final signedZapRequest = await zapRequest.signWith(signer);
    await signedZapRequest.pay();

    // Success - show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ Zap successful! $satAmount sats sent'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    // Handle errors (see error handling section)
    _handleZapError(e);
  }
}
```

### Sample Zap Dialog Implementation

```dart
class ZapDialog extends ConsumerStatefulWidget {
  final Model target; // The content to zap
  final String? customAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.flash_on, color: Theme.of(context).colorScheme.primary),
          Text('Send Zap'),
        ],
      ),
      content: Column(
        children: [
          // Amount selection chips
          Wrap(
            children: [21, 100, 210, 1000].map((amount) {
              return ChoiceChip(
                label: Text('$amount sats'),
                selected: selectedAmount == amount,
                onSelected: (selected) {
                  setState(() {
                    selectedAmount = selected ? amount : null;
                  });
                },
              );
            }).toList(),
          ),
          
          // Custom amount input
          TextField(
            decoration: InputDecoration(labelText: 'Custom Amount (sats)'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final amount = int.tryParse(value);
              setState(() {
                selectedAmount = amount;
              });
            },
          ),
          
          // Optional comment
          TextField(
            decoration: InputDecoration(
              labelText: 'Comment (Optional)',
              hintText: 'Add a message with your zap...',
            ),
            maxLines: 3,
            onChanged: (value) {
              comment = value;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        AsyncButtonBuilder(
          onPressed: selectedAmount != null ? () => _sendZap() : null,
          child: Text('Zap ${selectedAmount ?? ''} sats'),
          builder: (context, child, callback, buttonState) {
            return FilledButton(
              onPressed: buttonState.maybeWhen(
                loading: () => null,
                orElse: () => callback,
              ),
              child: buttonState.maybeWhen(
                loading: () => CircularProgressIndicator(strokeWidth: 2),
                orElse: () => child,
              ),
            );
          },
        ),
      ],
    );
  }
}
```

## 3. Checking Zap Status

### Check if User Has Zapped

```dart
// In your content widget (e.g., ArticleCard, NoteCard)
Widget build(BuildContext context, WidgetRef ref) {
  final activePubkey = ref.watch(Signer.activePubkeyProvider);
  
  // Load content with zap relationships
  final contentState = ref.watch(
    query<Article>( // or Note, etc.
      ids: {contentId},
      and: (article) => {
        article.zaps, // Load zap relationships
      },
    ),
  );
  
  return switch (contentState) {
    StorageData() => Builder(
      builder: (context) {
        final content = contentState.models.first;
        final zaps = content.zaps.toList();
        
        // Check if current user has zapped this content
        final userHasZapped = zaps.any(
          (z) => z.author.value?.pubkey == activePubkey,
        );
        
        return Row(
          children: [
            IconButton(
              onPressed: () => _showZapDialog(content),
              icon: Icon(
                Icons.flash_on,
                color: userHasZapped 
                  ? Colors.orange 
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text('${zaps.length}'),
          ],
        );
      },
    ),
    _ => CircularProgressIndicator(),
  };
}
```

### Calculate Total Zap Amount

```dart
// Get total sats received
final totalSats = content.zaps.toList().fold<int>(
  0, 
  (sum, zap) => sum + zap.amount,
);

// Display zap metrics
Row(
  children: [
    Icon(Icons.flash_on, size: 16),
    Text('${content.zaps.length}'), // Zap count
    SizedBox(width: 8),
    Text('${totalSats} sats'), // Total amount
  ],
)
```

## 4. Error Handling

### Common Error Scenarios

```dart
void _handleZapError(dynamic error) {
  String message = 'Failed to send zap: $error';
  
  if (error.toString().contains('No NWC connection')) {
    message = 'No wallet connected. Please connect a Lightning wallet in your profile.';
  } else if (error.toString().contains('expired')) {
    message = 'Wallet connection expired. Please reconnect in your profile.';
  } else if (error.toString().contains('invoice')) {
    message = 'The author doesn\'t have Lightning receiving setup.';
  } else if (error.toString().contains('insufficient')) {
    message = 'Insufficient balance in your Lightning wallet.';
  } else if (error.toString().contains('rate limit')) {
    message = 'Too many requests. Please wait and try again.';
  }
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}
```

## 5. UI Patterns

### Zap Button Component

```dart
class ZapButton extends ConsumerWidget {
  final Model target;
  final bool showCount;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePubkey = ref.watch(Signer.activePubkeyProvider);
    final zaps = target.zaps.toList();
    
    final userHasZapped = activePubkey != null && zaps.any(
      (z) => z.author.value?.pubkey == activePubkey,
    );
    
    return IconButton(
      onPressed: () => showZapDialog(context, target),
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flash_on,
            color: userHasZapped 
              ? Colors.orange 
              : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          if (showCount) ...[
            SizedBox(width: 4),
            Text('${zaps.length}'),
          ],
        ],
      ),
    );
  }
}
```

### Engagement Row with Zaps

```dart
import 'package:purplestack/widgets/common/engagement_row.dart';

EngagementRow(
  likesCount: content.reactions.length,
  repostsCount: content.reposts.length,
  zapsCount: content.zaps.length,
  zapsSatAmount: content.zaps.toList().fold(0, (sum, zap) => sum + zap.amount),
  
  // User interaction state
  isZapped: userHasZapped,
  
  // Zap callback
  onZap: () => showZapDialog(context, content),
)
```

## 6. Best Practices

### Query Optimization

```dart
// Always load zap relationships when displaying content
final articlesState = ref.watch(
  query<Article>(
    limit: 50,
    and: (article) => {
      article.author,    // For author info
      article.zaps,      // For zap counts and user state
      // article.reactions, // If showing other engagement
    },
  ),
);
```

### Offline Handling

```dart
// Zaps require network connectivity
Future<void> sendZap() async {
  try {
    // Check network connectivity first
    if (!await isConnected()) {
      throw Exception('No internet connection. Zaps require network access.');
    }
    
    // Proceed with zap...
  } catch (e) {
    _handleZapError(e);
  }
}
```

### Performance Considerations

- Load zap relationships only when needed
- Use `AsyncButtonBuilder` to prevent double-taps
- Cache NWC connection status to avoid repeated checks
- Show immediate UI feedback while processing

This implementation provides a complete zapping system that integrates with NWC-compatible Lightning wallets while maintaining good UX patterns and error handling. 