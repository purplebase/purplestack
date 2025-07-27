# Working with DVMs (NIP-90)

Interact with Decentralized Virtual Machines for reputation verification and other services.

## Reputation Verification

```dart
// Create a reputation verification request
final verificationRequest = PartialVerifyReputationRequest(
  targetPubkey: 'npub1abc123...',
  inputData: {'threshold': '0.8'},
);

// Sign and submit the request
final signedRequest = await verificationRequest.signWith(signer);
await ref.storage.save({signedRequest});

// Listen for the response
final responseState = ref.watch(
  query<VerifyReputationResponse>(
    tags: {'#e': {signedRequest.event.id}},
    limit: 1,
  ),
);

// Handle the verification result
switch (responseState) {
  case StorageData():
    final response = responseState.models.firstOrNull;
    if (response != null) {
      final reputationScore = response.reputationScore;
      final isVerified = reputationScore > 0.8;
      // Update UI based on verification result
    }
    break;
  // Handle other states...
}
```

## Custom DVM Services

WIP