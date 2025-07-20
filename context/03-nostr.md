## Nostr Protocol Integration

This project uses the `models` and `purplebase` packages which are the ONLY way to interact with the nostr network.

### Nostr Implementation Guidelines

- Always use the `mcp_nips_read_nips_index` tool before implementing any Nostr features to see what kinds are currently in use across all NIPs.
- If any existing kind or NIP might offer the required functionality, use the `mcp_nips_read_nip` tool to investigate thoroughly. Several NIPs may need to be read before making a decision.
- Only generate new kind numbers if no existing suitable kinds are found after comprehensive research.

Knowing when to create a new kind versus reusing an existing kind requires careful judgement. Introducing new kinds means the project won't be interoperable with existing clients. But deviating too far from the schema of a particular kind can cause different interoperability issues.

#### Choosing Between Existing NIPs and Custom Kinds

When implementing features that could use existing NIPs, follow this decision framework:

1. **Thorough NIP Review**: Before considering a new kind, always perform a comprehensive review of existing NIPs and their associated kinds. Use the `mcp_nips_read_nips_index` tool to get an overview, and then `mcp_nips_read_nip` and `mcp_nips_read_kind` to investigate any potentially relevant NIPs or kinds in detail. The goal is to find the closest existing solution.

2. **Prioritize Existing NIPs**: Always prefer extending or using existing NIPs over creating custom kinds, even if they require minor compromises in functionality.

3. **Interoperability vs. Perfect Fit**: Consider the trade-off between:
   - **Interoperability**: Using existing kinds means compatibility with other Nostr clients
   - **Perfect Schema**: Custom kinds allow perfect data modeling but create ecosystem fragmentation

4. **Extension Strategy**: When existing NIPs are close but not perfect:
   - Use the existing kind as the base
   - Add domain-specific tags for additional metadata
   - Document the extensions in `NIP.md`

5. **When to Generate Custom Kinds**:
   - No existing NIP covers the core functionality
   - The data structure is fundamentally different from existing patterns
   - The use case requires different storage characteristics (regular vs replaceable vs addressable)

6. **Custom Kind Publishing**: When publishing events with custom kinds, always include a NIP-31 "alt" tag with a human-readable description of the event's purpose.

**Example Decision Process**:
```
Need: Equipment marketplace for farmers
Options:
1. NIP-15 (Marketplace) - Too structured for peer-to-peer sales
2. NIP-99 (Classified Listings) - Good fit, can extend with farming tags
3. Custom kind - Perfect fit but no interoperability

Decision: Use NIP-99 + farming-specific tags for best balance
```

#### Tag Design Principles

When designing tags for Nostr events, follow these principles:

1. **Kind vs Tags Separation**:
   - **Kind** = Schema/structure (how the data is organized)
   - **Tags** = Semantics/categories (what the data represents)
   - Don't create different kinds for the same data structure

2. **Use Single-Letter Tags for Categories**:
   - **Relays only index single-letter tags** for efficient querying
   - Use `t` tags for categorization, not custom multi-letter tags
   - Multiple `t` tags allow items to belong to multiple categories

3. **Relay-Level Filtering**:
   - Design tags to enable efficient relay-level filtering with `#t: ["category"]`
   - Avoid client-side filtering when relay-level filtering is possible
   - Consider query patterns when designing tag structure

4. **Tag Examples**:
   ```json
   // ❌ Wrong: Multi-letter tag, not queryable at relay level
   ["product_type", "electronics"]
   
   // ✅ Correct: Single-letter tag, relay-indexed and queryable
   ["t", "electronics"]
   ["t", "smartphone"]
   ["t", "android"]
   ```

5. **Querying Best Practices**:
   ```dart
   // ❌ Inefficient: Get all events, filter in Dart
   final models = await ref.storage.query(RequestFilter(kinds: {30402}).toRequest());
   final filtered = models.filter((m) => m.event.containsTag('electronics'));
   
   // ✅ Efficient: Filter at relay level
   final models = await ref.storage.query(RequestFilter(kinds: {30402}, tags: {'#t': {'electronics'}}).toRequest());
   ```

#### `t` Tag Filtering for Community-Specific Content

For applications focused on a specific community or niche, you can use `t` tags to filter events for the target audience.

