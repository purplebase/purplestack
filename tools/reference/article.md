# Article Model

**Kind:** 30023 (Parameterizable Replaceable Event)  
**NIP:** NIP-23  
**Class:** `Article extends ParameterizableReplaceableModel<Article>`

## Overview

The Article model represents long-form content in the Nostr protocol. Articles are parameterizable replaceable events, meaning multiple articles can exist from the same author, identified by unique slug/identifier values. They support rich metadata, content highlighting, and various forms of engagement.

## Properties

### Core Properties
- **`title: String?`** - Article title
- **`content: String`** - Full article content (markdown supported)
- **`slug: String`** - Unique identifier/slug for the article (from `d` tag)
- **`summary: String?`** - Brief description or excerpt
- **`imageUrl: String?`** - Featured image URL
- **`publishedAt: DateTime?`** - Publication timestamp

## Relationships

### Direct Relationships
- **`highlights: HasMany<Highlight>`** - Text highlights made on this article
- **`reposts: HasMany<GenericRepost>`** - Reposts of this article

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The profile that authored this article
- **`reactions: HasMany<Reaction>`** - Reactions to this article
- **`zaps: HasMany<Zap>`** - Lightning payments to this article
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this article
- **`genericReposts: HasMany<GenericRepost>`** - Generic reposts of this article

## Usage Examples

### Creating an Article

```dart
final partialArticle = PartialArticle(
  title: 'Understanding Nostr: A Decentralized Social Protocol',
  content: '''
# Introduction

Nostr (Notes and Other Stuff Transmitted by Relays) is a simple, open protocol 
that enables global, decentralized, and censorship-resistant social media.

## Key Features

- **Decentralized**: No central authority or server
- **Censorship-resistant**: Content lives on multiple relays
- **Simple**: Minimal protocol complexity
- **Extensible**: Easy to add new event types

## How It Works

Nostr uses cryptographic key pairs for identity...
  ''',
  slug: 'understanding-nostr-protocol',
  summary: 'An introduction to the Nostr protocol and its key benefits for decentralized social media.',
  imageUrl: 'https://example.com/nostr-cover.jpg',
  publishedAt: DateTime.now(),
);

final signedArticle = await partialArticle.signWith(signer);
await signedArticle.publish();
```

### Querying Articles

```dart
// Get articles from specific authors
final articlesState = ref.watch(
  query<Article>(
    authors: {authorPubkey},
    limit: 10,
    and: (article) => {
      article.author,
      article.highlights,
      article.reactions,
    },
  ),
);

// Get a specific article by slug and author
final specificArticleState = ref.watch(
  query<Article>(
    authors: {authorPubkey},
    tags: {
      '#d': {'understanding-nostr-protocol'},
    },
    limit: 1,
  ),
);

// Get recently published articles
final recentArticlesState = ref.watch(
  query<Article>(
    since: DateTime.now().subtract(Duration(days: 7)),
    limit: 20,
    and: (article) => {
      article.author,
    },
  ),
);
```

### Working with Article Content

```dart
// Display article with metadata
Widget buildArticleView(Article article) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Featured image
      if (article.imageUrl != null)
        Image.network(article.imageUrl!),
      
      // Title
      Text(
        article.title ?? 'Untitled',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      
      // Author and date
      Row(
        children: [
          Text('By ${article.author.value?.nameOrNpub ?? 'Unknown'}'),
          if (article.publishedAt != null) ...[
            Text(' • '),
            Text(formatDate(article.publishedAt!)),
          ],
        ],
      ),
      
      // Summary
      if (article.summary != null)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            article.summary!,
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ),
      
      // Content (render markdown)
      MarkdownBody(data: article.content),
      
      // Engagement stats
      Row(
        children: [
          Text('${article.reactions.length} reactions'),
          SizedBox(width: 16),
          Text('${article.zap.length} zaps'),
          SizedBox(width: 16),
          Text('${article.highlights.length} highlights'),
        ],
      ),
    ],
  );
}
```

### Article Discovery

