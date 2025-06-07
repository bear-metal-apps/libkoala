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
      _error = e.toString();
      debugPrint('Failed to load current team: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _error = loading ? null : _error;
    notifyListeners();
  }

  Future<bool> createTeam({
    required String teamName,
    required int teamNumber,
    List<String> roles = const ['owner'],
  }) async {
    _setLoading(true);
    try {
      final String id = ID.unique();
      await teams.create(teamId: id, name: teamNumber.toString(), roles: roles);
      await teams.updatePrefs(
        teamId: id,
        prefs: {'teamName': teamName, 'teamNumber': teamNumber},
      );
      _currentTeam = await teams.get(teamId: id);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Failed to create team: ${e.toString()}');
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
      _error = e.toString();
      debugPrint('Failed to get team: ${e.toString()}');
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
      _error = e.toString();
      debugPrint('Failed to delete team: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshCurrentTeam() async {
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
      _error = e.toString();
      debugPrint('Failed to refresh current team: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
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
        final membershipId =
            memberships.memberships
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
      _error = e.toString();
      debugPrint('Failed to leave team: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> createJoinCode() async {
    _setLoading(true);
    try {
      final execution = await functions.createExecution(
        functionId: '682ead86000333ab4057',
        path: '/create_join_code',
        method: ExecutionMethod.pOST,
        body: jsonEncode({'teamId': _currentTeam!.$id}),
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
      _error = e.toString();
      debugPrint(e.toString());
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
        throw Exception(
          'Failed to use join code: ${responseBody['error'] ?? 'Unknown error'}',
        );
      }
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
