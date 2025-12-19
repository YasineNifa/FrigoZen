import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frigo_zen/models/activity_log.dart';
import 'package:frigo_zen/models/frigo_user.dart';
import 'package:frigo_zen/services/history_service.dart';
import 'package:frigo_zen/services/household_service.dart';
import 'package:frigo_zen/services/auth_service.dart';
import 'package:frigo_zen/locator.dart';

class HistoryViewModel extends ChangeNotifier {
  final HistoryService _historyService;
  final HouseholdService _householdService = HouseholdService();

  List<ActivityLog> _logs = [];
  Map<String, FrigoUser> _members = {};
  bool _isLoading = true;
  final AuthService _authService = locator<AuthService>();
  StreamSubscription<List<ActivityLog>>? _historySubscription;
  StreamSubscription? _authSubscription;

  List<ActivityLog> get logs => _logs;
  Map<String, FrigoUser> get members => _members;
  bool get isLoading => _isLoading;

  HistoryViewModel() : _historyService = locator<HistoryService>() {
    _init();
  }

  void _init() {
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (user != null) {
        _subscribeToHistory();
      } else {
        _logs = [];
        _historySubscription?.cancel();
        notifyListeners();
      }
    });
  }
  
  StreamSubscription<List<FrigoUser>>? _membersSubscription;
  Set<String> _listeningUserIds = {};

  void _subscribeToHistory() {
    _isLoading = true;
    notifyListeners();
    
    _historySubscription?.cancel();
    _historySubscription = _historyService.getHistoryStream().listen((logs) {
      _logs = logs;
      _isLoading = false;
      notifyListeners();
      _updateMembersSubscription();
    });
  }

  void _updateMembersSubscription() {
    final userIds = _logs
        .map((log) => log.userId)
        .where((id) => id.isNotEmpty)
        .toSet();

    // If the set of users hasn't changed, we don't need to rebuild the stream
    // (Equality check for sets)
    if (userIds.length == _listeningUserIds.length && 
        userIds.containsAll(_listeningUserIds)) {
      return;
    }

    _listeningUserIds = userIds;
    _membersSubscription?.cancel();

    if (userIds.isNotEmpty) {
      _membersSubscription = _householdService
          .getHouseholdMembersStream(userIds.toList())
          .listen((users) {
        for (var user in users) {
          _members[user.id] = user;
        }
        notifyListeners();
      }, onError: (e) {
         debugPrint("Error listening to history members: $e");
      });
    }
  }

  FrigoUser? getUser(String userId) {
    return _members[userId];
  }

  // Legacy method kept for compatibility but effectively replaced by stream logic for internal use
  Future<void> _fetchMissingMembers() async {
     _updateMembersSubscription();
  }
  
  // Method specifically for spending analysis to get ALL relevant members
  Future<void> ensureMembersForIds(List<String> userIds) async {
     final missingIds = userIds
        .where((id) => id.isNotEmpty && !_members.containsKey(id))
        .toSet()
        .toList();
        
     if (missingIds.isNotEmpty) {
        final users = await _householdService.getHouseholdMembers(missingIds);
        for (var user in users) {
          _members[user.id] = user;
        }
        notifyListeners();
     }
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    _authSubscription?.cancel();
    _membersSubscription?.cancel();
    super.dispose();
  }
}