```dart
// Search articles by content
final searchResults = ref.watch(
  query<Article>(
    search: 'bitcoin lightning',
    limit: 20,
    and: (article) => {
      article.author,
    },
  ),
);

// Get articles with specific topics (using hashtags)
final topicArticles = ref.watch(
  query<Article>(
    tags: {
      '#t': {'nostr', 'decentralization'},
    },
    limit: 15,
    and: (article) => {
      article.author,
      article.reactions,
    },
  ),
);

// Get trending articles (by engagement)
final trendingArticles = ref.watch(
  query<Article>(
    since: DateTime.now().subtract(Duration(days: 3)),
    limit: 50,
    and: (article) => {
      article.reactions,
      article.zaps,
      article.author,
    },
    where: (article) {
      // Filter for high engagement
      final reactionCount = article.reactions.length;
      final zapCount = article.zaps.length;
      return reactionCount + zapCount * 2 > 10; // Weight zaps more
    },
  ),
);
```

### Updating Articles

```dart
// Update an existing article
final existingArticle = await ref.storage.get<Article>(articleId);
final updatedArticle = PartialArticle(
  title: existingArticle.title,
  content: '${existingArticle.content}\n\n## Update\n\nAdded new section...',
  slug: existingArticle.slug,
  summary: existingArticle.summary,
  imageUrl: existingArticle.imageUrl,
  publishedAt: existingArticle.publishedAt,
);

final signedUpdate = await updatedArticle.signWith(signer);
await signedUpdate.publish();
```

### Article Collections

```dart
// Create a series or collection
final articles = [
  'nostr-basics',
  'nostr-relays',
  'nostr-clients',
  'nostr-future',
];

// Query entire series
final seriesState = ref.watch(
  query<Article>(
    authors: {authorPubkey},
    tags: {
      '#d': articles.toSet(),
    },
    and: (article) => {
      article.author,
    },
  ),
);

// Sort by publication date
final sortedSeries = seriesState.when(
  data: (articles) {
    final sorted = articles.toList()
      ..sort((a, b) {
        final aDate = a.publishedAt ?? a.createdAt;
        final bDate = b.publishedAt ?? b.createdAt;
        return aDate.compareTo(bDate);
      });
    return sorted;
  },
  loading: () => <Article>[],
  error: (_, __) => <Article>[],
);
```

## Content Guidelines

### Markdown Support
Articles support markdown formatting:
```dart
final content = '''
# Main Title

## Section Header

**Bold text** and *italic text*

- Bullet points
- Are supported

1. Numbered lists
2. Work too

> Block quotes for emphasis

\`Code snippets\` and code blocks:

```dart
final example = 'Dart code';
\```

Links: [Nostr Protocol](https://github.com/nostr-protocol/nostr)
''';
```

### Tags and Topics
```dart
// Add topic tags for discoverability
final articleWithTags = PartialArticle(
  // ... other properties
  hashtags: {'nostr', 'decentralization', 'social-media'},
);
```

### SEO and Metadata
```dart
// Rich metadata for better discovery
final wellStructuredArticle = PartialArticle(
  title: 'Clear, Descriptive Title',
  summary: 'Compelling summary that explains the value proposition',
  imageUrl: 'https://example.com/engaging-cover-image.jpg',
  content: content,
  slug: 'clear-descriptive-url-slug',
  publishedAt: DateTime.now(),
);
```

## Related Models

- **[Profile](profile.md)** - Article authors
- **[Highlight](highlight.md)** - Text highlights made on articles
- **[Reaction](reaction.md)** - Reader reactions to articles
- **[Zap](zap.md)** - Lightning payments to articles
- **[GenericRepost](generic-repost.md)** - Article shares and reposts
- **[Comment](comment.md)** - Comments on articles (NIP-22)

## Implementation Notes

- Articles use parameterizable replaceable events (kind 30023)
- The `d` tag contains the article slug/identifier
- Multiple articles per author are supported via unique `d` tag values
- Content should be formatted in markdown for consistent rendering
- The `published_at` tag allows backdating articles
- Articles can be updated by publishing new versions with the same `d` tag
- Rich metadata improves discoverability and social sharing 