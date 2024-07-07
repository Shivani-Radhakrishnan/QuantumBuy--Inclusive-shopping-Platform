import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserModel with ChangeNotifier {
  String? _userName;
  String? _email;
  String? _password;
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

  void register(String username, String email, String password) async {
    _userName = username;
    _email = email;
    _password = password; // Store password for authentication
    await _saveUserData();
    notifyListeners();
  }

  bool authenticate(String username, String password) {
    if ((_userName == username || _email == username) && _password == password) {
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
    _password = null; // Clear password on logout
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
    prefs.setString('password', _password ?? ''); // Save password
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName');
    _email = prefs.getString('email');
    _profilePicture = prefs.getString('profilePicture');
    _phoneNumber = prefs.getString('phoneNumber');
    _address = prefs.getString('address');
    _password = prefs.getString('password'); // Load password
    notifyListeners();
  }
}
