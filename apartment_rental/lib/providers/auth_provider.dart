import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_database.dart';
import '../services/sync_queue.dart';

class AuthProvider extends ChangeNotifier {
  static const _key = 'isLoggedIn';
  bool _isLoggedIn = false;
  bool _isLoading = true;
  final LocalDatabase? _localDb;
  final SyncQueue? _syncQueue;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthProvider({LocalDatabase? localDb, SyncQueue? syncQueue})
      : _localDb = localDb,
        _syncQueue = syncQueue {
    _loadLoginState();
  }

  Future<void> _loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_key) ?? false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    // Clear authentication state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    
    // Clear local database
    if (_localDb != null) {
      await _localDb.clearAll();
    }
    
    // Clear sync queue
    if (_syncQueue != null) {
      await _syncQueue.clear();
    }
    
    _isLoggedIn = false;
    notifyListeners();
  }
}