import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

class AuthState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
    'healthcare_workers',
  );
  final Logger _logger = Logger();

  bool _isLoading = false;
  String? _errorMessage;
  bool _agreeToTerms = false;
  Map<String, dynamic>? _currentUserData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get agreeToTerms => _agreeToTerms;
  Map<String, dynamic>? get currentUserData => _currentUserData;

  User? get user => _auth.currentUser;
  bool get isLoggedIn => user != null;

  // Initialize offline cache and restore session
  Future<void> init() async {
    if (user != null) {
      await _loadUserData(user!.uid);
    }
  }

  void setAgreeToTerms(bool value) {
    _agreeToTerms = value;
    notifyListeners();
  }

  void printCurrentUser() {
    _logger.d('Current User: ${user?.uid}');
    _logger.d('Healthcare ID: ${currentUserData?['healthcareId']}');
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String healthcareId,
    String facilityName,
    String role,
  ) async {
    if (!_agreeToTerms) {
      _errorMessage = 'Please agree to the Terms of Service & Privacy Policy';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      // 1. Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Update display name
      await userCredential.user?.updateDisplayName(name);

      // 3. Realtime Database (Cloud)
      final userData = {
        'name': name,
        'email': email,
        'healthcareId': healthcareId,
        'facilityName': facilityName,
        'role': role,
        'lastUpdated': ServerValue.timestamp,
      };

      await _dbRef.child(userCredential.user!.uid).set(userData);

      // 4. Cache locally
      await _cacheUserData(userCredential.user!.uid, userData);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Registration failed';
    } catch (e) {
      _errorMessage = 'Failed to create user: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Load user data (tries cloud first, falls back to cache)
      await _loadUserData(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login failed';
    } finally {
      _setLoading(false);
    }
  }

  // ================== Data Handling ==================
  Future<void> _loadUserData(String uid) async {
    try {
      // 1. Try fetching from Realtime DB (Cloud)
      final snapshot = await _dbRef.child(uid).get();

      if (snapshot.exists) {
        _currentUserData = Map<String, dynamic>.from(snapshot.value as Map);
        await _cacheUserData(uid, _currentUserData!);
      } else {
        // 2. Fallback to local cache
        await _loadUserDataFromCache();
      }
    } catch (e) {
      // 3. Offline fallback
      await _loadUserDataFromCache();
    }
    notifyListeners();
  }

  Future<void> _cacheUserData(String uid, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedUserData_$uid', jsonEncode(data));
    _currentUserData = data;
  }

  Future<void> _loadUserDataFromCache() async {
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cachedUserData_${user!.uid}');

    if (cachedData != null) {
      _currentUserData = Map<String, dynamic>.from(jsonDecode(cachedData));
      notifyListeners();
    }
  }



  Future<void> logout() async {
    // Clear cached data first
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.remove('cachedUserData_${user!.uid}');
    }
    
    // Clear local state
    _currentUserData = null;
    _errorMessage = null;
    
    // Sign out from Firebase
    await _auth.signOut();

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _logger.d('AuthState loading: $value');
    _logger.d('Current user: ${_auth.currentUser?.uid}');
    _logger.d('Healthcare ID: ${_currentUserData?['healthcareId']}');
    _isLoading = value;
    notifyListeners();
  }
}