# Quickstart

Get started with a minimal Flutter/Riverpod app that shows a user's notes and replies.

## Complete Example

Here is a minimal Flutter/Riverpod app that shows a user's notes and replies.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart';

void main() => runApp(ProviderScope(child: MaterialApp(home: NotesScreen())));

class NotesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(initializationProvider(StorageConfiguration()))) {
      AsyncLoading() => Center(child: CircularProgressIndicator()),
      AsyncError() => Center(child: Text('Error initializing')),
      _ => Scaffold(
        body: Consumer(
          builder: (context, ref, _) {
            final activePubkey = ref.watch(Signer.activePubkeyProvider);
            if (activePubkey == null) {
              return Center(child: Text('Please sign in'));
            }
            
            final notesState = ref.watch(
              query<Note>(
                authors: {activePubkey},
                limit: 100,
                and: (note) => {
                  note.author,      // Include author profile
                  note.reactions,   // Include reactions
                  note.zaps,        // Include zaps
                  note.root,        // Include root note for replies
                  note.replies,     // Include direct replies
                },
              ),
            );
            
            return switch (notesState) {
              StorageLoading() => Center(child: CircularProgressIndicator()),
              StorageError() => Center(child: Text('Error loading notes')),
              StorageData() => ListView.builder(
                itemCount: notesState.models.length,
                itemBuilder: (context, index) {
                  final note = notesState.models[index];
                  return NoteCard(note: note);
                },
              ),
            };
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            final signer = ref.read(Signer.activeSignerProvider);
            if (signer != null) {
              final newNote = await PartialNote('Hello, nostr!').signWith(signer);
              await ref.storage.save({newNote});
            }
          },
        ),
      ),
    };
  }
}

class NoteCard extends StatelessWidget {
  final Note note;
  
  const NoteCard({required this.note, super.key});
  
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
            
            // Reply indicator
            if (note.root.value != null)
              Text('↳ Reply to ${note.root.value!.author.value?.nameOrNpub ?? 'Unknown'}'),
            
            // Engagement metrics
            Row(
              children: [
                Icon(Icons.favorite, size: 16),
                Text('${note.reactions.length}'),
                SizedBox(width: 16),
                Icon(Icons.flash_on, size: 16),
                Text('${note.zaps.length}'),
                SizedBox(width: 16),
                Icon(Icons.reply, size: 16),
                Text('${note.replies.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## Flutter Syntax Sugar (Optional)

For Flutter apps, you can add this extension for cleaner syntax:

```dart
extension WidgetRefStorage on WidgetRef {
  StorageNotifier get storage => read(storageNotifierProvider.notifier);
}
``` 