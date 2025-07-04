import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

/// Handles all authentication stuff.
///
/// It's responsible for:
///   - Managing user sessions
///   - Handling sign in, sign up, and sign out
///   - Exposing the current user and session
///   - Notifying listeners when authentication state changes
///
/// Usage:
///   Instantiate with an Appwrite [Client].
///   Listen to changes with a Consumer or Provider.
class AuthProvider extends ChangeNotifier {
  final Client client;
  final Account account;

  models.User? _user;
  models.Session? _session;
  bool _isLoading = false;
  String? _error;

  /// Creates a new AuthProvider instance and automatically checks the authentication state.
  ///
  /// This constructor initializes the provider with the required Appwrite client
  /// and immediately attempts to restore any existing user session.
  ///
  /// Parameters:
  ///   - client: The Appwrite client instance
  AuthProvider({required this.client}) : account = Account(client) {
    _checkAuthState();
  }

  /// Returns the current authenticated user, or null if not signed in.
  models.User? get user => _user;

  /// Returns the current session, or null if not signed in.
  models.Session? get session => _session;

  /// True if a user is authenticated.
  bool get isAuthed => _user != null;

  /// True if an authentication operation is in progress.
  bool get isLoading => _isLoading;

  /// The last error message, if any.
  String? get error => _error;

  /// The user's display name, or 'Guest' if not signed in.
  String get userName => _user?.name ?? 'Guest';

  /// The user's email, or empty string if not signed in.
  String get userEmail => _user?.email ?? '';

  /// Checks and restores authentication state on startup.
  Future<void> _checkAuthState() async {
    _setLoading(true);
    try {
      _user = await account.get();
      _session = await account.getSession(sessionId: 'current');
    } catch (e) {
      _handleError(e, 'Auth state check failed');
    } finally {
      _setLoading(false);
    }
  }

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

  /// Signs in a user with email and password.
  ///
  /// Returns true if successful, false if not.
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      _session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      _user = await account.get();
      return true;
    } catch (e) {
      _handleError(e, 'Login failed');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Registers a new user and signs them in.
  ///
  /// Returns true if successful, false if not.
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      await account.createVerification(
        url: 'https://appwrite.bearmet.al/verify_email',
      );
      _user = user;
      _session = session;
      return true;
    } catch (e) {
      _handleError(e, 'Sign up failed');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs out the current user and clears state.
  ///
  /// Returns true if successful, false if not.
  Future<bool> signOut() async {
    if (_user == null) return true;
    _setLoading(true);
    try {
      await account.deleteSession(sessionId: 'current');
      _user = null;
      _session = null;
      return true;
    } catch (e) {
      _handleError(e, 'Logout failed');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refreshes the current user from Appwrite.
  Future<void> refreshUser() async {
    if (!isAuthed) return;
    try {
      _user = await account.get();
      notifyListeners();
    } catch (e) {
      _handleError(e, 'User refresh failed');
    }
  }
}
