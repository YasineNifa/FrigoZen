import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/models/activity_log.dart';
import 'package:frigo_zen/services/history_service.dart';
import 'package:frigo_zen/locator.dart';
import 'package:frigo_zen/screens/history/history_screen.dart';
import 'package:provider/provider.dart';
import 'package:frigo_zen/viewmodels/history_view_model.dart';
import 'package:frigo_zen/models/frigo_user.dart';

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
          child: Consumer<HistoryViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                 return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
              }
              
              if (vm.logs.isEmpty) {
                 return Center(
                   child: Text(
                     l10n.activityEmpty,
                     style: TextStyle(color: Colors.grey[400], fontSize: 12),
                   ),
                 );
              }

              final logs = vm.logs.take(5).toList(); // Show last 5 horizontally
              
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: logs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                   final log = logs[index];
                   final user = vm.getUser(log.userId);
                   return _MiniHistoryCard(log: log, user: user);
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
  final FrigoUser? user;
  
  const _MiniHistoryCard({required this.log, this.user});

  @override
  Widget build(BuildContext context) {
    // Fallbacks
    final displayName = user?.displayName ?? 'Utilisateur';
    final photoUrl = user?.photoURL;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

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
              image: photoUrl != null && photoUrl.isNotEmpty 
                  ? DecorationImage(
                      image: photoUrl.startsWith('http')
                        ? NetworkImage(photoUrl)
                        : AssetImage(photoUrl) as ImageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
               color: Colors.grey[100],
            ),
             child: (photoUrl == null || photoUrl.isEmpty) 
                 ? Center(child: Text(initial, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))
                 : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getActionText(AppLocalizations.of(context)!, displayName),
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

  String _getActionText(AppLocalizations l10n, String userName) {
     // Simplified text for mini card
     switch (log.type) {
      case ActivityType.addedShopping:
        return "$userName + ${log.itemName}";
      case ActivityType.bought:
        return "$userName -> ${log.itemName}";
      case ActivityType.consumed:
        return "$userName - ${log.itemName}";
      case ActivityType.trashed:
        return "$userName x ${log.itemName}";
    }
  }

  String _getTimeAgo() {
     final diff = DateTime.now().difference(log.timestamp);
     if (diff.inMinutes < 60) return "${diff.inMinutes}m";
     if (diff.inHours < 24) return "${diff.inHours}h";
     return "${diff.inDays}j";
  }
}
