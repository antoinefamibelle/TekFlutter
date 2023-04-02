import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _token = "";
  String _pseudo = "";

  String get firstName => _firstName;

  String get lastName => _lastName;

  String get email => _email;

  String get token => _token;

  String get peuso => _pseudo;

  void setUser(String firstName, String lastName, String email, String token,
      String pseudo) {
    _firstName = firstName;
    _lastName = lastName;
    _email = email;
    _token = token;
    _pseudo = pseudo;
    notifyListeners();
  }
}

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void login() {
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
