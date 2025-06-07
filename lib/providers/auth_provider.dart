import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

/// AuthProvider manages all authentication state and logic for the app.
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
      _user = await _getCurrentUser();
      _session = await _getSession();
    } catch (e) {
      debugPrint('Auth state check failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Sets the loading state and notifies listeners.
  void _setLoading(bool loading) {
    _isLoading = loading;
    _error = loading ? null : _error;
    notifyListeners();
  }

  /// Gets the current user from Appwrite, or null if not signed in.
  Future<models.User?> _getCurrentUser() async {
    try {
      final user = await account.get();
      return user;
    } catch (e) {
      return null;
    }
  }

  /// Gets the current session from Appwrite, or null if not signed in.
  Future<models.Session?> _getSession() async {
    try {
      return await account.getSession(sessionId: 'current');
    } catch (e) {
      return null;
    }
  }

  /// Signs in a user with email and password.
  ///
  /// Returns true if successful, false otherwise.
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
      _error = e.toString();
      debugPrint('Login failed: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Registers a new user and signs them in.
  ///
  /// Returns true if successful, false otherwise.
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
      _user = user;
      _session = session;
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Sign up failed: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs out the current user and clears state.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> signOut() async {
    if (_user == null) return true;
    _setLoading(true);
    try {
      await account.deleteSession(sessionId: 'current');
      _user = null;
      _session = null;
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Logout failed: $_error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refreshes the current user from Appwrite.
  Future<void> refreshUser() async {
    if (!isAuthed) return;
    try {
      _user = await _getCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('User refresh failed: $e');
    }
  }
}
