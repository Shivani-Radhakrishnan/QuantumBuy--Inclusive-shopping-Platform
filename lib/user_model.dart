import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserModel with ChangeNotifier {
  String? _userName;
  String? _email;
  // The password itself is never stored: only a salted PBKDF2-HMAC-SHA256 hash of it.
  String? _passwordHash;
  String? _salt;
  String? _profilePicture;
  String? _phoneNumber;
  String? _address;

  UserModel() {
    _loadUserData();
  }

  String? get userName => _userName;
  String? get email => _email;
  String? get profilePicture => _profilePicture;
  String? get phoneNumber => _phoneNumber;
  String? get address => _address;
  String? get currentUser => _userName;

  get name => null;

  void register(String username, String email, String password) async {
    _userName = username;
    _email = email;
    _salt = _newSalt();
    _passwordHash = _hashPassword(password, _salt!);
    await _saveUserData();
    notifyListeners();
  }

  bool authenticate(String username, String password) {
    final hash = _passwordHash;
    final salt = _salt;
    if (hash == null || salt == null || hash.isEmpty) return false;
    if ((_userName == username || _email == username) && _constantTimeEquals(_hashPassword(password, salt), hash)) {
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() async {
    _userName = 'Log In to Fill Details';
    _email = '';
    _profilePicture = null;
    _phoneNumber = null;
    _address = null;
    _passwordHash = null;
    _salt = null;
    await _saveUserData();
    notifyListeners();
  }

  void updateProfile(String? profilePicture, String? phoneNumber, String? address) {
    _profilePicture = profilePicture;
    _phoneNumber = phoneNumber;
    _address = address;
    _saveUserData();
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', _userName ?? '');
    prefs.setString('email', _email ?? '');
    prefs.setString('profilePicture', _profilePicture ?? '');
    prefs.setString('phoneNumber', _phoneNumber ?? '');
    prefs.setString('address', _address ?? '');
    prefs.setString('passwordHash', _passwordHash ?? '');
    prefs.setString('passwordSalt', _salt ?? '');
    prefs.remove('password'); // older versions stored the password in plain text
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName');
    _email = prefs.getString('email');
    _profilePicture = prefs.getString('profilePicture');
    _phoneNumber = prefs.getString('phoneNumber');
    _address = prefs.getString('address');
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
