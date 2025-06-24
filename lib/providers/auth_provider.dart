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
      _error = e.toString();
      debugPrint('Login failed: $_error');
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
      final verification = await account.createVerification(
        url: 'https://appwrite.bearmet.al/verify_email',
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

  // Placeholder for session loading - implement this to load session from storage
  Future<void> loadSession() async {
    // Example:
    // _setLoading(true);
    // try {
    //   // Replace with your actual session loading logic (e.g., from flutter_secure_storage)
    //   final storedSessionId = await _secureStorage.read(key: 'session_id');
    //   if (storedSessionId != null) {
    //     // Potentially re-fetch the session or account details to validate
    //     final acc = await account.get();
    //     // If account.get() is successful, a session is active.
    //     // You might want to fetch the session object itself if needed:
    //     // _currentSession = await account.getSession(sessionId: 'current'); // Or specific ID
    //     _loggedInUser = acc; // Assuming you have a _loggedInUser state
    //     _error = null;
    //   }
    // } on AppwriteException catch (e) {
    //   // Handle session invalid or other errors
    //   _currentSession = null;
    //   _loggedInUser = null;
    //   if (e.code != 401) { // Don't show error for "no session" / "user not found"
    //      _error = "Failed to load session: ${e.message}";
    //   }
    // } catch (e) {
    //   _currentSession = null;
    //   _loggedInUser = null;
    //   _error = "Unexpected error loading session: $e";
    // } finally {
    //   _setLoading(false);
    //   notifyListeners();
    // }
  }

  // Placeholder for logout - implement this
  // Future<void> logout() async {
  // Example:
  // _setLoading(true);
  // try {
  //   if (_currentSession != null) {
  //     await account.deleteSession(sessionId: _currentSession!.$id); // or 'current'
  //   } else {
  //     await account.deleteSessions(); // Fallback if no specific session ID is known
  //   }
  //   _currentSession = null;
  //   _loggedInUser = null;
  //   // Clear stored session
  //   await _secureStorage.delete(key: 'session_id');
  //   _error = null;
  // } on AppwriteException catch (e) {
  //   _error = "Logout failed: ${e.message}";
  //   // Decide if you want to clear local state even if server call fails
  //   _currentSession = null;
  //   _loggedInUser = null;
  //   await _secureStorage.delete(key: 'session_id');
  // } catch (e) {
  //   _error = "Unexpected error during logout: $e";
  //   _currentSession = null;
  //   _loggedInUser = null;
  //   await _secureStorage.delete(key: 'session_id');
  // } finally {
  //   _setLoading(false);
  //   notifyListeners();
  // }
  //}

  // Helper to set loading state and notify (if not already present)
  // void _setLoading(bool isLoading) {
  //   _isLoading = isLoading;
  // Consider if notifyListeners() should always be called here or by the calling method
  // For simplicity, often called by the main methods after all state changes.
  //}

  // You would also need to initialize your Appwrite client and account instance,
  // typically in the constructor or an init method.
  // Client client = Client();
  // late Account account;
  // models.Session? _currentSession;
  // models.User? _loggedInUser; // If you store user details
  // bool _isLoading = false;
  // String? _error;

  // Example constructor:
  // AuthProvider() {
  //   client
  //       .setEndpoint('YOUR_APPWRITE_ENDPOINT') // Replace with your endpoint
  //       .setProject('YOUR_PROJECT_ID')         // Replace with your project ID
  //       .setSelfSigned(status: true); // For local development if using self-signed certs
  //   account = Account(client);
  //   loadSession(); // Load session when provider is initialized
  // }
}
