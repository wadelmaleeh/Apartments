import 'package:flutter/material.dart';
import '../models/apartment.dart';
import '../repositories/repositories.dart';

class ApartmentProvider extends ChangeNotifier {
  final ApartmentRepository _repository;

  ApartmentProvider(this._repository);

  List<Apartment> _apartments = [];
  bool _isLoading = false;
  String? _error;

  List<Apartment> get apartments => _apartments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadApartments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _apartments = await _repository.getApartments();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addApartment(String name, String description) async {
    try {
      final now = DateTime.now();
      final apartment = Apartment(
        id: '',
        name: name,
        description: description,
        createdAt: now,
        updatedAt: now,
      );
      final created = await _repository.createApartment(apartment);
      _apartments.add(created);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateApartment(Apartment apartment) async {
    try {
      final updated = await _repository.updateApartment(
        apartment.copyWith(updatedAt: DateTime.now()),
      );
      final index = _apartments.indexWhere((a) => a.id == apartment.id);
      if (index != -1) _apartments[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteApartment(String id) async {
    try {
      await _repository.deleteApartment(id);
      _apartments.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
