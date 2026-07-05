import 'package:uuid/uuid.dart';
import '../models/apartment.dart';
import '../models/rental.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import '../services/local_database.dart';
import '../services/connectivity_service.dart';
import '../services/sync_queue.dart';
import '../services/sync_service.dart';

const _uuid = Uuid();

class ApartmentRepository {
  final ApiService _api;
  final LocalDatabase _localDb;
  final ConnectivityService _connectivity;
  final SyncService _sync;

  ApartmentRepository(this._api, this._localDb, this._connectivity, this._sync);

  Future<List<Apartment>> getApartments() async {
    if (_connectivity.connected) {
      try {
        final apartments = await _api.getApartments();
        await _localDb.saveApartments(apartments);
        return apartments;
      } catch (_) {
        return await _localDb.getApartments();
      }
    }
    return await _localDb.getApartments();
  }

  Future<Apartment> createApartment(Apartment apartment) async {
    final localId = _uuid.v4();
    final localApartment = apartment.copyWith(id: localId);

    final apartments = await _localDb.getApartments();
    apartments.add(localApartment);
    await _localDb.saveApartments(apartments);

    _sync.queueItem(SyncItem(
      id: _uuid.v4(),
      operation: SyncOperation.create,
      dataType: SyncDataType.apartment,
      localId: localId,
      data: apartment.toJson(),
    ));

    return localApartment;
  }

  Future<Apartment> updateApartment(Apartment apartment) async {
    final apartments = await _localDb.getApartments();
    final updated = apartments.map((a) => a.id == apartment.id ? apartment : a).toList();
    await _localDb.saveApartments(updated);

    _sync.queueItem(SyncItem(
      id: _uuid.v4(),
      operation: SyncOperation.update,
      dataType: SyncDataType.apartment,
      remoteId: apartment.id,
      data: apartment.toJson(),
    ));

    return apartment;
  }

  Future<void> deleteApartment(String id) async {
    final apartments = await _localDb.getApartments();
    apartments.removeWhere((a) => a.id == id);
    await _localDb.saveApartments(apartments);

    _sync.queueItem(SyncItem(
      id: _uuid.v4(),
      operation: SyncOperation.delete,
      dataType: SyncDataType.apartment,
      remoteId: id,
    ));
  }
}

class RentalRepository {
  final ApiService _api;
  final LocalDatabase _localDb;
  final ConnectivityService _connectivity;
  final SyncService _sync;

  RentalRepository(this._api, this._localDb, this._connectivity, this._sync);

  Future<List<Rental>> getRentals({String? apartmentId}) async {
    if (_connectivity.connected) {
      try {
        final rentals = await _api.getRentals(apartmentId: apartmentId);
        await _localDb.saveRentals(rentals);
        return apartmentId != null
            ? rentals.where((r) => r.apartmentId == apartmentId).toList()
            : rentals;
      } catch (_) {}
    }
    final all = await _localDb.getRentals();
    return apartmentId != null
        ? all.where((r) => r.apartmentId == apartmentId).toList()
        : all;
  }

  Future<Rental> createRental(Rental rental) async {
    final localId = _uuid.v4();
    final localRental = rental.copyWith(id: localId);

    final rentals = await _localDb.getRentals();
    rentals.add(localRental);
    await _localDb.saveRentals(rentals);

    _sync.queueItem(SyncItem(
      id: _uuid.v4(),
      operation: SyncOperation.create,
      dataType: SyncDataType.rental,
      localId: localId,
      data: rental.toJson(),
    ));

    return localRental;
  }

  Future<Rental> updateRental(Rental rental) async {
    final rentals = await _localDb.getRentals();
    final updated = rentals.map((r) => r.id == rental.id ? rental : r).toList();
    await _localDb.saveRentals(updated);

    _sync.queueItem(SyncItem(
      id: _uuid.v4(),
      operation: SyncOperation.update,
      dataType: SyncDataType.rental,
      remoteId: rental.id,
      data: rental.toJson(),
    ));

    return rental;
  }

  Future<void> deleteRental(String id) async {
    final rentals = await _localDb.getRentals();
    rentals.removeWhere((r) => r.id == id);
    await _localDb.saveRentals(rentals);

    _sync.queueItem(SyncItem(
      id: _uuid.v4(),
      operation: SyncOperation.delete,
      dataType: SyncDataType.rental,
      remoteId: id,
    ));
  }
}

class ExpenseRepository {
  final ApiService _api;
  final LocalDatabase _localDb;
  final ConnectivityService _connectivity;
  final SyncService _sync;

  ExpenseRepository(this._api, this._localDb, this._connectivity, this._sync);

  Future<List<Expense>> getExpenses({String? apartmentId}) async {
    if (_connectivity.connected) {
      try {
        final expenses = await _api.getExpenses(apartmentId: apartmentId);
        await _localDb.saveExpenses(expenses);
        return apartmentId != null
            ? expenses.where((e) => e.apartmentId == apartmentId).toList()
            : expenses;
      } catch (_) {}
    }
    final all = await _localDb.getExpenses();
    return apartmentId != null
        ? all.where((e) => e.apartmentId == apartmentId).toList()
        : all;
  }

  Future<Expense> createExpense(Expense expense) async {
    final localId = _uuid.v4();
    final localExpense = expense.copyWith(id: localId);

    final expenses = await _localDb.getExpenses();
    expenses.add(localExpense);
    await _localDb.saveExpenses(expenses);

    _sync.queueItem(SyncItem(
      id: _uuid.v4(),
      operation: SyncOperation.create,
      dataType: SyncDataType.expense,
      localId: localId,
      data: expense.toJson(),
    ));

    return localExpense;
  }

  Future<Expense> updateExpense(Expense expense) async {
    final expenses = await _localDb.getExpenses();
    final updated = expenses.map((e) => e.id == expense.id ? expense : e).toList();
    await _localDb.saveExpenses(updated);

    _sync.queueItem(SyncItem(
      id: _uuid.v4(),
      operation: SyncOperation.update,
      dataType: SyncDataType.expense,
      remoteId: expense.id,
      data: expense.toJson(),
    ));

    return expense;
  }

  Future<void> deleteExpense(String id) async {
    final expenses = await _localDb.getExpenses();
    expenses.removeWhere((e) => e.id == id);
    await _localDb.saveExpenses(expenses);

    _sync.queueItem(SyncItem(
      id: _uuid.v4(),
      operation: SyncOperation.delete,
      dataType: SyncDataType.expense,
      remoteId: id,
    ));
  }
}
