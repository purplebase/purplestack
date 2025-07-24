# Signer Interface & Authentication

The signer system manages authentication and signing across your app.

## Basic Signer Setup

```dart
// Create a private key signer
final privateKey = 'your_private_key_here';
final signer = Bip340PrivateKeySigner(privateKey, ref);

// Sign in (sets the pubkey as active)
await signer.signIn();

// Check if signer is signed in and available for use
final isSignedIn = signer.isSignedIn;
final isAvailable = await signer.isAvailable;

// Watch the active profile (use RemoteSource() if you want to fetch from relays)
final activeProfile = ref.watch(Signer.activeProfileProvider(LocalSource()));
final activePubkey = ref.watch(Signer.activePubkeyProvider);
```

## Multiple Account Management

```dart
// Sign in multiple accounts
final signer1 = Bip340PrivateKeySigner(privateKey1, ref);
final signer2 = Bip340PrivateKeySigner(privateKey2, ref);

await signer1.signIn(setAsActive: false); // Don't set as active
await signer2.signIn(setAsActive: true);  // Set as active

// Switch between accounts
await signer1.setAsActivePubkey();
await signer2.removeAsActivePubkey();

// Get all signed-in accounts
final signedInPubkeys = ref.watch(Signer.signedInPubkeysProvider);
```

## Active Profile with Different Sources

```dart
// Get active profile from local storage only
final localProfile = ref.watch(Signer.activeProfileProvider(LocalSource()));

// Get active profile from local storage and relays
final fullProfile = ref.watch(Signer.activeProfileProvider(LocalAndRemoteSource()));

// Get active profile from specific relay group
final socialProfile = ref.watch(Signer.activeProfileProvider(
  RemoteSource(group: 'social'),
));
```

The [amber_signer](https://github.com/purplebase/amber_signer) package implements this interface for Amber / NIP-55.

## Sign Out Flow

```dart
// Clean up when user signs out
await signer.signOut();

// The active profile provider will automatically update
// as the signer is removed from the system
``` 