**When to Use:**
- ✅ Community apps: "farmers" → `t: "farming"`, "Poland" → `t: "poland"`
- ❌ Generic platforms: Twitter clones, general Nostr clients

**Implementation:**
```dart
// Publishing with community tag
final note = PartialNote("note", tags: {'farming'}).signWith(signer);
await ref.storage.publish([note]);

// Querying community content
final notes = await ref.storage.query(RequestFilter<Note>(tags: {'#t': {'farming'}}, limit: 20).toRequest());
```

### Kind Ranges

An event's kind number determines the event's behavior and storage characteristics:

- **Regular Events** (1000 ≤ kind < 10000): Expected to be stored by relays permanently. Used for persistent content like notes, articles, etc.
- **Replaceable Events** (10000 ≤ kind < 20000): Only the latest event per pubkey+kind combination is stored. Used for profile metadata, contact lists, etc.
- **Addressable Events** (30000 ≤ kind < 40000): Identified by pubkey+kind+d-tag combination, only latest per combination is stored. Used for articles, long-form content, etc.

Kinds below 1000 are considered "legacy" kinds, and may have different storage characteristics based on their kind definition. For example, kind 1 is regular, while kind 3 is replaceable.

See `models` package reference below for how to create and initialize events and custom events (models), and which class to inherit from (`RegularModel`, `ReplaceableModel`, etc).

### Content Field Design Principles

When designing new event kinds, the `content` field should be used for semantically important data that doesn't need to be queried by relays. **Structured JSON data generally shouldn't go in the content field** (kind 0 being an early exception).

#### Guidelines

- **Use content for**: Large text, freeform human-readable content, or existing industry-standard JSON formats (Tiled maps, FHIR, GeoJSON)
- **Use tags for**: Queryable metadata, structured data, anything that needs relay-level filtering
- **Empty content is valid**: Many events need only tags with `content: ""`
- **Relays only index tags**: If you need to filter by a field, it must be a tag

#### Example

**✅ Good - queryable data in tags:**
```json
{
  "kind": 30402,
  "content": "",
  "tags": [["d", "product-123"], ["title", "Camera"], ["price", "250"], ["t", "photography"]]
}
```

**❌ Bad - structured data in content:**
```json
{
  "kind": 30402,
  "content": "{\"title\":\"Camera\",\"price\":250,\"category\":\"photo\"}",
  "tags": [["d", "product-123"]]
}
```

### NIP.md

The file `NIP.md` (in the root folder of this project) is used to define a custom Nostr protocol document. If the file doesn't exist, it means this project doesn't have any custom kinds associated with it.

Whenever new kinds are generated, the `NIP.md` file in the project must be created or updated to document the custom event schema. Whenever the schema of one of these custom events changes, `NIP.md` must also be updated accordingly.

### The `query` provider

The `query` provider has a filter-like API for querying Nostr events.

```dart
import 'package:models/models.dart';

final state = ref.watch(query<Note>(authors: {pubkey1}, limit: 10, source: LocalAndRemoteSource()));
```

`query` takes an `and` operator which will instruct it to load relationships. If data is needed, it's always better to use a relationship than a separate query call.

**Do not call query**, especially with many relationships inside loops! If you need relationship loading, use `and` and loop there - it will have the chance to optimize data loading and relay requests.

