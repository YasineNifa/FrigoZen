import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/models/activity_log.dart';
import 'package:frigo_zen/services/history_service.dart';
import 'package:frigo_zen/locator.dart';
import 'package:frigo_zen/screens/history/history_screen.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyService = locator<HistoryService>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.historyTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
                child: const Text("Voir tout"),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 90, // Fixed height for activity preview
          child: StreamBuilder<List<ActivityLog>>(
            stream: historyService.getHistoryStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                 return Center(
                   child: Text(
                     l10n.activityEmpty,
                     style: TextStyle(color: Colors.grey[400], fontSize: 12),
                   ),
                 );
              }

              final logs = snapshot.data!.take(5).toList(); // Show last 5 horizontally
              
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: logs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                   return _MiniHistoryCard(log: logs[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniHistoryCard extends StatelessWidget {
  final ActivityLog log;
  const _MiniHistoryCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: log.userAvatar.isNotEmpty 
                  ? DecorationImage(
                      image: log.userAvatar.startsWith('http')
                        ? NetworkImage(log.userAvatar)
                        : AssetImage(log.userAvatar) as ImageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
               color: Colors.grey[100],
            ),
             child: log.userAvatar.isEmpty 
                 ? Center(child: Text(log.userName.isNotEmpty ? log.userName[0] : '?', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))
                 : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getActionText(AppLocalizations.of(context)!),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _getTimeAgo(),
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getActionText(AppLocalizations l10n) {
     // Simplified text for mini card
     switch (log.type) {
      case ActivityType.addedShopping:
        return "${log.userName} + ${log.itemName}";
      case ActivityType.bought:
        return "${log.userName} -> ${log.itemName}";
      case ActivityType.consumed:
        return "${log.userName} - ${log.itemName}";
      case ActivityType.trashed:
        return "${log.userName} x ${log.itemName}";
    }
  }

  String _getTimeAgo() {
     final diff = DateTime.now().difference(log.timestamp);
     if (diff.inMinutes < 60) return "${diff.inMinutes}m";
     if (diff.inHours < 24) return "${diff.inHours}h";
     return "${diff.inDays}j";
  }
}
