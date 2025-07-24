# Comment Model

**Kind:** 1111 (Regular Event)  
**NIP:** NIP-22  
**Class:** `Comment extends RegularModel<Comment>`

## Overview

The Comment model represents structured comments on various types of content in the Nostr protocol. Unlike simple note replies, comments provide a more formal way to respond to long-form articles, files, and other non-text-note content with clear parent-child relationships and support for external content references.

## Properties

### Core Properties
- **`content: String`** - The text content of the comment

### Content References
- **`externalRootUri: String?`** - External URI of the root content being commented on
- **`externalParentUri: String?`** - External URI of the parent content
- **`rootKind: int?`** - Event kind of the root content
- **`parentKind: int?`** - Event kind of the parent content

## Relationships

### Direct Relationships
- **`rootModel: BelongsTo<Model>`** - The root content being commented on
- **`parentModel: BelongsTo<Model>`** - The immediate parent content
- **`quotedModel: BelongsTo<Model>`** - Content being quoted in the comment
- **`rootAuthor: BelongsTo<Profile>`** - Author of the root content
- **`parentAuthor: BelongsTo<Profile>`** - Author of the parent content
- **`replies: HasMany<Comment>`** - Replies to this comment

### Inherited Relationships
- **`author: BelongsTo<Profile>`** - The profile that wrote this comment
- **`reactions: HasMany<Reaction>`** - Reactions to this comment
- **`zaps: HasMany<Zap>`** - Zaps sent to this comment
- **`targetedPublications: HasMany<TargetedPublication>`** - Publications targeting this comment
- **`genericReposts: HasMany<GenericRepost>`** - Reposts of this comment

## Usage Examples

### Commenting on Articles

```dart
// Comment on a long-form article
final partialComment = PartialComment(
  content: 'Excellent analysis! I particularly enjoyed the section on Lightning Network adoption.',
  rootModel: article, // The article being commented on
  parentModel: article, // Same as root for top-level comments
);

final signedComment = await partialComment.signWith(signer);
await signedComment.publish();
```

### Replying to Comments

```dart
// Reply to an existing comment
final partialReply = PartialComment(
  content: 'I agree with your point about network effects, but what about privacy concerns?',
  rootModel: originalArticle, // Always reference the root
  parentModel: existingComment, // The comment being replied to
);

final signedReply = await partialReply.signWith(signer);
await signedReply.publish();
```

### Commenting on External Content

```dart
// Comment on external content (not on Nostr)
final partialComment = PartialComment(
  content: 'This GitHub issue perfectly explains the problem we discussed.',
  externalRootUri: 'https://github.com/nostr-protocol/nostr/issues/123',
  externalParentUri: 'https://github.com/nostr-protocol/nostr/issues/123',
);

final signedComment = await partialComment.signWith(signer);
await signedComment.publish();
```

### Querying Comments

```dart
// Get all comments on a specific article
final articleCommentsState = ref.watch(
  query<Comment>(
    tags: {
      '#a': {articleId}, // For replaceable events
      '#e': {articleId}, // For regular events
    },
    and: (comment) => {
      comment.author,
      comment.parentAuthor,
      comment.replies,
    },
  ),
);

// Get comment thread (replies to a specific comment)
final commentThreadState = ref.watch(
  query<Comment>(
    tags: {
      '#e': {commentId},
    },
    kinds: {1111},
    and: (comment) => {
      comment.author,
      comment.replies,
    },
  ),
);

// Get recent comments by a user
final userCommentsState = ref.watch(
  query<Comment>(
    authors: {userPubkey},
    limit: 50,
    and: (comment) => {
      comment.rootModel,
      comment.parentModel,
    },
  ),
);
```

### Building Comment Threads

```dart
class CommentThread extends StatelessWidget {
  final Model rootContent;
  
  const CommentThread({required this.rootContent});
  
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final commentsState = ref.watch(
          query<Comment>(
            tags: rootContent is ReplaceableModel
              ? {'#a': {rootContent.id}}
              : {'#e': {rootContent.id}},
            and: (comment) => {
              comment.author,
              comment.replies,
            },
          ),
        );
        
        return commentsState.when(
          data: (comments) => CommentList(
            comments: _buildCommentTree(comments),
            rootContent: rootContent,
          ),
          loading: () => CircularProgressIndicator(),
          error: (error, _) => Text('Error loading comments: $error'),
        );
      },
    );
  }
  
  List<CommentNode> _buildCommentTree(List<Comment> comments) {
    final commentMap = <String, Comment>{};
    final rootComments = <CommentNode>[];
    
    // First pass: create map of all comments
    for (final comment in comments) {
      commentMap[comment.id] = comment;
    }
    
    // Second pass: build tree structure
    for (final comment in comments) {
      final parentModel = comment.parentModel.value;
      
      if (parentModel is Comment && commentMap.containsKey(parentModel.id)) {
        // This is a reply to another comment
        // Add to parent's replies (handled by relationship)
      } else if (parentModel?.id == rootContent.id) {
        // This is a top-level comment on the root content
        rootComments.add(CommentNode(
          comment: comment,
          replies: _getReplies(comment, commentMap),
        ));
      }
    }
    
    return rootComments;
  }
  
  List<CommentNode> _getReplies(Comment parent, Map<String, Comment> commentMap) {
    return parent.replies.toList()
      .map((reply) => CommentNode(
        comment: reply,
        replies: _getReplies(reply, commentMap),
      ))
      .toList();
  }
}

class CommentNode {
  final Comment comment;
  final List<CommentNode> replies;
  
  CommentNode({required this.comment, required this.replies});
}
```

### Comment Display Widget

