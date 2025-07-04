import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

class TeamProvider extends ChangeNotifier {
  final Client client;
  final Teams teams;
  final Functions functions;

  models.Team? _currentTeam;
  bool _isLoading = false;
  String? _error;

  TeamProvider({required this.client})
    : teams = Teams(client),
      functions = Functions(client) {
    _loadCurrentTeam();
  }

  models.Team? get currentTeam => _currentTeam;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasTeam => _currentTeam != null;

  String get teamName => _currentTeam?.prefs.data['teamName'] ?? 'No Team';

  int get teamNumber => _currentTeam?.prefs.data['teamNumber'] ?? 0;

  /// Centralized error handling method.
  void _handleError(dynamic error, String operation) {
    _error = error.toString();
    debugPrint('$operation: $_error');
  }

  /// Sets the loading state and notifies listeners.
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  Future<void> _loadCurrentTeam() async {
    _setLoading(true);
    try {
      final teamsList = await teams.list();
      if (teamsList.teams.isNotEmpty) {
        _currentTeam = teamsList.teams.first;
      } else {
        _currentTeam = null;
        throw Exception('No teams found for current user');
      }
    } catch (e) {
      _handleError(e, 'Failed to load current team');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTeam({
    required String teamName,
    required int teamNumber,
    List<String> roles = const ['owner'],
  }) async {
    _setLoading(true);
    try {
      final String id = ID.unique();
      // Create team and set preferences in a single atomic operation
      final team = await teams.create(
        teamId: id,
        name: teamNumber.toString(),
        roles: roles,
      );
      await teams.updatePrefs(
        teamId: id,
        prefs: {'teamName': teamName, 'teamNumber': teamNumber},
      );
      _currentTeam = await teams.get(teamId: id);
      return true;
    } catch (e) {
      _handleError(e, 'Failed to create team');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> getTeam(String teamId) async {
    _setLoading(true);
    try {
      _currentTeam = await teams.get(teamId: teamId);
      return true;
    } catch (e) {
      _handleError(e, 'Failed to get team');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCurrentTeam() async {
    _setLoading(true);
    try {
      if (_currentTeam != null) {
        await teams.delete(teamId: _currentTeam!.$id);
        _currentTeam = null;
        return true;
      } else {
        debugPrint('No team to delete');
        return false;
      }
    } catch (e) {
      _handleError(e, 'Failed to delete team');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refreshes the current team data from the server.
  Future<void> refreshCurrentTeam() async {
    await _loadCurrentTeam();
  }

  Future<bool> leaveTeam() async {
    _setLoading(true);
    try {
      if (_currentTeam != null) {
        final account = Account(client);
        final user = await account.get();
        final memberships = await teams.listMemberships(
          teamId: _currentTeam!.$id,
        );
        final membershipId = memberships.memberships
            .firstWhere((membership) => membership.userId == user.$id)
            .$id;
        await teams.deleteMembership(
          teamId: _currentTeam!.$id,
          membershipId: membershipId,
        );
        _currentTeam = null;
        return true;
      } else {
        debugPrint('No team to leave');
        return false;
      }
    } catch (e) {
      _handleError(e, 'Failed to leave team');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> createJoinCode({String? expiresAt}) async {
    _setLoading(true);
    try {
      final execution = await functions.createExecution(
        functionId: '682ead86000333ab4057',
        path: '/create_join_code',
        method: ExecutionMethod.pOST,
        body: jsonEncode({
          'teamId': _currentTeam!.$id,
          'expiresAt':
              expiresAt ??
              DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        }),
      );
      final Map<String, dynamic> responseBody = jsonDecode(
        execution.responseBody,
      );
      if (execution.responseStatusCode != 200) {
        throw Exception(
          'Failed to create join code: ${responseBody['error'] ?? 'Unknown error'}',
        );
      }
      return responseBody['joinCode'];
    } catch (e) {
      _handleError(e, 'Failed to create join code');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> useJoinCode(String joinCode) async {
    _setLoading(true);
    try {
      final execution = await functions.createExecution(
        functionId: '682ead86000333ab4057',
        path: '/use_join_code',
        method: ExecutionMethod.pOST,
        body: jsonEncode({'joinCode': joinCode}),
      );
      final Map<String, dynamic> responseBody = jsonDecode(
        execution.responseBody,
      );
      if (execution.responseStatusCode != 200) {
        throw Exception(responseBody['error'] ?? 'Unknown error');
      }
      return true;
    } catch (e) {
      _handleError(e, 'Failed to use join code');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
