import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AuthUser? _currentUser;
  bool _isLoading = false;

  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  // Initialize – check if user already logged in
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId != null) {
      _currentUser = AuthUser(
        id: userId,
        name: prefs.getString('user_name') ?? '',
        email: prefs.getString('user_email') ?? '',
        photoUrl: prefs.getString('user_photo'),
        isGoogleUser: prefs.getBool('is_google_user') ?? false,
      );
      notifyListeners();
    }
  }

  // Google Sign In
  Future<String?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return 'cancelled';
      }

      _currentUser = AuthUser(
        id: googleUser.id,
        name: googleUser.displayName ?? 'Reader',
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
        isGoogleUser: true,
      );

      await _saveUser();
      _isLoading = false;
      notifyListeners();
      return null; // success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  // Email/Password Sign In
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate a small delay
      await Future.delayed(const Duration(milliseconds: 800));

      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('registered_email');
      final storedPassword = prefs.getString('registered_password');
      final storedName = prefs.getString('registered_name');

      if (storedEmail == null) {
        _isLoading = false;
        notifyListeners();
        return 'ยังไม่มีบัญชีผู้ใช้ กรุณาสมัครสมาชิกก่อน';
      }

      if (storedEmail != email) {
        _isLoading = false;
        notifyListeners();
        return 'ไม่พบอีเมลนี้ในระบบ';
      }

      if (storedPassword != password) {
        _isLoading = false;
        notifyListeners();
        return 'รหัสผ่านไม่ถูกต้อง';
      }

      _currentUser = AuthUser(
        id: email,
        name: storedName ?? email.split('@')[0],
        email: email,
        isGoogleUser: false,
      );

      await _saveUser();
      _isLoading = false;
      notifyListeners();
      return null; // success
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

      await Future.delayed(const Duration(milliseconds: 800));

      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString('registered_email');

      if (existing == email) {
        _isLoading = false;
        notifyListeners();
        return 'อีเมลนี้ถูกใช้งานแล้ว';
      }

      await prefs.setString('registered_name', name);
      await prefs.setString('registered_email', email);
      await prefs.setString('registered_password', password);

      _currentUser = AuthUser(
        id: email,
        name: name,
        email: email,
        isGoogleUser: false,
      );

      await _saveUser();
      _isLoading = false;
      notifyListeners();
      return null; // success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'เกิดข้อผิดพลาด: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    if (_currentUser?.isGoogleUser == true) {
      await _googleSignIn.signOut();
    }
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_photo');
    await prefs.remove('is_google_user');
    notifyListeners();
  }

  Future<void> _saveUser() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', _currentUser!.id);
    await prefs.setString('user_name', _currentUser!.name);
    await prefs.setString('user_email', _currentUser!.email);
    if (_currentUser!.photoUrl != null) {
      await prefs.setString('user_photo', _currentUser!.photoUrl!);
    }
    await prefs.setBool('is_google_user', _currentUser!.isGoogleUser);
  }
}
