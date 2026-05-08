import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileNotifier extends ChangeNotifier {
  static final ProfileNotifier instance = ProfileNotifier._();
  ProfileNotifier._();

  String _name = '';
  String? _photoPath;

  String get name => _name;
  String? get photoPath => _photoPath;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('farmer_name') ?? '';
    _photoPath = prefs.getString('farmer_photo');
    notifyListeners();
  }

  Future<void> save({required String name, String? photoPath}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('farmer_name', name);
    if (photoPath != null) await prefs.setString('farmer_photo', photoPath);
    _name = name;
    if (photoPath != null) _photoPath = photoPath;
    notifyListeners();
  }
}
