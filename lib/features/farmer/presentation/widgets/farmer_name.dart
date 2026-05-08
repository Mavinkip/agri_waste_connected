import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmerName extends ChangeNotifier {
  static final FarmerName _instance = FarmerName._();
  factory FarmerName() => _instance;
  FarmerName._() { _loadName(); }

  String _name = 'Farmer';
  String get name => _name;

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('farmer_name') ?? 'Farmer';
    notifyListeners();
  }

  Future<void> setName(String newName) async {
    _name = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('farmer_name', newName);
    notifyListeners();
  }
}
