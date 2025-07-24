# Nostr Wallet Connect (NWC) Models

**NIPs:** NIP-47  
**Event Kinds:** 13194 (Info), 23194 (Request), 23195 (Response), 23196 (Notification)  
**Classes:** `NwcInfo`, `NwcRequest`, `NwcResponse`, `NwcNotification`, `NwcConnection`, `NwcManager`

## Overview

The NWC (Nostr Wallet Connect) models implement the complete NIP-47 specification for connecting applications to Lightning wallets over Nostr. This enables secure wallet operations like paying invoices, creating invoices, checking balances, and receiving real-time payment notifications - all through the Nostr protocol.

## Core Models

### NwcInfo (Kind 13194)
**Class:** `NwcInfo extends ReplaceableModel<NwcInfo>`

Published by wallet services to advertise their capabilities and supported methods.

#### Properties
- **`supportedMethods: List<String>`** - List of supported NWC methods
- **`supportedNotifications: List<String>`** - List of supported notification types

#### Methods
- **`supportsMethod(String method): bool`** - Check if a method is supported
- **`supportsNotification(String notification): bool`** - Check if a notification type is supported

#### Method Constants
```dart
// Available NWC methods
NwcInfo.payInvoice          // 'pay_invoice'
NwcInfo.multiPayInvoice     // 'multi_pay_invoice' 
NwcInfo.payKeysend          // 'pay_keysend'
NwcInfo.multiPayKeysend     // 'multi_pay_keysend'
NwcInfo.makeInvoice         // 'make_invoice'
NwcInfo.lookupInvoice       // 'lookup_invoice'
NwcInfo.listTransactions    // 'list_transactions'
NwcInfo.getBalance          // 'get_balance'
NwcInfo.getInfo             // 'get_info'

// Notification types
NwcInfo.paymentReceived     // 'payment_received'
NwcInfo.paymentSent         // 'payment_sent'
```

### NwcRequest (Kind 23194)
**Class:** `NwcRequest extends EphemeralModel<NwcRequest>`

Encrypted requests from clients to wallet services for wallet operations.

#### Properties
- **`walletPubkey: String`** - The wallet service's public key
- **`expiration: DateTime?`** - Optional expiration time for the request
- **`isExpired: bool`** - Whether this request has expired
- **`encryptedContent: String`** - NIP-04 encrypted command data

#### Methods
- **`decryptContent(Signer signer): Future<Map<String, dynamic>>`** - Decrypt request content
- **`getMethod(Signer signer): Future<String>`** - Get the command method
- **`getParams(Signer signer): Future<Map<String, dynamic>?>`** - Get command parameters

### NwcResponse (Kind 23195)
**Class:** `NwcResponse extends EphemeralModel<NwcResponse>`

Encrypted responses from wallet services back to clients with command results.

#### Properties
- **`clientPubkey: String`** - The client's public key
- **`requestEventId: String?`** - ID of the request being responded to
- **`encryptedContent: String`** - NIP-04 encrypted response data

#### Methods
- **`decryptContent(Signer signer): Future<Map<String, dynamic>>`** - Decrypt response content
- **`getResultType(Signer signer): Future<String>`** - Get the result type
- **`getResult(Signer signer): Future<Map<String, dynamic>?>`** - Get result data
- **`getError(Signer signer): Future<NwcError?>`** - Get error information
- **`hasError(Signer signer): Future<bool>`** - Check if response contains an error

### NwcNotification (Kind 23196)
**Class:** `NwcNotification extends EphemeralModel<NwcNotification>`

Real-time notifications from wallet services about payment events.

#### Properties
- **`clientPubkey: String`** - The client's public key
- **`encryptedContent: String`** - NIP-04 encrypted notification data

#### Methods
- **`decryptContent(Signer signer): Future<Map<String, dynamic>>`** - Decrypt notification content
- **`getNotificationType(Signer signer): Future<String>`** - Get notification type
- **`getNotification(Signer signer): Future<Map<String, dynamic>?>`** - Get notification data
- **`isPaymentReceived(Signer signer): Future<bool>`** - Check if payment received
- **`isPaymentSent(Signer signer): Future<bool>`** - Check if payment sent

