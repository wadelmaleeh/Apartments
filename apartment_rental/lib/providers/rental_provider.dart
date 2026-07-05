import 'package:flutter/material.dart';
import '../models/rental.dart';
import '../repositories/repositories.dart';

class RentalProvider extends ChangeNotifier {
  final RentalRepository _repository;

  RentalProvider(this._repository);

  List<Rental> _rentals = [];
  bool _isLoading = false;
  String? _error;

  List<Rental> get rentals => _rentals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalIncome =>
      _rentals.fold(0.0, (sum, r) => sum + r.total);

  Future<void> loadRentals({String? apartmentId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rentals = await _repository.getRentals(apartmentId: apartmentId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double totalIncomeForApartment(String apartmentId) {
    return _rentals
        .where((r) => r.apartmentId == apartmentId)
        .fold(0.0, (sum, r) => sum + r.total);
  }

  List<Rental> rentalsForApartment(String apartmentId) {
    return _rentals.where((r) => r.apartmentId == apartmentId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<bool> addRental(Rental rental) async {
    try {
      final created = await _repository.createRental(rental);
      _rentals.add(created);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRental(Rental rental) async {
    try {
      final updated = await _repository.updateRental(rental);
      final index = _rentals.indexWhere((r) => r.id == rental.id);
      if (index != -1) _rentals[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRental(String id) async {
    try {
      await _repository.deleteRental(id);
      _rentals.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
