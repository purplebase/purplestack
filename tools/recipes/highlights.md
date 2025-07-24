# Highlights Recipe

Uses `Article` as example, but may be implemented in other nostr kinds.

## Highlight Card Widget

```dart
class HighlightCard extends ConsumerWidget {
  final Highlight highlight;
  final VoidCallback? onTap;

  const HighlightCard({super.key, required this.highlight, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author row
              Row(
                children: [
                  ProfileAvatar(profile: highlight.author.value, radius: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlight.author.value?.nameOrNpub ?? 'Anonymous',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.highlight, size: 16, color: Theme.of(context).colorScheme.primary),
                ],
              ),
              
              const SizedBox(height: 12),

              // Highlight content
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow.withValues(alpha: 0.3)),
                ),
                child: Text(
                  highlight.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              // Quote comment
              if (highlight.isQuote && highlight.quoteComment != null) ...[
                const SizedBox(height: 8),
                Text(highlight.quoteComment!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

## Highlightable Content Widget

```dart
class HighlightableContent extends HookConsumerWidget {
  final String content;
  final String? articleAddressableId;
  final MarkdownStyleSheet? styleSheet;

  const HighlightableContent({
    super.key,
    required this.content,
    this.articleAddressableId,
    this.styleSheet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedText = useState<String?>(null);

    // Query existing highlights
    final highlightsState = ref.watch(
      query<Highlight>(
        tags: articleAddressableId != null
            ? {'#a': {articleAddressableId!}}
            : {},
        source: LocalAndRemoteSource(),
      ),
    );

    final existingHighlights = switch (highlightsState) {
      StorageData(:final models) => models.map((h) => h.content.trim()).toList(),
      _ => <String>[],
    };

    return SelectionArea(
      onSelectionChanged: (selection) {
        selectedText.value = selection?.plainText.trim();
      },
      contextMenuBuilder: (context, selectableRegionState) {
        return _buildContextMenu(context, ref, selectableRegionState, selectedText.value);
      },
      child: MarkdownBody(
        data: _processContentWithHighlights(content, existingHighlights),
        styleSheet: (styleSheet ?? MarkdownStyleSheet()).copyWith(
          code: TextStyle(
            backgroundColor: Colors.yellow.withValues(alpha: 0.3),
            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
            fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  String _processContentWithHighlights(String content, List<String> highlights) {
    if (highlights.isEmpty) return content;
    
    String processed = content;
    for (final highlight in highlights..sort((a, b) => b.length.compareTo(a.length))) {
      if (highlight.isNotEmpty) {
        processed = processed.replaceAll(highlight, '`🟡$highlight🟡`');
      }
    }
    return processed;
  }

  Widget _buildContextMenu(
    BuildContext context,
    WidgetRef ref,
    SelectableRegionState selectableRegionState,
    String? selectedText,
  ) {
    final buttonItems = <ContextMenuButtonItem>[
      ContextMenuButtonItem(
        label: 'Copy',
        onPressed: () {
          if (selectedText != null) {
            Clipboard.setData(ClipboardData(text: selectedText));
          }
          selectableRegionState.hideToolbar();
        },
      ),
    ];

    if (selectedText != null && selectedText.isNotEmpty) {
      final signer = ref.read(Signer.activeSignerProvider);
      if (signer != null) {
        buttonItems.add(
          ContextMenuButtonItem(
            label: 'Highlight',
            onPressed: () {
              _createHighlight(context, ref, selectedText);
              selectableRegionState.hideToolbar();
            },
          ),
        );
      }
    }

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: selectableRegionState.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }

  Future<void> _createHighlight(BuildContext context, WidgetRef ref, String selectedText) async {
    try {
      final signer = ref.read(Signer.activeSignerProvider);
      if (signer == null) return;

      final highlight = PartialHighlight(selectedText.trim());
      
      if (articleAddressableId != null) {
        highlight.addArticleReference(articleAddressableId!);
      }

      final signedHighlight = await highlight.signWith(signer);
      await ref.storage.save({signedHighlight});
      await ref.storage.publish({signedHighlight});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✨ Highlight saved!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create highlight: $e')),
        );
      }
    }
  }
}
```

## Highlights Screen

```dart
class HighlightsScreen extends ConsumerWidget {
  const HighlightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePubkey = ref.watch(Signer.activePubkeyProvider);
    if (activePubkey == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Highlights')),
        body: const Center(child: Text('Sign in to view highlights')),
      );
    }

    final highlightsState = ref.watch(
      query<Highlight>(
        authors: {activePubkey},
        limit: 50,
        source: LocalAndRemoteSource(),
        and: (highlight) => {highlight.author},
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('My Highlights')),
      body: switch (highlightsState) {
        StorageLoading() => const Center(child: CircularProgressIndicator()),
        StorageError(:final exception) => Center(child: Text('Error: $exception')),
        StorageData(:final models) when models.isEmpty => const Center(
          child: Text('No highlights yet. Start highlighting content!'),
        ),
        StorageData(:final models) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: models.length,
          itemBuilder: (context, index) => HighlightCard(highlight: models[index]),
        ),
      },
    );
  }
}
```

## Integration with Article Detail

```dart
// In your ArticleDetailScreen, replace the content widget:
HighlightableContent(
  content: article.content,
  articleAddressableId: article.addressableId,
  styleSheet: MarkdownStyleSheet(/* your existing styles */),
)

// Add highlights section after content:
Widget _buildHighlightsSection(WidgetRef ref, Article article) {
  final highlightsState = ref.watch(
    query<Highlight>(
      tags: {'#a': {article.addressableId}},
      source: LocalAndRemoteSource(),
      and: (highlight) => {highlight.author},
    ),
  );

  return switch (highlightsState) {
    StorageData(:final models) when models.isNotEmpty => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Highlights (${models.length})', 
             style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...models.map((h) => HighlightCard(highlight: h)),
      ],
    ),
    _ => const SizedBox.shrink(),
  };
}
```

Remember to test the implementation thoroughly, especially the text selection and context menu functionality across different devices and screen sizes. The highlights feature should feel natural and intuitive while providing powerful functionality for content curation and sharing. 