## Connection Management

### NwcConnection
Represents a connection to a specific wallet service.

#### Properties
- **`walletPubkey: String`** - Wallet service's public key
- **`secret: String`** - Client's secret key for this connection (hex)
- **`relay: String`** - Relay URL where wallet service listens
- **`lud16: String?`** - Optional Lightning address
- **`limits: NwcConnectionLimits?`** - Optional budget limits and permissions
- **`createdAt: DateTime`** - When connection was created
- **`expiresAt: DateTime?`** - Optional expiration time
- **`clientPubkey: String`** - Derived client public key
- **`isExpired: bool`** - Whether connection has expired

#### Methods
- **`fromUri(String uri): NwcConnection`** - Create from NWC URI
- **`toUri(): String`** - Generate NWC URI for this connection

### NwcConnectionLimits
Defines budget limits and permissions for connections.

#### Properties
- **`maxAmount: int?`** - Maximum spendable amount in sats per renewal period
- **`budgetRenewal: NwcBudgetRenewal`** - Budget renewal frequency
- **`allowedMethods: Set<String>`** - Allowed request methods

#### Budget Renewal Options
```dart
NwcBudgetRenewal.never    // No automatic renewal
NwcBudgetRenewal.daily    // Daily budget renewal
NwcBudgetRenewal.weekly   // Weekly budget renewal
NwcBudgetRenewal.monthly  // Monthly budget renewal
NwcBudgetRenewal.yearly   // Yearly budget renewal
```

## High-Level Manager: NwcManager

**Provider:** `nwcManagerProvider`

The `NwcManager` class provides a high-level interface for NWC operations with secure storage and connection management.

### Setup and Connection Management

#### Store a Connection
```dart
final manager = ref.read(nwcManagerProvider);

// Parse connection from NWC URI
final connection = NwcConnection.fromUri(
  'nostr+walletconnect://wallet_pubkey?relay=wss://relay.example.com&secret=client_secret'
);

// Store the connection securely (encrypted with NIP-44)
await manager.storeConnection('my_wallet', connection);

// Set as active connection
await manager.setActiveConnection('my_wallet');
```

#### Manage Connections
```dart
// Get all stored connections
final connections = await manager.getAllConnections();

// Get specific connection
final connection = await manager._getConnection('my_wallet');

// Remove a connection
await manager.removeConnection('my_wallet');

// Clear all NWC data
await manager.clearAll();
```

### Command Execution

The manager provides both low-level command execution and high-level convenience methods.

#### Execute Commands Directly
```dart
// Get wallet balance
final balanceResult = await manager.executeCommand(GetBalanceCommand());
print('Balance: ${balanceResult.balance} sats');

// Get wallet info
final infoResult = await manager.executeCommand(GetInfoCommand());
print('Supported methods: ${infoResult.methods}');

// Pay an invoice
final payResult = await manager.executeCommand(
  PayInvoiceCommand(invoice: 'lnbc1000n1...'),
);
print('Payment preimage: ${payResult.preimage}');

// Create an invoice
final invoiceResult = await manager.executeCommand(
  MakeInvoiceCommand(
    amount: 1000, // sats
    description: 'Payment for services',
  ),
);
print('Invoice: ${invoiceResult.invoice}');

// Lookup an invoice
final lookupResult = await manager.executeCommand(
  LookupInvoiceCommand(paymentHash: 'abc123...'),
);
print('Invoice settled: ${lookupResult.isSettled}');
```

## NWC Commands

### PayInvoiceCommand
Pays a Lightning invoice through the connected wallet.

