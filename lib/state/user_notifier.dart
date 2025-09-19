import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserNotifier extends StateNotifier<AppUser?> {
  UserNotifier() : super(null) {
    _restore();
  }

  static const String _prefsKey = 'app_user';

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        state = AppUser.fromJson(map);
      } catch (_) {}
    }
  }

  Future<void> setUser(AppUser? user) async {
    state = user;
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_prefsKey);
      return;
    }
    await prefs.setString(_prefsKey, jsonEncode(user.toJson()));
  }

  Future<void> clear() async {
    await setUser(null);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, AppUser?>((ref) {
  return UserNotifier();
});


