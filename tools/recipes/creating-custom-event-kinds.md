# Creating Custom Event Kinds

Extend the system with your own event kinds.

## Basic Custom Model

```dart
@GeneratePartialModel()
class Joke extends RegularModel<Joke> {
  Joke.fromMap(super.map, super.ref) : super.fromMap();
  
  String? get title => event.getFirstTagValue('title');
  String get punchline => event.content;
  DateTime? get publishedAt => 
      event.getFirstTagValue('published_at')?.toInt()?.toDate();
}

class PartialJoke extends RegularPartialModel<Joke> with PartialJokeMixin {
  PartialJoke({
    required String title,
    required String punchline,
    DateTime? publishedAt,
  }) {
    event.content = punchline;
    event.addTagValue('title', title);
    if (publishedAt != null) {
      event.addTagValue('published_at', publishedAt.toSeconds().toString());
    }
  }
}
```

## Registering Custom Kinds

```dart
// Create a custom initialization provider
final customInitializationProvider = FutureProvider((ref) async {
  await ref.read(initializationProvider(StorageConfiguration()).future);
  
  // Register your custom models
  Model.register(kind: 1055, constructor: Joke.fromMap);
  Model.register(kind: 1056, constructor: Meme.fromMap);
  
  return true;
});

// Use this provider instead of the default one
final initState = ref.watch(customInitializationProvider);
```

## Using Custom Models

```dart
// Create and sign a joke
final partialJoke = PartialJoke(
  title: 'The Time Traveler',
  punchline: 'I was going to tell you a joke about time travel... but you didn\'t like it.',
  publishedAt: DateTime.now(),
);

final signedJoke = await partialJoke.signWith(signer);

// Save to storage
await ref.storage.save({signedJoke});

// Query jokes
final jokesState = ref.watch(
  query<Joke>(
    authors: {signer.pubkey},
    limit: 10,
  ),
);
```

## Different Model Types

```dart
// Regular events (kind 1-9999)
class RegularEvent extends RegularModel<RegularEvent> {
  RegularEvent.fromMap(super.map, super.ref) : super.fromMap();
}

// Replaceable events (kind 0, 3, 10000-19999)
class ReplaceableEvent extends ReplaceableModel<ReplaceableEvent> {
  ReplaceableEvent.fromMap(super.map, super.ref) : super.fromMap();
}

// Parameterizable replaceable events (kind 30000-39999)
class ParameterizableEvent extends ParameterizableReplaceableModel<ParameterizableEvent> {
  ParameterizableEvent.fromMap(super.map, super.ref) : super.fromMap();
  
  String get identifier => event.identifier; // d-tag value
}

// Ephemeral events (kind 20000-29999)
class EphemeralEvent extends EphemeralModel<EphemeralEvent> {
  EphemeralEvent.fromMap(super.map, super.ref) : super.fromMap();
}
``` 