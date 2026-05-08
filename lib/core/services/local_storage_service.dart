import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save/Get pending listings (created offline)
  static Future<void> addPendingListing(Map<String, dynamic> listing) async {
    final list = getPendingListings();
    list.add({...listing, 'createdAt': DateTime.now().toIso8601String()});
    await _prefs.setString('pending_listings', jsonEncode(list));
  }

  static List<Map<String, dynamic>> getPendingListings() {
    final data = _prefs.getString('pending_listings');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<void> clearPendingListings() async {
    await _prefs.remove('pending_listings');
  }

  // Save/Get cached dashboard stats
  static Future<void> cacheDashboardStats(Map<String, dynamic> stats) async {
    await _prefs.setString('cached_stats', jsonEncode(stats));
  }

  static Map<String, dynamic>? getCachedDashboardStats() {
    final data = _prefs.getString('cached_stats');
    if (data == null) return null;
    return jsonDecode(data);
  }

  // Save/Get cached earnings
  static Future<void> cacheEarnings(List<Map<String, dynamic>> transactions) async {
    await _prefs.setString('cached_earnings', jsonEncode(transactions));
  }

  static List<Map<String, dynamic>> getCachedEarnings() {
    final data = _prefs.getString('cached_earnings');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  // Save/Get cached schedule
  static Future<void> cacheSchedule(List<Map<String, dynamic>> schedules) async {
    await _prefs.setString('cached_schedule', jsonEncode(schedules));
  }

  static List<Map<String, dynamic>> getCachedSchedule() {
    final data = _prefs.getString('cached_schedule');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  // Connectivity status
  static Future<bool> getLastOnlineStatus() async {
    return _prefs.getBool('last_online') ?? true;
  }

  static Future<void> setOnlineStatus(bool online) async {
    await _prefs.setBool('last_online', online);
  }

  // Pending sync count
  static int getPendingSyncCount() {
    return getPendingListings().length;
  }
}
