import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ai_project/services/firestore_service.dart';

/// Custom exception containing a user-friendly error message.
class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Service managing user authentication with Firebase Auth, Google Sign-In,
/// and Email/Password. Automatically synchronizes user profile to Firestore.
class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirestoreService _firestoreService;

  bool _isGoogleInitialized = false;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirestoreService? firestoreService,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _firestoreService = firestoreService ?? FirestoreService();

  /// Stream emitting the authenticated Firebase [User] whenever state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in Firebase [User], or null if unauthenticated.
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently authenticated.
  bool get isAuthenticated => _auth.currentUser != null;

  /// Initializes authentication SDKs (e.g. Google Sign In singleton).
  Future<void> initialize() async {
    if (_isGoogleInitialized) return;
    try {
      await _googleSignIn.initialize();
      _isGoogleInitialized = true;
    } catch (e) {
      debugPrint('AuthService: Google Sign In initialization notice: $e');
    }
  }

  // ── EMAIL & PASSWORD REGISTRATION ───────────────────────────────────────────

  /// Registers a new user with Email and Password, updates their displayName,
  /// and creates a user document in Cloud Firestore under `users/{uid}`.
  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final user = userCredential.user;
      if (user != null) {
        try {
          await user.updateDisplayName(fullName.trim());
        } catch (_) {}

        await _firestoreService.saveUserProfile(
          user,
          fullName: fullName.trim(),
          username: username.trim(),
          provider: 'password',
        );
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Signs in an existing user with Email and Password.
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      final user = userCredential.user;
      if (user != null) {
        await _firestoreService.saveUserProfile(user, provider: 'password');
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ── GOOGLE SIGN-IN ──────────────────────────────────────────────────────────

  /// Initiates interactive Google Sign-In, exchanges tokens with Firebase Auth,
  /// and saves the user profile in Firestore under `users/{uid}`.
  ///
  /// Returns [UserCredential] on success, or `null` if the user cancelled.
  Future<UserCredential?> signInWithGoogle() async {
    await initialize();

    try {
      final GoogleSignInAccount googleAccount = await _googleSignIn
          .authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleAccount.authentication;

      String? accessToken;
      try {
        final authz = await googleAccount.authorizationClient.authorizeScopes(
          [],
        );
        accessToken = authz.accessToken;
      } catch (_) {
        // Scopes authorization is optional for primary Firebase authentication
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: accessToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        await _firestoreService.saveUserProfile(
          userCredential.user!,
          provider: 'google.com',
        );
      }

      return userCredential;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        debugPrint('AuthService: Google sign-in was cancelled by user.');
        return null;
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (e.toString().toLowerCase().contains('cancel')) {
        return null;
      }
      throw _handleAuthException(e);
    }
  }

  // ── LOGOUT ──────────────────────────────────────────────────────────────────

  /// Signs the user out from Firebase Authentication and Google Sign-In.
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut().catchError((_) {}),
    ]);
  }

  // ── ERROR HANDLING ──────────────────────────────────────────────────────────

  /// Converts various platform & Firebase exceptions into user-friendly messages.
  Exception _handleAuthException(dynamic error) {
    if (error is FirebaseAuthException) {
      String message;
      switch (error.code) {
        case 'email-already-in-use':
          message =
              'This email address is already registered. Please sign in instead.';
          break;
        case 'weak-password':
          message =
              'The password is too weak. Please choose a password with at least 6 characters.';
          break;
        case 'invalid-email':
          message =
              'The email address is formatted incorrectly. Please enter a valid email.';
          break;
        case 'user-not-found':
          message = 'No account found matching this email address.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message =
              'Incorrect email or password. Please check your credentials and try again.';
          break;
        case 'too-many-requests':
          message =
              'Too many failed attempts. Please wait a moment and try again.';
          break;
        case 'account-exists-with-different-credential':
          message =
              'An account already exists with the same email using a different sign-in method. Please sign in with that provider.';
          break;
        case 'operation-not-allowed':
          message =
              'This sign-in provider is not enabled in Firebase Console. Please enable it under Authentication > Sign-in method.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled. Please contact support.';
          break;
        case 'network-request-failed':
          message =
              'Network error. Please check your internet connection and try again.';
          break;
        case 'popup-closed-by-user':
          message = 'Sign-in was cancelled before completion.';
          break;
        case 'invalid-api-key':
          message =
              'Firebase API key is invalid. Please verify your firebase_options.dart.';
          break;
        case 'app-not-authorized':
          message =
              'This app is not authorized to use Firebase Authentication with the provided API key.';
          break;
        default:
          message = error.message ?? 'Authentication error: ${error.code}';
      }
      return AuthException(message, code: error.code);
    } else if (error is GoogleSignInException) {
      String message;
      switch (error.code) {
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          message =
              'Google Sign-In configuration error: Please verify your SHA-1 fingerprint in Firebase Console and ensure Google sign-in is enabled.';
          break;
        case GoogleSignInExceptionCode.canceled:
          message = 'Google sign-in was cancelled.';
          break;
        case GoogleSignInExceptionCode.uiUnavailable:
          message =
              'Google sign-in UI is currently unavailable. Please try again.';
          break;
        default:
          message =
              error.description ??
              'Google Sign-In failed (${error.code.name}).';
      }
      return AuthException(message, code: error.code.name);
    } else if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return AuthException(
          'Firestore permission denied. Please ensure your Firestore Security Rules permit authenticated access to users/{uid}.',
          code: error.code,
        );
      } else if (error.code == 'unavailable') {
        return AuthException(
          'Firebase service is temporarily unavailable. Please verify your internet connection.',
          code: error.code,
        );
      }
      return AuthException(
        error.message ?? 'Firebase error: ${error.code}',
        code: error.code,
      );
    } else if (error is AuthException) {
      return error;
    } else {
      return AuthException(error.toString().replaceFirst('Exception: ', ''));
    }
  }
}