```dart
class CommentCard extends StatelessWidget {
  final Comment comment;
  final int depth;
  final VoidCallback? onReply;
  
  const CommentCard({
    required this.comment,
    this.depth = 0,
    this.onReply,
  });
  
  @override
  Widget build(BuildContext context) {
    final author = comment.author.value;
    final parentAuthor = comment.parentAuthor.value;
    
    return Container(
      margin: EdgeInsets.only(left: depth * 16.0, bottom: 8),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author and context info
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: author?.pictureUrl != null
                      ? NetworkImage(author!.pictureUrl!)
                      : null,
                    child: author?.pictureUrl == null
                      ? Text(author?.nameOrNpub[0] ?? '?')
                      : null,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author?.nameOrNpub ?? 'Unknown',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (parentAuthor != null && depth > 0)
                          Text(
                            'replying to ${parentAuthor.nameOrNpub}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    formatTimestamp(comment.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Comment content
              Text(comment.content),
              
              SizedBox(height: 8),
              
              // Action buttons
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite_border, size: 16),
                    onPressed: () => _reactToComment(comment),
                  ),
                  Text('${comment.reactions.length}'),
                  SizedBox(width: 16),
                  if (onReply != null)
                    IconButton(
                      icon: Icon(Icons.reply, size: 16),
                      onPressed: onReply,
                    ),
                  SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.flash_on, size: 16),
                    onPressed: () => _zapComment(comment),
                  ),
                  Text('${comment.zaps.length}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _reactToComment(Comment comment) {
    // Implement reaction functionality
  }
  
  void _zapComment(Comment comment) {
    // Implement zap functionality
  }
}
```

### Comment Moderation

```dart
class CommentModerator {
  final Ref ref;
  final Signer moderatorSigner;
  
  CommentModerator(this.ref, this.moderatorSigner);
  
  // Check if user can moderate comments on this content
  bool canModerate(Model rootContent) {
    return rootContent.author.value?.pubkey == moderatorSigner.pubkey;
  }
  
  // Remove inappropriate comment
  Future<void> removeComment(Comment comment, String reason) async {
    final rootContent = comment.rootModel.value;
    if (rootContent == null || !canModerate(rootContent)) {
      throw Exception('Not authorized to moderate comments on this content');
    }
    
    final deletionEvent = PartialDeletion(
      eventIds: {comment.id},
      reason: reason,
    );
    
    final signedDeletion = await deletionEvent.signWith(moderatorSigner);
    await signedDeletion.publish();
  }
  
  // Auto-moderation based on content
  bool shouldAutoModerate(Comment comment) {
    final content = comment.content.toLowerCase();
    
    // Check for spam indicators
    if (content.length < 10 || 
        content.contains('buy now') ||
        RegExp(r'https?://').allMatches(content).length > 3) {
      return true;
    }
    
    return false;
  }
}
```

### Comment Analytics

```dart
class CommentAnalytics {
  static Map<String, dynamic> analyzeComments(List<Comment> comments) {
    final now = DateTime.now();
    
    // Time-based analysis
    final recent = comments.where((c) => 
      c.createdAt.isAfter(now.subtract(Duration(days: 7))));
    
    // Thread depth analysis
    final threadDepths = <String, int>{};
    for (final comment in comments) {
      threadDepths[comment.id] = _calculateThreadDepth(comment, comments);
    }
    
    final maxDepth = threadDepths.values.isEmpty ? 0 : threadDepths.values.reduce(math.max);
    final avgDepth = threadDepths.values.isEmpty 
      ? 0.0 
      : threadDepths.values.reduce((a, b) => a + b) / threadDepths.length;
    
    // Author analysis
    final authorCounts = <String, int>{};
    for (final comment in comments) {
      final authorPubkey = comment.author.value?.pubkey ?? 'unknown';
      authorCounts[authorPubkey] = (authorCounts[authorPubkey] ?? 0) + 1;
    }
    
    return {
      'total_comments': comments.length,
      'recent_comments': recent.length,
      'max_thread_depth': maxDepth,
      'average_thread_depth': avgDepth,
      'unique_commenters': authorCounts.length,
      'top_commenters': authorCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        .take(5)
        .map((e) => {'pubkey': e.key, 'comment_count': e.value})
        .toList(),
    };
  }
  
  static int _calculateThreadDepth(Comment comment, List<Comment> allComments) {
    var depth = 0;
    var current = comment;
    
    while (true) {
      final parent = current.parentModel.value;
      if (parent is! Comment) break;
      
      final parentComment = allComments.firstWhereOrNull((c) => c.id == parent.id);
      if (parentComment == null) break;
      
      depth++;
      current = parentComment;
    }
    
    return depth;
  }
}
```

## Content Guidelines

### Comment Quality
- Provide substantive, thoughtful responses
- Stay relevant to the original content
- Use proper formatting and grammar
- Avoid excessive quoting

### Thread Etiquette
- Keep nested replies focused
- Don't hijack comment threads
- Acknowledge previous commenters when appropriate
- Use external references sparingly

## Related Models

- **[Article](article.md)** - Long-form content that can be commented on
- **[Note](note.md)** - Notes that can receive comments
- **[Profile](profile.md)** - Comment authors and content creators
- **[Reaction](reaction.md)** - Reactions to comments
- **[Zap](zap.md)** - Lightning payments to comments

## Implementation Notes

- Comments use regular events (kind 1111) following NIP-22
- Support both Nostr content and external URIs as comment targets
- Use `A` tags for replaceable events, `E` tags for regular events
- Parent-child relationships enable threaded discussions
- Comments can reference external content via URI tags
- Moderation is typically handled by the content author
- Thread depth should be limited to maintain readability 