See [#models 👯](#models-) reference below.

#### Efficient Query Design

**Critical**: Always minimize the number of separate queries to avoid rate limiting and improve performance. Combine related queries whenever possible.

**✅ Efficient - Single query with multiple kinds:**
```dart
ref.watch(queryKinds(kinds: {1, 6, 16}, authors: {pubkey1}, limit: 150));

// Separate by type in Dart
final notes = events.whereType<Note>();
final reposts = events.whereType<Repost>();
final genericReposts = events.whereType<GenericRepost>();
```

**❌ Inefficient - Multiple separate queries:**
```dart
ref.watch(query<Note>(authors: {pubkey1}));
ref.watch(query<Repost>(authors: {pubkey1}));
ref.watch(query<GenericRepost>(authors: {pubkey1}));
```

**Query Optimization Guidelines:**
1. **Combine kinds**: Use `kinds: [1, 6, 16]` instead of separate queries; if these are relationships then always use the `and` operator: `ref.watch(query<Profile>(authors: {pubkey1}, and: (p) => {p.notes, p.reposts}));`
2. **Use multiple filters**: When you need different tag filters, use multiple filter objects in a single query
3. **Adjust limits**: When combining queries, increase the limit appropriately
4. **Filter by querying local storage**: Querying local storage is cheap, make any kind of specific query there
5. **Consider relay capacity**: Each query consumes relay resources and may count against rate limits

### Displaying a profile

To display profile data for a user by their Nostr pubkey (such as an event author), use the `query<Profile>(authors: {pubkey1})`.

### Signing in a profile

Make sure to **always** use `amber_signer` package first, unless the user instructs to support signing in with nsec (`Bip340PrivateKeySigner`). All signer interfaces inherit from `Signer`.

The `Profile` class has all the necessary properties to display a profile in a widget.

Example:

```dart
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile =
        ref.watch(Signer.activeProfileProvider(RemoteSource(group: 'social')));
    final pubkey = ref.watch(Signer.activePubkeyProvider);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pubkey == null) ...[
            ElevatedButton(
              onPressed: () => ref.read(amberSignerProvider).initialize(),
              child: const Text('Sign In'),
            ),
          ] else ...[
            if (profile?.pictureUrl != null)
              CircleAvatar(backgroundImage: NetworkImage(profile!.pictureUrl!)),
            if (profile?.nameOrNpub != null) Text(profile!.nameOrNpub),
            Text(
                '${pubkey.substring(0, 8)}...${pubkey.substring(pubkey.length - 8)}'),
            ElevatedButton(
              onPressed: () => ref.read(amberSignerProvider).dispose(),
              child: const Text('Sign Out'),
            ),
          ],
        ],
      ),
    );
  }
}

final amberSignerProvider = Provider<AmberSigner>(AmberSigner.new);
```

See "Signer Interface & Authentication" in the [#models 👯](#models-) reference below for more.

### Publishing

To publish events, use `storage.publish(...)` in any callback.

### `npub`, `naddr`, and other Nostr addresses

Nostr defines a set of identifiers in NIP-19. Their prefixes:

- `npub`: public keys
- `nsec`: private keys
- `note`: note ids
- `nprofile`: a nostr profile
- `nevent`: a nostr event
- `naddr`: a nostr replaceable event coordinate
- `nrelay`: a nostr relay (deprecated)

All of these can be encoded/decoded via:
  - `Utils.encodeShareableIdentifier` and `Utils.decodeShareableIdentifier` (sealed class with correct types)
  - `Utils.encodeShareable` and `Utils.decodeShareable` (shortcuts for types that return the main value as String)

Always use valid pubkeys, `Utils.generate64Hex()` and other utils allow you to generate private keys, turn to nsec (`privkey.encodeShareable()`), public keys (`Utils.derivePubkey(privkey)`) etc; never use invalid pubkeys like "author-1" which will make relays fail.

For nostr-related utilities always look first in the `models` or `purplebase` packages, where they are likely available, before creating your own.

### Rendering entities in notes

Use `NoteParser.parse()` to automatically detect and render NIP-19 entities, media URLs, and links in note content:

```dart
import 'package:purplestack/utils/utils.dart';

// Basic usage with styling
NoteParser.parse(
  note.content,
  textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
  linkStyle: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
)

// With custom widget replacements
NoteParser.parse(
  note.content,
  textStyle: const TextStyle(fontSize: 16),
  onNip19Entity: (entity) {
    // Replace npub1..., note1..., nevent1... with custom widgets
    final decoded = Utils.decodeShareableIdentifier(entity);
    return switch (decoded) {
      ProfileData() => ProfileChip(pubkey: decoded.pubkey),
      EventData() => NotePreview(eventId: decoded.eventId),
      _ => null, // Falls back to styled text
    };
  },
  onMediaUrl: (url) => CachedNetworkImage(imageUrl: url, height: 200),
  onHttpUrl: (url) => LinkChip(url: url),
)
```

**Features:**
- Automatically detects `npub1...`, `note1...`, `nevent1...`, etc. (handles `nostr:` prefix)
- Identifies media URLs by file extension (jpg, png, mp4, etc.)
- Returns `RichText` with `WidgetSpan` for seamless text/widget mixing
- Validates NIP-19 entities using `Utils.decodeShareableIdentifier()`
- Graceful fallbacks when callbacks return `null`

#### Use in Filters

The base Nostr protocol uses hex string identifiers when filtering by event IDs and pubkeys. Nostr filters only accept hex strings.

```dart
// ❌ Wrong: naddr is not decoded
final models = await ref.storage.query(ids: {naddr});
```

Corrected example:

```dart
// Decode a NIP-19 identifier
final naddr = Utils.decodeShareableIdentifier(value);

// Optional: guard certain types (depending on the use-case)
if (naddr is! AddressData) {
  throw new Error('Unsupported Nostr identifier');
}

// ✅ Correct: naddr is expanded into the correct filter
final models = await ref.storage.query(
  kinds: {naddr.kind},
  authors: {naddr.author},
  tags: {'#d': {naddr.identifier}},
);
```

### Uploading Files on Nostr

TODO: Blossom interface in models, impl in purplebase (take from zapstore-cli)

To attach files to kind 1 events, each file's URL should be appended to the event's `content`, and an `imeta` tag should be added for each file. For kind 0 events, the URL by itself can be used in relevant fields of the JSON content.

### Nostr Encryption and Decryption

The `Signer` interface has methods for:

 - `nip04Encrypt`
 - `nip04Decrypt`
 - `nip44Encrypt`
 - `nip44Decrypt`

Signers can be obtained via the `signerProvider` family or `activeSignerProvider`.

The signer's nip44 methods handle all cryptographic operations internally, including key derivation and conversation key management, so you never need direct access to private keys. Always use the signer interface for encryption rather than requesting private keys from users, as this maintains security and follows best practices.

**NIP-04 Encryption Example:**
```dart
// Encrypt a message using NIP-04
final signer = ref.read(Signer.activeSignerProvider);
final recipientPubkey = 'npub1abc123...';

// Encrypt the message
final encryptedContent = await signer.nip04Encrypt(
  message: 'Hello, this is a secret message!',
  recipientPubkey: recipientPubkey,
);

// Create and sign the encrypted direct message
final dm = PartialDirectMessage.encrypted(
  encryptedContent: encryptedContent,
  receiver: recipientPubkey,
);

final signedDm = await dm.signWith(signer);
await ref.storage.save({signedDm});
```

**NIP-44 Encryption Example (Recommended):**
```dart
// Encrypt a message using NIP-44 (more secure)
final signer = ref.read(Signer.activeSignerProvider);
final recipientPubkey = 'npub1abc123...';

// Encrypt the message with NIP-44
final encryptedContent = await signer.nip44Encrypt(
  message: 'Hello, this is a secret message!',
  recipientPubkey: recipientPubkey,
);

// Create and sign the encrypted direct message
final dm = PartialDirectMessage.encrypted(
  encryptedContent: encryptedContent,
  receiver: recipientPubkey,
);

final signedDm = await dm.signWith(signer);
await ref.storage.save({signedDm});
```

**Decrypting Messages:**
```dart
// Query for encrypted messages
final dmsState = ref.watch(
  query<DirectMessage>(
    authors: {signer.pubkey},
    tags: {'#p': {recipientPubkey}},
  ),
);

// Decrypt messages in UI
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
        
        if (snapshot.hasError) {
          return ListTile(
            title: Text('Failed to decrypt'),
            subtitle: Text('Message may be corrupted or from different encryption method'),
          );
        }
        
        return ListTile(
          title: Text(snapshot.data ?? 'Empty message'),
          subtitle: Text(dm.createdAt.toString()),
        );
      },
    );
  }
}
```

**Key Differences:**
- **NIP-04**: Legacy encryption method, simpler but less secure
- **NIP-44**: Modern encryption with better security, forward secrecy, and metadata protection
- Always prefer NIP-44 for new applications unless compatibility with older clients is required

### Custom data

Any time you need to store custom data, use the `CustomData` model from the `models` package. Use `setProperty` to set tags, and feel free to use encryption as defined above for sensitive data (NWC strings, cashu tokens, for example).

### Rendering Rich Text Content

Nostr text notes (kind 1, 11, and 1111) have a plaintext `content` field that may contain URLs, hashtags, and Nostr URIs.

TODO: Implement small Flutter lib for this (take from minimal-sample-app)
