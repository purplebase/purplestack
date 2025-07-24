# Profile Model

**Kind:** 0 (Replaceable Event)  
**NIP:** NIP-01  
**Class:** `Profile extends ReplaceableModel<Profile>`

## Overview

The Profile model represents a user's profile information in the Nostr protocol. It contains metadata such as display name, bio, profile picture, and other identifying information. Profile events are replaceable, meaning newer profile events from the same author replace older ones.

## Properties

### Core Properties
- **`pubkey: String`** - The user's public key (hexadecimal)
- **`npub: String`** - The user's public key in bech32 format (npub...)
- **`nameOrNpub: String`** - Returns name if available, otherwise npub

### Profile Metadata
- **`name: String?`** - Display name or username
- **`nip05: String?`** - NIP-05 internet identifier (user@domain.com)
- **`pictureUrl: String?`** - Profile picture URL
- **`lud16: String?`** - Lightning address for payments
- **`about: String?`** - Bio/description text
- **`banner: String?`** - Banner image URL
- **`website: String?`** - Personal website URL
- **`birthday: DateTime?`** - User's birthday

### External Identities (NIP-39)
- **`externalIdentities: Set<(String, String)>`** - Set of (platform, proofUrl) tuples for verified external accounts

## Relationships

### Direct Relationships
- **`notes: HasMany<Note>`** - All notes authored by this profile
- **`contactList: BelongsTo<ContactList>`** - The profile's contact/following list

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - Self-reference (profiles are authored by themselves)
- **`reactions: HasMany<Reaction>`** - Reactions to this profile
- **`zaps: HasMany<Zap>`** - Zaps sent to this profile
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this profile
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this profile

## Usage Examples

### Creating a Profile

```dart
final partialProfile = PartialProfile(
  name: 'Alice Smith',
  about: 'Nostr enthusiast and developer',
  pictureUrl: 'https://example.com/alice.jpg',
  nip05: 'alice@example.com',
  lud16: 'alice@wallet.example.com',
  website: 'https://alice.dev',
  externalIdentities: {
    ('github', 'https://github.com/alice'),
    ('twitter', 'https://twitter.com/alice'),
  },
);

final signedProfile = await partialProfile.signWith(signer);
await signedProfile.save();
```

### Querying Profiles

```dart
// Get a specific profile by pubkey
final profileState = ref.watch(
  query<Profile>(
    authors: {userPubkey},
    limit: 1,
  ),
);

// Load profile with relationships
final profileWithData = ref.watch(
  query<Profile>(
    authors: {userPubkey},
    and: (profile) => {
      profile.notes,
      profile.contactList,
    },
  ),
);
```

### Loading from NIP-05

```dart
// Resolve NIP-05 address to Profile
final profile = await Profile.fromNip05('user@domain.com', ref);
if (profile != null) {
  print('Found profile: ${profile.nameOrNpub}');
}
```

### Lightning Invoice Generation

```dart
// Generate Lightning invoice for this profile
final invoice = await profile.createLightningInvoice(
  amountSats: 1000,
  comment: 'Thanks for the great content!',
);
if (invoice != null) {
  // Use the BOLT11 invoice
  print('Invoice: $invoice');
}
```

### Updating Profile

```dart
// Load existing profile and update
final existingProfile = await ref.storage.get<Profile>(pubkey);
final updatedProfile = existingProfile.copyWith(
  about: 'Updated bio text',
  website: 'https://newsite.com',
);

final partialProfile = PartialProfile(
  name: updatedProfile.name,
  about: updatedProfile.about,
  pictureUrl: updatedProfile.pictureUrl,
  // ... other properties
);

final signedProfile = await partialProfile.signWith(signer);
await signedProfile.publish();
```

## Related Models

- **[Note](note.md)** - Text posts authored by this profile
- **[ContactList](contact-list.md)** - Following/followers list
- **[Reaction](reaction.md)** - Reactions to profile events
- **[Zap](zap.md)** - Lightning payments to this profile

## Implementation Notes

- Profile events are replaceable (kind 0), so only the latest profile from each pubkey is kept
- The `processMetadata()` method handles parsing of complex JSON metadata from the event content
- NIP-05 verification requires DNS resolution and may be cached
- Lightning address (lud16) integration follows the Lightning Address specification
- External identities (NIP-39) provide verifiable links to other platforms 