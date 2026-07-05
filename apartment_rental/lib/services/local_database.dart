import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/apartment.dart';
import '../models/rental.dart';
import '../models/expense.dart';

class LocalDatabase {
  static const _apartmentsKey = 'local_apartments';
  static const _rentalsKey = 'local_rentals';
  static const _expensesKey = 'local_expenses';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Apartments
  Future<List<Apartment>> getApartments() async {
    final json = _prefs.getString(_apartmentsKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Apartment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveApartments(List<Apartment> apartments) async {
    final json = jsonEncode(apartments.map((a) => a.toJson()).toList());
    await _prefs.setString(_apartmentsKey, json);
  }

  // Rentals
  Future<List<Rental>> getRentals() async {
    final json = _prefs.getString(_rentalsKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Rental.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveRentals(List<Rental> rentals) async {
    final json = jsonEncode(rentals.map((r) => r.toJson()).toList());
    await _prefs.setString(_rentalsKey, json);
  }

  // Expenses
  Future<List<Expense>> getExpenses() async {
    final json = _prefs.getString(_expensesKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    final json = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await _prefs.setString(_expensesKey, json);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_apartmentsKey);
    await _prefs.remove(_rentalsKey);
    await _prefs.remove(_expensesKey);
  }
}
