import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:picapool/features/auth/auth_state_manager.dart';
import 'package:picapool/models/auth_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A pure storage controller that exclusively handles
/// saving and retrieving data, with no state management.
class StorageController extends GetxController {
  // Storage keys
  static const String _authKey = 'auth';
  static const String _userKey = 'user';
  static const String _accessTokenKey = 'accessToken';
  static const String _guestModeKey = 'guest_mode';
  static const String _migrationCompleteKey = 'migration_v1_complete';

  // Dependency
  final GetStorage _storage = GetStorage();

  /// Clear authentication data from storage
  /// Returns true if operation was successful
  Future<bool> clearAuth() async {
    try {
      debugPrint('Clearing auth data');
      await _storage.remove(_authKey);
      await _storage.remove(_accessTokenKey);
      return true;
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
      return false;
    }
  }

  /// Clear user data from storage
  /// Returns true if operation was successful
  Future<bool> clearUser() async {
    try {
      debugPrint('Clearing user data');
      await _storage.remove(_userKey);
      return true;
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      return false;
    }
  }

  /// Get access token (simple retrieval, no refresh logic)
  String? getAccessToken() {
    if (isGuestMode()) {
      return null;
    }

    final Auth? auth = getAuth();
    return auth?.accessToken;
  }

  /// Get authentication data from storage
  Auth? getAuth() {
    final String? authData = _storage.read<String>(_authKey);

    if (authData != null) {
      try {
        final Map<String, dynamic> authMap = jsonDecode(authData);
        return Auth.fromJson(authMap);
      } catch (e) {
        debugPrint('Error parsing auth data: $e');
        return null;
      }
    }
    return null;
  }

  /// Get refresh token (simple retrieval)
  String? getRefreshToken() {
    if (isGuestMode()) {
      return null;
    }

    final Auth? auth = getAuth();
    return auth?.refreshToken;
  }

  /// Get user data from storage
  User? getUser() {
    final String? userData = _storage.read<String>(_userKey);

    if (userData != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userData);
        return User.fromJson(userMap);
      } catch (e) {
        debugPrint('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  /// Initialize the controller by loading auth and user data
  Future<bool> initialize() async {
    try {
      // Check and migrate data if needed
      await _migrateFromSharedPreferences();
      return true;
    } catch (e) {
      debugPrint('Error initializing storage controller: $e');
      return false;
    }
  }

  /// Check if in guest mode
  bool isGuestMode() {
    return _storage.read<bool>(_guestModeKey) ?? false;
  }

  /// Perform logout by clearing data and refreshing auth state
  /// Returns true if operation was successful
  Future<bool> logout() async {
    try {
      debugPrint('Performing logout');
      final bool authCleared = await clearAuth();
      final bool userCleared = await clearUser();

      if (!authCleared || !userCleared) {
        debugPrint('Warning: Failed to clear some data during logout');
      }

      try {
        final manager = Get.find<AuthStateManager>();
        manager.refreshAuthState();
      } catch (e) {
        debugPrint('Error refreshing auth state during logout: $e');
        // We still return true if data was cleared, even if the auth state refresh failed
      }

      return authCleared && userCleared;
    } catch (e) {
      debugPrint('Error during logout: $e');
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  /// Save access token to storage
  /// Returns true if operation was successful
  Future<bool> saveAccessToken(String accessToken) async {
    try {
      debugPrint('Saving access token');
      await _storage.write(_accessTokenKey, accessToken);
      return true;
    } catch (e) {
      debugPrint('Error saving access token: $e');
      return false;
    }
  }

  /// Save authentication data to storage
  /// Returns true if operation was successful
  Future<bool> saveAuth(Auth auth) async {
    try {
      debugPrint('Saving auth data: ${auth.toJson()}');
      final String authData = jsonEncode(auth.toJson());
      await _storage.write(_authKey, authData);
      return true;
    } catch (e) {
      debugPrint('Error saving auth data: $e');
      return false;
    }
  }

  /// Save user data to storage
  /// Returns true if operation was successful
  Future<bool> saveUser(User user) async {
    try {
      debugPrint('Saving user data: ${user.toJson()}');
      final String userData = jsonEncode(user.toJson());
      await _storage.write(_userKey, userData);
      return true;
    } catch (e) {
      debugPrint('Error saving user data: $e');
      return false;
    }
  }

  /// Set guest mode
  /// Returns true if operation was successful
  Future<bool> setGuestMode(bool isGuest) async {
    try {
      await _storage.write(_guestModeKey, isGuest);
      return true;
    } catch (e) {
      debugPrint('Error setting guest mode: $e');
      return false;
    }
  }

  /// One-time migration from SharedPreferences to GetStorage
  Future<bool> _migrateFromSharedPreferences() async {
    try {
      // Check if migration already completed
      final bool migrationComplete =
          _storage.read<bool>(_migrationCompleteKey) ?? false;
      if (migrationComplete) {
        debugPrint('Migration already completed, skipping');
        return true;
      }

      debugPrint('Starting migration from SharedPreferences to GetStorage');
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Migrate auth data
      final String? authData = prefs.getString(_authKey);
      if (authData != null) {
        debugPrint('Migrating auth data');
        await _storage.write(_authKey, authData);
      }

      // Migrate user data
      final String? userData = prefs.getString(_userKey);
      if (userData != null) {
        debugPrint('Migrating user data');
        await _storage.write(_userKey, userData);
      }

      // Migrate access token
      final String? accessToken = prefs.getString(_accessTokenKey);
      if (accessToken != null) {
        debugPrint('Migrating access token');
        await _storage.write(_accessTokenKey, accessToken);
      }

      // Mark migration as complete
      await _storage.write(_migrationCompleteKey, true);
      debugPrint('Migration completed successfully');
      return true;
    } catch (e) {
      debugPrint('Error during migration: $e');
      return false;
    }
  }
}
