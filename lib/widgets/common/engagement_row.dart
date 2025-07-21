import 'package:flutter/material.dart';

class EngagementRow extends StatelessWidget {
  final int likesCount;
  final int repostsCount;
  final int zapsCount;
  final int zapsSatAmount;
  final int? commentsCount;
  final VoidCallback? onLike;
  final VoidCallback? onRepost;
  final VoidCallback? onZap;
  final VoidCallback? onComment;
  final bool isLiked;
  final bool isReposted;
  final bool isZapped;

  const EngagementRow({
    super.key,
    required this.likesCount,
    required this.repostsCount,
    required this.zapsCount,
    required this.zapsSatAmount,
    this.commentsCount,
    this.onLike,
    this.onRepost,
    this.onZap,
    this.onComment,
    this.isLiked = false,
    this.isReposted = false,
    this.isZapped = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // Likes
        _EngagementItem(
          icon: Icons.favorite,
          count: likesCount,
          onTap: onLike,
          isActive: isLiked,
          activeColor: Colors.red,
          theme: theme,
        ),

        const SizedBox(width: 24),

        // Reposts
        _EngagementItem(
          icon: Icons.repeat,
          count: repostsCount,
          onTap: onRepost,
          isActive: isReposted,
          activeColor: Colors.green,
          theme: theme,
        ),

        const SizedBox(width: 24),

        // Zaps
        _ZapItem(
          count: zapsCount,
          satAmount: zapsSatAmount,
          onTap: onZap,
          isActive: isZapped,
          theme: theme,
        ),

        // Comments (optional)
        if (commentsCount != null) ...[
          const SizedBox(width: 24),
          _EngagementItem(
            icon: Icons.mode_comment_outlined,
            count: commentsCount!,
            onTap: onComment,
            isActive: false,
            activeColor: colorScheme.primary,
            theme: theme,
          ),
        ],
      ],
    );
  }
}

class _EngagementItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onTap;
  final bool isActive;
  final Color activeColor;
  final ThemeData theme;

  const _EngagementItem({
    required this.icon,
    required this.count,
    required this.onTap,
    required this.isActive,
    required this.activeColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? activeColor
        : theme.colorScheme.onSurface.withOpacity(0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? icon : icon, size: 16, color: color),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(count),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _ZapItem extends StatelessWidget {
  final int count;
  final int satAmount;
  final VoidCallback? onTap;
  final bool isActive;
  final ThemeData theme;

  const _ZapItem({
    required this.count,
    required this.satAmount,
    required this.onTap,
    required this.isActive,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? Colors.orange
        : theme.colorScheme.onSurface.withOpacity(0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flash_on, size: 16, color: color),
            if (count > 0 || satAmount > 0) ...[
              const SizedBox(width: 4),
              Text(
                satAmount > 0 ? _formatSats(satAmount) : count.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatSats(int sats) {
    if (sats >= 1000000) {
      return '${(sats / 1000000).toStringAsFixed(1)}M';
    } else if (sats >= 1000) {
      return '${(sats / 1000).toStringAsFixed(1)}K';
    }
    return sats.toString();
  }
}
