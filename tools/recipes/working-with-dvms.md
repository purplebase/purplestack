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

```dart
// Define a custom DVM request model
@GeneratePartialModel()
class CustomDVMRequest extends RegularModel<CustomDVMRequest> {
  CustomDVMRequest.fromMap(super.map, super.ref) : super.fromMap();
  
  String get serviceType => event.getFirstTagValue('service') ?? '';
  Map<String, dynamic> get inputData => 
      json.decode(event.content) as Map<String, dynamic>;
}

class PartialCustomDVMRequest extends RegularPartialModel<CustomDVMRequest> 
    with PartialCustomDVMRequestMixin {
  PartialCustomDVMRequest({
    required String serviceType,
    required Map<String, dynamic> inputData,
  }) {
    event.kind = 5000; // Custom DVM request kind
    event.content = json.encode(inputData);
    event.addTagValue('service', serviceType);
  }
}
```

## DVM Error Handling

```dart
// Listen for DVM errors
final errorState = ref.watch(
  query<DVMError>(
    tags: {'#e': {requestEventId}},
    limit: 1,
  ),
);

switch (errorState) {
  case StorageData():
    final error = errorState.models.firstOrNull;
    if (error != null) {
      print('DVM Error: ${error.errorMessage}');
      // Handle the error appropriately
    }
    break;
  // Handle other states...
}
```

## Batch DVM Requests

```dart
// Submit multiple requests and collect responses
final requests = <String, Future<Model>>{};

for (final pubkey in pubkeysToVerify) {
  final request = PartialVerifyReputationRequest(
    targetPubkey: pubkey,
    inputData: {'threshold': '0.8'},
  );
  
  final signedRequest = await request.signWith(signer);
  requests[pubkey] = ref.storage.save({signedRequest}).then((_) => signedRequest);
}

// Wait for all requests to be submitted
final submittedRequests = await Future.wait(requests.values);

// Set up listeners for all responses
for (final request in submittedRequests) {
  ref.listen(
    query<VerifyReputationResponse>(
      tags: {'#e': {request.event.id}},
      limit: 1,
    ),
    (previous, next) {
      if (next is StorageData && next.models.isNotEmpty) {
        final response = next.models.first;
        // Process individual response
        handleVerificationResponse(request, response);
      }
    },
  );
}
``` 