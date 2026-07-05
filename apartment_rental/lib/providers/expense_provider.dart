import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../repositories/repositories.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;

  ExpenseProvider(this._repository);

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalExpenses =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  Future<void> loadExpenses({String? apartmentId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _repository.getExpenses(apartmentId: apartmentId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double totalExpensesForApartment(String apartmentId) {
    return _expenses
        .where((e) => e.apartmentId == apartmentId)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  List<Expense> expensesForApartment(String apartmentId) {
    return _expenses.where((e) => e.apartmentId == apartmentId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<bool> addExpense(Expense expense) async {
    try {
      final created = await _repository.createExpense(expense);
      _expenses.add(created);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    try {
      final updated = await _repository.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) _expenses[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
