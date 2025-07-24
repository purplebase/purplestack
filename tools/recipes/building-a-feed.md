# Building a Feed

Create a reactive feed that updates in real-time.

## Home Feed with Relationships

```dart
class HomeFeed extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(Signer.activeProfileProvider(LocalSource()));
    
    if (activeProfile == null) {
      return Center(child: Text('Please sign in'));
    }
    
    // Get following pubkeys from contact list
    final following = activeProfile.contactList.value?.followingPubkeys ?? {};
    
    final feedState = ref.watch(
      query<Note>(
        authors: following,
        limit: 50,
        and: (note) => {
          note.author,           // Include author profile
          note.reactions,        // Include reactions
          note.zaps,            // Include zaps
          note.root,            // Include root note for replies
        },
      ),
    );
    
    return switch (feedState) {
      StorageLoading() => Center(child: CircularProgressIndicator()),
      StorageError() => Center(child: Text('Error loading feed')),
      StorageData() => ListView.builder(
        itemCount: feedState.models.length,
        itemBuilder: (context, index) {
          final note = feedState.models[index];
          return FeedItemCard(note: note);
        },
      ),
    };
  }
}

class FeedItemCard extends StatelessWidget {
  final Note note;
  
  const FeedItemCard({required this.note, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    note.author.value?.pictureUrl ?? '',
                  ),
                ),
                SizedBox(width: 8),
                Text(note.author.value?.nameOrNpub ?? 'Unknown'),
              ],
            ),
            SizedBox(height: 8),
            
            // Note content
            Text(note.content),
            SizedBox(height: 8),
            
            // Engagement metrics
            Row(
              children: [
                Icon(Icons.favorite, size: 16),
                Text('${note.reactions.length}'),
                SizedBox(width: 16),
                Icon(Icons.flash_on, size: 16),
                Text('${note.zaps.length}'),
                SizedBox(width: 16),
                Text(note.createdAt.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## Real-time Updates

```dart
// The feed automatically updates when new notes arrive
// thanks to the reactive query system

// You can also manually trigger updates
final storage = ref.read(storageNotifierProvider.notifier);

// Save a new note and it will appear in the feed
final newNote = await PartialNote('Hello, world!').signWith(signer);
await storage.save({newNote});
``` 