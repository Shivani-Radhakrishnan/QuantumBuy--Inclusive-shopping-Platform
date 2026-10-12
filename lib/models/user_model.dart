import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The local account (one per device) and the current login session.

class UserModel with ChangeNotifier {
  String? _userName;
  String? _email;
  // The password itself is never stored: only a salted PBKDF2-HMAC-SHA256 hash of it.
  String? _passwordHash;
  String? _salt;
  String? _profilePicture;
  String? _phoneNumber;
  String? _address;

  bool _isLoggedIn = false;
  late final Future<void> _ready;

  UserModel() {
    _ready = _loadUserData();
  }

  /// Completes once the saved account has been loaded.
  Future<void> get ready => _ready;

  String? get userName => _userName;
  String? get email => _email;
  String? get profilePicture => _profilePicture;
  String? get phoneNumber => _phoneNumber;
  String? get address => _address;

  /// Whether someone has logged in during this app session.
  bool get isLoggedIn => _isLoggedIn;

  /// Whether an account has been registered on this device.
  bool get hasAccount => (_passwordHash ?? '').isNotEmpty;

  /// Creates (or replaces) the local account. Does not log in.
  Future<void> register(String username, String email, String password) async {
    _userName = username.trim();
    _email = email.trim();
    _salt = _newSalt();
    _passwordHash = _hashPassword(password, _salt!);
    _isLoggedIn = false;
    notifyListeners();
    await _saveUserData();
  }

  bool authenticate(String username, String password) {
    final hash = _passwordHash;
    final salt = _salt;
    if (hash == null || salt == null || hash.isEmpty) return false;
    username = username.trim();
    if (username.isEmpty) return false;
    if ((_userName == username || _email == username) && _constantTimeEquals(_hashPassword(password, salt), hash)) {
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Ends the session. The account stays on the device so the user can log
  /// in again.
  void logout() {
    if (!_isLoggedIn) return;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> updateProfile({String? profilePicture, String? phoneNumber, String? address}) async {
    if (profilePicture != null) _profilePicture = profilePicture;
    if (phoneNumber != null) _phoneNumber = phoneNumber.trim();
    if (address != null) _address = address.trim();
    notifyListeners();
    await _saveUserData();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName ?? '');
    await prefs.setString('email', _email ?? '');
    await prefs.setString('profilePicture', _profilePicture ?? '');
    await prefs.setString('phoneNumber', _phoneNumber ?? '');
    await prefs.setString('address', _address ?? '');
    await prefs.setString('passwordHash', _passwordHash ?? '');
    await prefs.setString('passwordSalt', _salt ?? '');
    await prefs.remove('password'); // older versions stored the password in plain text
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? nonEmpty(String key) {
      final value = prefs.getString(key);
      return (value == null || value.isEmpty) ? null : value;
    }

    _userName = nonEmpty('userName');
    _email = nonEmpty('email');
    _profilePicture = nonEmpty('profilePicture');
    _phoneNumber = nonEmpty('phoneNumber');
    _address = nonEmpty('address');
    _passwordHash = prefs.getString('passwordHash');
    _salt = prefs.getString('passwordSalt');
    // Upgrade data saved by older versions, which kept the password in plain text.
    final legacy = prefs.getString('password');
    if (legacy != null) {
      if (legacy.isNotEmpty && (_passwordHash == null || _passwordHash!.isEmpty)) {
        _salt = _newSalt();
        _passwordHash = _hashPassword(legacy, _salt!);
        await prefs.setString('passwordHash', _passwordHash!);
        await prefs.setString('passwordSalt', _salt!);
      }
      await prefs.remove('password');
    }
    notifyListeners();
  }

  static String _newSalt() {
    final rng = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => rng.nextInt(256)));
  }

  /// PBKDF2-HMAC-SHA256, 10,000 iterations, 32-byte key.
  static String _hashPassword(String password, String salt) {
    final hmac = Hmac(sha256, utf8.encode(password));
    var u = hmac.convert([...utf8.encode(salt), 0, 0, 0, 1]).bytes;
    final key = List<int>.from(u);
    for (var i = 1; i < 10000; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < key.length; j++) {
        key[j] ^= u[j];
      }
    }
    return base64Url.encode(key);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