#### Basic Usage
```dart
final command = PayInvoiceCommand(
  invoice: 'lnbc1000n1pn7s8kspp5...',
  amount: 1000, // Optional: amount in msats if invoice doesn't specify
);

final result = await manager.executeCommand(command);
print('Preimage: ${result.preimage}');
print('Fees paid: ${result.feesPaid} msats');
```

#### Zap Integration
The `PayInvoiceCommand` has special support for zaps with automatic zap request creation:

```dart
// Pay a zap to a user (handles all zap complexity internally)
final zapCommand = await PayInvoiceCommand.fromPubkey(
  recipientPubkey: 'user_pubkey',
  amountSats: 1000,
  ref: ref,
  comment: 'Great post!',
  zapRelays: ['wss://relay1.com', 'wss://relay2.com'],
  linkedModel: someNote, // Optional: zap a specific note
);

final result = await manager.executeCommand(zapCommand);
```

#### High-Level Zap Method
```dart
// Even simpler: use the manager's built-in zap method
final result = await manager.sendZap(
  recipientPubkey: 'user_pubkey',
  amountSats: 1000,
  comment: 'Great post!',
  linkedModel: someNote,
);
```

### GetBalanceCommand
Retrieves the current wallet balance.

```dart
final command = GetBalanceCommand();
final result = await manager.executeCommand(command);
print('Balance: ${result.balance} msats');
```

### MakeInvoiceCommand
Creates a new Lightning invoice.

```dart
final command = MakeInvoiceCommand(
  amount: 5000, // msats
  description: 'Payment for services',
  expiry: 3600, // seconds
);

final result = await manager.executeCommand(command);
print('Invoice: ${result.invoice}');
print('Payment hash: ${result.paymentHash}');
```

### GetInfoCommand
Gets information about the wallet service.

```dart
final command = GetInfoCommand();
final result = await manager.executeCommand(command);

print('Wallet alias: ${result.alias}');
print('Network: ${result.network}');
print('Supported methods: ${result.methods}');
print('Supported notifications: ${result.notifications}');
```

### LookupInvoiceCommand
Looks up an invoice by payment hash or invoice string.

```dart
// Lookup by payment hash
final command = LookupInvoiceCommand(paymentHash: 'abc123...');

// Or lookup by invoice string
final command = LookupInvoiceCommand(invoice: 'lnbc1000n1...');

final result = await manager.executeCommand(command);
print('Invoice settled: ${result.isSettled}');
print('Amount: ${result.amount} msats');
```

## Error Handling

### NwcException
All wallet errors are wrapped in `NwcException` with structured error codes:

```dart
try {
  final result = await manager.executeCommand(command);
} on NwcException catch (e) {
  print('Wallet error: ${e.error.code} - ${e.error.message}');
  
  // Handle specific error codes
  switch (e.error.code) {
    case NwcError.insufficientBalance:
      // Handle insufficient balance
      break;
    case NwcError.quotaExceeded:
      // Handle quota exceeded
      break;
    case NwcError.paymentFailed:
      // Handle payment failure
      break;
  }
}
```

### Error Codes
```dart
NwcError.rateLimited           // Rate limited
NwcError.notImplemented        // Method not implemented
NwcError.insufficientBalance   // Insufficient balance
NwcError.quotaExceeded         // Quota exceeded
NwcError.restricted            // Operation restricted
NwcError.unauthorized          // Unauthorized
NwcError.internal              // Internal error
NwcError.other                 // Other error
NwcError.paymentFailed         // Payment failed
NwcError.notFound              // Invoice not found
```

## Advanced Usage

### Custom Command Timeout
```dart
final result = await manager.executeCommand(
  command,
  timeout: Duration(seconds: 60), // Custom timeout
);
```

### Connection-Specific Commands
```dart
// Use a specific connection instead of the active one
final result = await manager.executeCommand(
  command,
  connectionId: 'backup_wallet',
);
```

### Request Expiration
```dart
final result = await manager.executeCommand(
  command,
  expiration: DateTime.now().add(Duration(minutes: 5)),
);
```

### Secure Secret Storage
The manager can also store arbitrary secrets securely:

