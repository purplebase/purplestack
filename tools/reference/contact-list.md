# ContactList Model

**Kind:** 3 (Replaceable Event)  
**NIP:** NIP-02  
**Class:** `ContactList extends ReplaceableModel<ContactList>`

## Overview

The ContactList model represents a user's social graph in the Nostr protocol - specifically who they follow. It's a replaceable event that contains a list of public keys the user follows, along with optional relay information for each contact.

## Properties

### Core Properties
- **`followingPubkeys: Set<String>`** - Set of public keys (hex format) that this user follows

## Relationships

### Direct Relationships
- **`following: HasMany<Profile>`** - Profile objects for all followed users
- **`followers: HasMany<Profile>`** - Profile objects for users following this account (currently null - requires reverse lookup)

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The profile that owns this contact list
- **`reactions: HasMany<Reaction>`** - Reactions to this contact list
- **`zaps: HasMany<Zap>`** - Zaps sent to this contact list
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this contact list
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this contact list

## Usage Examples

### Creating a Contact List

```dart
// Create a new contact list
final contactList = PartialContactList(
  followPubkeys: {
    'pubkey1hex...',
    'pubkey2hex...',
    'pubkey3hex...',
  },
);

final signedContactList = await contactList.signWith(signer);
await signedContactList.save();
```

### Adding and Removing Follows

```dart
// Load existing contact list
final existingContactList = await ref.storage.query(
  RequestFilter<ContactList>(
    authors: {signer.pubkey},
    limit: 1,
  ).toRequest(),
);

if (existingContactList.isNotEmpty) {
  // Convert to partial for editing
  final partialContactList = existingContactList.first.toPartial<PartialContactList>();
  
  // Add new follow
  partialContactList.addFollowingPubkey(newUserPubkey);
  
  // Or add by profile
  partialContactList.addFollow(newUserProfile);
  
  // Remove a follow
  partialContactList.removeFollowingPubkey(unfollowPubkey);
  
  // Or remove by profile
  partialContactList.removeFollow(unfollowProfile);
  
  // Sign and publish updated contact list
  final updatedContactList = await partialContactList.signWith(signer);
  await updatedContactList.publish();
}
```

### Querying Contact Lists

```dart
// Get a user's contact list
final contactListState = ref.watch(
  query<ContactList>(
    authors: {userPubkey},
    limit: 1,
    and: (contactList) => {
      contactList.following, // Load all followed profiles
    },
  ),
);

// Get contact lists that follow a specific user
final followersState = ref.watch(
  query<ContactList>(
    tags: {
      '#p': {targetUserPubkey},
    },
    and: (contactList) => {
      contactList.author, // Load the profile that owns each contact list
    },
  ),
);
```

### Working with Following Lists

```dart
// Access following relationships
final contactList = user.contactList.value;
if (contactList != null) {
  final followingProfiles = contactList.following.toList();
  
  print('Following ${followingProfiles.length} users:');
  for (final profile in followingProfiles) {
    print('- ${profile.nameOrNpub}');
  }
  
  // Check if following specific user
  final isFollowing = contactList.followingPubkeys.contains(targetPubkey);
  print('Following target user: $isFollowing');
}
```

### Social Graph Analysis

```dart
// Find mutual follows
Set<String> findMutualFollows(ContactList userContactList, ContactList otherContactList) {
  return userContactList.followingPubkeys.intersection(otherContactList.followingPubkeys);
}

// Get follow recommendations (people followed by people you follow)
final myContactList = await getContactList(myPubkey);
final myFollowing = myContactList.following.toList();

final recommendations = <String, int>{};
for (final followedProfile in myFollowing) {
  final theirContactList = followedProfile.contactList.value;
  if (theirContactList != null) {
    for (final theirFollow in theirContactList.followingPubkeys) {
      if (!myContactList.followingPubkeys.contains(theirFollow) && 
          theirFollow != myPubkey) {
        recommendations[theirFollow] = (recommendations[theirFollow] ?? 0) + 1;
      }
    }
  }
}

// Sort by recommendation score
final sortedRecommendations = recommendations.entries.toList()
  ..sort((a, b) => b.value.compareTo(a.value));
```

### Follow/Unfollow Operations

```dart
// Helper class for managing follows
class FollowManager {
  final Ref ref;
  final Signer signer;
  
  FollowManager(this.ref, this.signer);
  
  Future<void> followUser(String pubkey) async {
    final contactList = await _getCurrentContactList();
    final partialContactList = contactList?.toPartial<PartialContactList>() 
        ?? PartialContactList();
    
    partialContactList.addFollowingPubkey(pubkey);
    
    final signedContactList = await partialContactList.signWith(signer);
    await signedContactList.publish();
  }
  
  Future<void> unfollowUser(String pubkey) async {
    final contactList = await _getCurrentContactList();
    if (contactList == null) return;
    
    final partialContactList = contactList.toPartial<PartialContactList>();
    partialContactList.removeFollowingPubkey(pubkey);
    
    final signedContactList = await partialContactList.signWith(signer);
    await signedContactList.publish();
  }
  
  Future<ContactList?> _getCurrentContactList() async {
    final contactLists = await ref.storage.query(
      RequestFilter<ContactList>(
        authors: {signer.pubkey},
        limit: 1,
      ).toRequest(),
    );
    
    return contactLists.isNotEmpty ? contactLists.first : null;
  }
}
```

### Batch Operations

```dart
// Follow multiple users at once
Future<void> followMultipleUsers(List<String> pubkeys) async {
  final contactList = await getCurrentContactList();
  final partialContactList = contactList?.toPartial<PartialContactList>() 
      ?? PartialContactList();
  
  // Add all new follows
  for (final pubkey in pubkeys) {
    partialContactList.addFollowingPubkey(pubkey);
  }
  
  final signedContactList = await partialContactList.signWith(signer);
  await signedContactList.publish();
}
```

## Social Features

### Follower Count (Reverse Lookup)
```dart
// Count followers for a user (requires querying all contact lists)
Future<int> getFollowerCount(String pubkey) async {
  final followerContactLists = await ref.storage.query(
    RequestFilter<ContactList>(
      tags: {
        '#p': {pubkey},
      },
    ).toRequest(),
  );
  
  return followerContactLists.length;
}
```

### Social Graph Visualization
```dart
// Build a social graph for visualization
Map<String, Set<String>> buildSocialGraph(List<ContactList> contactLists) {
  final graph = <String, Set<String>>{};
  
  for (final contactList in contactLists) {
    final author = contactList.author.value?.pubkey;
    if (author != null) {
      graph[author] = contactList.followingPubkeys;
    }
  }
  
  return graph;
}
```

## Related Models

- **[Profile](profile.md)** - Users in the contact list and the list owner
- **[Note](note.md)** - Content from followed users appears in feeds

## Implementation Notes

- Contact lists are replaceable events (kind 3) - newer lists replace older ones
- Each followed user is represented by a `p` tag with their public key
- Optional relay information can be included in `p` tags for better connectivity
- The `followers` relationship is currently null as it requires reverse indexing
- Contact lists enable building social feeds and recommendation systems
- Privacy consideration: following lists are public by default 