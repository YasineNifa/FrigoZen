import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/models/activity_log.dart';
import 'package:frigo_zen/services/history_service.dart';
import 'package:frigo_zen/locator.dart';
import 'package:frigo_zen/theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyService = locator<HistoryService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
      ),
      body: StreamBuilder<List<ActivityLog>>(
        stream: historyService.getHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[300]),
                   const SizedBox(height: 16),
                   Text(
                     l10n.activityEmpty,
                     style: TextStyle(color: Colors.grey[500], fontSize: 16),
                   ),
                ],
              ),
            );
          }

          final logs = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _HistoryCard(log: logs[index]);
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ActivityLog log;

  const _HistoryCard({required this.log});

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      if (diff.inMinutes < 1) return l10n.timeJustNow;
      return l10n.timeMinutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24 && date.day == now.day) {
      final timeStr = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
      return l10n.timeTodayAt(timeStr);
    } else {
      final dateStr = "${date.day}/${date.month}";
      final timeStr = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
      return l10n.timeDateAt(dateStr, timeStr);
    }
  }

  Widget _buildAvatar(BuildContext context) {
    if (log.userAvatar.isEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[200],
        child: Text(
          log.userName.isNotEmpty ? log.userName[0].toUpperCase() : '?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: log.userAvatar.startsWith('http')
              ? NetworkImage(log.userAvatar)
              : AssetImage(log.userAvatar) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String _getDescription(BuildContext context, AppLocalizations l10n) {
    final userName = log.userName;
    final itemName = log.itemName;

    switch (log.type) {
      case ActivityType.addedShopping:
        return l10n.activityAddedShopping(itemName, userName);
      case ActivityType.bought:
        return l10n.activityBought(itemName, userName);
      case ActivityType.consumed:
        return l10n.activityConsumed(itemName, userName);
      case ActivityType.trashed:
        return l10n.activityTrashed(itemName, userName);
    }
  }

  IconData _getIcon() {
    switch (log.type) {
      case ActivityType.addedShopping:
        return Icons.add_shopping_cart;
      case ActivityType.bought:
        return Icons.shopping_bag;
      case ActivityType.consumed:
        return Icons.restaurant;
      case ActivityType.trashed:
        return Icons.delete_outline;
    }
  }
  
  Color _getColor() {
    switch (log.type) {
      case ActivityType.addedShopping:
        return Colors.blue;
      case ActivityType.bought:
        return Colors.green;
      case ActivityType.consumed:
        return Colors.orange;
      case ActivityType.trashed:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(context),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDescription(context, l10n),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                   _formatDate(log.timestamp, l10n),
                   style: TextStyle(
                     fontSize: 11,
                     color: Colors.grey[400],
                   ),
                ),
              ],
            ),
          ),
          Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: _getColor().withValues(alpha: 0.1),
               shape: BoxShape.circle,
             ),
             child: Icon(_getIcon(), size: 16, color: _getColor()),
          ),
        ],
      ),
    );
  }
}
