import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  final List<User> _mockUsers = [];


  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }
    if (!_isStrongPassword(password)) {
      throw ArgumentError('Password must be at least 8 characters long');
    }

    final hashedPassword = _hashPassword(password);
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      password: hashedPassword,
      firstName: firstName,
      lastName: lastName,
      createdOn: DateTime.now(),
    );


    _mockUsers.add(user);
    _currentUser = user;
    notifyListeners();

  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }

    final user = _mockUsers.firstWhere(
      (u) => u.email == email,
      orElse: () => User(
        id: '',
        email: '',
        password: '',
        firstName: '',
        lastName: '',
        createdOn: DateTime.now(),
      ),
    );
    
    if (user.id.isNotEmpty) {

      final hashedPassword = _hashPassword(password);
      if (user.password == hashedPassword) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    return password.length >= 8;
  }




  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
