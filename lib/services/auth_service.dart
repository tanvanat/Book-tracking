import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isGoogleUser;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.isGoogleUser,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  AuthUser? _currentUser;
  bool _isLoading = false;

  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initialize() async {
    // Initialize GoogleSignIn (required for v7.x)
    await _googleSignIn.initialize();

    // Check existing Firebase session
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      _currentUser = _fromFirebaseUser(firebaseUser);
      notifyListeners();
    }

    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user != null ? _fromFirebaseUser(user) : null;
      notifyListeners();
    });
  }

  AuthUser _fromFirebaseUser(User user) {
    return AuthUser(
      id: user.uid,
      name: user.displayName ?? user.email?.split('@')[0] ?? 'Reader',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      isGoogleUser:
          user.providerData.any((p) => p.providerId == 'google.com'),
    );
  }

  // Google Sign In — google_sign_in v7.x API
  Future<String?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // v7.x: use authenticate() instead of signIn()
      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      // Get ID token from authentication
      final String? idToken = googleUser.authentication.idToken;

      // Get access token via authorization
      final clientAuth = await googleUser.authorizationClient
          .authorizeScopes(['email', 'profile']);

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: clientAuth.accessToken,
      );

      await _auth.signInWithCredential(credential);

      _isLoading = false;
      notifyListeners();
      return null; // success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      final msg = e.toString();
      if (msg.contains('cancel') || msg.contains('sign_in_canceled') ||
          msg.contains('canceled')) {
        return 'cancelled';
      }
      return msg;
    }
  }

  // Email/Password Sign In
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _authErrorMessage(e.code);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'เกิดข้อผิดพลาด: ${e.toString()}';
    }
  }

  // Register with Email/Password
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _authErrorMessage(e.code);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'เกิดข้อผิดพลาด: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    _currentUser = null;
    notifyListeners();
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'ไม่พบอีเมลนี้ในระบบ';
      case 'wrong-password':
        return 'รหัสผ่านไม่ถูกต้อง';
      case 'email-already-in-use':
        return 'อีเมลนี้ถูกใช้งานแล้ว';
      case 'weak-password':
        return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
      case 'invalid-email':
        return 'รูปแบบอีเมลไม่ถูกต้อง';
      case 'too-many-requests':
        return 'ลองใหม่อีกครั้งในภายหลัง';
      default:
        return 'เกิดข้อผิดพลาด: $code';
    }
  }
}