```dart
// Store a secret
await manager.storeSecret('api_key', 'secret_value');

// Retrieve a secret
final secret = await manager.getSecret('api_key');

// Remove a secret
await manager.removeSecret('api_key');
```

## Security Features

### Encryption
- **Connection Storage**: All connections are encrypted with NIP-44 using your own keypair
- **Request/Response**: All NWC communication uses NIP-04 encryption between client and wallet
- **Key Derivation**: Follows NIP-47 specification for proper key management

### Budget Controls
```dart
final limits = NwcConnectionLimits(
  maxAmount: 50000, // Max 50k sats
  budgetRenewal: NwcBudgetRenewal.daily,
  allowedMethods: {'pay_invoice'}, // Only allow payments
);

final connection = NwcConnection(
  walletPubkey: walletPubkey,
  secret: secret,
  relay: relay,
  limits: limits,
  createdAt: DateTime.now(),
  expiresAt: DateTime.now().add(Duration(days: 30)),
);
```

### Connection Expiration
Connections can have automatic expiration dates for enhanced security:

```dart
final connection = NwcConnection(
  // ... other properties
  expiresAt: DateTime.now().add(Duration(days: 30)),
);

if (connection.isExpired) {
  // Handle expired connection
}
```

## Complete Example

Here's a complete example showing how to set up and use NWC:

```dart
// 1. Set up the manager
final manager = ref.read(nwcManagerProvider);

// 2. Parse and store a connection from URI
final nwcUri = 'nostr+walletconnect://wallet_pubkey?relay=wss://relay.example.com&secret=client_secret';
final connection = NwcConnection.fromUri(nwcUri);
await manager.storeConnection('main_wallet', connection);
await manager.setActiveConnection('main_wallet');

// 3. Check wallet capabilities
try {
  final info = await manager.executeCommand(GetInfoCommand());
  print('Connected to: ${info.alias}');
  print('Supported methods: ${info.methods}');
  
  // 4. Check balance
  final balance = await manager.executeCommand(GetBalanceCommand());
  print('Current balance: ${balance.balance} msats');
  
  // 5. Send a zap
  final zapResult = await manager.sendZap(
    recipientPubkey: 'recipient_pubkey',
    amountSats: 1000,
    comment: 'Thanks for the great content!',
  );
  print('Zap sent! Preimage: ${zapResult.preimage}');
  
  // 6. Create an invoice
  final invoice = await manager.executeCommand(
    MakeInvoiceCommand(
      amount: 5000,
      description: 'Payment for services',
    ),
  );
  print('Invoice created: ${invoice.invoice}');
  
} on NwcException catch (e) {
  print('Wallet error: ${e.error.code} - ${e.error.message}');
} catch (e) {
  print('Other error: $e');
}
```

## URI Format

NWC URIs follow the NIP-47 specification:

```
nostr+walletconnect://<wallet_pubkey>?relay=<relay_url>&secret=<client_secret>&lud16=<optional_lightning_address>
```

Example:
```
nostr+walletconnect://a1b2c3d4e5f6...?relay=wss%3A%2F%2Frelay.example.com&secret=f6e5d4c3b2a1...&lud16=wallet%40example.com
```

## Provider Integration

The NWC manager integrates with Riverpod providers:

```dart
// Access the manager
final manager = ref.read(nwcManagerProvider);

// Watch for active signer changes (manager requires an active signer)
ref.listen(Signer.activeSignerProvider, (previous, next) {
  if (next == null) {
    // Handle signer logout - NWC operations will fail
  }
});
```

## Storage Backend

All NWC data is stored using the `CustomData` model with NIP-44 encryption:
- **Connections**: Stored with identifier `nwc_connection_<id>`
- **Active Connection**: Stored with identifier `nwc_active_connection`
- **Secrets**: Stored with identifier `nwc_secret_<key>`

This ensures that your wallet connections and secrets are end-to-end encrypted and only accessible with your private key. 