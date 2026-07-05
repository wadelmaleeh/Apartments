import 'dart:async';
import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';
import 'local_database.dart';
import 'sync_queue.dart';
import '../services/api_service.dart';
import '../models/apartment.dart';
import '../models/rental.dart';
import '../models/expense.dart';

enum SyncStatus { idle, pending, syncing, error, synced }

class SyncService extends ChangeNotifier {
  final ApiService _api;
  final ConnectivityService _connectivity;
  final LocalDatabase _localDb;
  final SyncQueue _queue;

  SyncStatus _status = SyncStatus.idle;
  String? _lastError;
  StreamSubscription<bool>? _sub;
  
  // Auto-sync timer
  Timer? _autoSyncTimer;
  DateTime? _lastSyncTime;
  DateTime? _lastOnlineTime;
  static const Duration _autoSyncInterval = Duration(minutes: 5);
  static const Duration _offlineThreshold = Duration(minutes: 5);

  SyncStatus get status => _status;
  int get pendingCount => _queue.pendingCount;
  bool get hasPending => _queue.hasPending;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;

  SyncService({
    required ApiService api,
    required ConnectivityService connectivity,
    required LocalDatabase localDb,
    required SyncQueue queue,
  })  : _api = api,
        _connectivity = connectivity,
        _localDb = localDb,
        _queue = queue;

  void init() {
    _updateStatus();
    notifyListeners();

    _sub = _connectivity.isConnected.listen((connected) {
      _updateStatus();
      notifyListeners();
      
      if (connected) {
        _handleOnlineStateChanged();
      } else {
        _handleOfflineStateChanged();
      }
    });
    
    // Start auto-sync if online
    if (_connectivity.connected) {
      _startAutoSync();
    }
  }

  void _handleOnlineStateChanged() {
    // Check if we were offline for more than 5 minutes
    final now = DateTime.now();
    final wasOfflineForLong = _lastOnlineTime != null && 
                              now.difference(_lastOnlineTime!) > _offlineThreshold;
    
    debugPrint('Back online! Was offline for long: $wasOfflineForLong');
    
    // Sync immediately if:
    // 1. We have pending items, OR
    // 2. We were offline for more than 5 minutes
    if (_queue.hasPending || wasOfflineForLong) {
      syncNow();
    } else {
      // Just pull latest data
      _pullAll();
    }
    
    // Start auto-sync timer
    _startAutoSync();
  }

  void _handleOfflineStateChanged() {
    debugPrint('Gone offline');
    _lastOnlineTime = DateTime.now();
    _stopAutoSync();
  }

  void _startAutoSync() {
    _stopAutoSync(); // Clear any existing timer
    
    debugPrint('Starting auto-sync every 5 minutes');
    _autoSyncTimer = Timer.periodic(_autoSyncInterval, (timer) {
      if (_connectivity.connected) {
        debugPrint('Auto-sync triggered');
        _pullAll(); // Fetch latest data from server
      }
    });
  }

  void _stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  void queueItem(SyncItem item) {
    _queue.add(item);
    _updateStatus();
    notifyListeners();
    _trySync();
  }

  void _trySync() {
    if (_connectivity.connected && _queue.hasPending && _status != SyncStatus.syncing) {
      syncNow();
    }
  }

  Future<void> syncNow() async {
    if (!_connectivity.connected || !_queue.hasPending) {
      _updateStatus();
      notifyListeners();
      return;
    }

    _status = SyncStatus.syncing;
    _lastError = null;
    notifyListeners();

    try {
      final items = List<SyncItem>.from(_queue.items);
      for (final item in items) {
        try {
          await _processItem(item);
          await _queue.remove(item.id);
        } catch (itemError) {
          // Log individual item error but continue with others
          debugPrint('Failed to sync item ${item.id}: $itemError');
          // Don't remove failed items from queue - they'll be retried
        }
      }
      await _pullAll();
      _lastSyncTime = DateTime.now();
      _status = SyncStatus.synced;
    } catch (e) {
      _status = SyncStatus.error;
      _lastError = e.toString();
    }
    notifyListeners();
  }

  Future<void> _processItem(SyncItem item) async {
    switch (item.dataType) {
      case SyncDataType.apartment:
        await _processApartment(item);
        break;
      case SyncDataType.rental:
        await _processRental(item);
        break;
      case SyncDataType.expense:
        await _processExpense(item);
        break;
    }
  }

  Future<void> _processApartment(SyncItem item) async {
    try {
      switch (item.operation) {
        case SyncOperation.create:
          final data = item.data!;
          final apartment = Apartment(
            id: '',
            name: data['name'] as String,
            description: data['description'] as String? ?? '',
            createdAt: DateTime.parse(data['created_at'] as String),
            updatedAt: DateTime.parse(data['updated_at'] as String),
          );
          try {
            final created = await _api.createApartment(apartment);
            await _replaceLocalId('apartment', item.localId!, created.id);
          } catch (e) {
            debugPrint('Warning: Failed to create apartment: $e');
            rethrow; // Re-throw to keep item in queue
          }
          break;
        case SyncOperation.update:
          final data = item.data!;
          final apartment = Apartment.fromJson(data);
          try {
            await _api.updateApartment(apartment);
          } catch (e) {
            debugPrint('Warning: Failed to update apartment ${apartment.id}: $e');
            // Don't rethrow for updates - skip gracefully
          }
          break;
        case SyncOperation.delete:
          try {
            await _api.deleteApartment(item.remoteId!);
          } catch (e) {
            debugPrint('Warning: Failed to delete apartment ${item.remoteId}: $e');
            // Don't rethrow for deletes - might already be deleted
          }
          break;
      }
    } catch (e) {
      debugPrint('Error processing apartment sync item: $e');
      rethrow;
    }
  }

  Future<void> _processRental(SyncItem item) async {
    try {
      switch (item.operation) {
        case SyncOperation.create:
          final data = item.data!;
          final rental = Rental(
            id: '',
            apartmentId: data['apartment_id'] as String,
            rentalType: rentalTypeFromString(data['rental_type'] as String),
            amount: (data['amount'] as num).toDouble(),
            days: (data['days'] as num?)?.toInt() ?? 1,
            date: DateTime.parse(data['date'] as String),
            createdAt: DateTime.parse(data['created_at'] as String),
          );
          final created = await _api.createRental(rental);
          await _replaceLocalId('rental', item.localId!, created.id);
          break;
        case SyncOperation.update:
          final data = item.data!;
          final rental = Rental.fromJson(data);
          try {
            await _api.updateRental(rental);
          } catch (e) {
            // If update fails with 404, the item doesn't exist on server
            // Skip this item and log the error
            debugPrint('Warning: Failed to update rental ${rental.id}: $e');
            // Don't rethrow - continue with other sync items
          }
          break;
        case SyncOperation.delete:
          try {
            await _api.deleteRental(item.remoteId!);
          } catch (e) {
            debugPrint('Warning: Failed to delete rental ${item.remoteId}: $e');
            // Don't rethrow - item might already be deleted
          }
          break;
      }
    } catch (e) {
      debugPrint('Error processing rental sync item: $e');
      rethrow;
    }
  }

  Future<void> _processExpense(SyncItem item) async {
    try {
      switch (item.operation) {
        case SyncOperation.create:
          final data = item.data!;
          final expense = Expense(
            id: '',
            apartmentId: data['apartment_id'] as String,
            expenseType: data['expense_type'] as String,
            amount: (data['amount'] as num).toDouble(),
            date: DateTime.parse(data['date'] as String),
            createdAt: DateTime.parse(data['created_at'] as String),
          );
          final created = await _api.createExpense(expense);
          await _replaceLocalId('expense', item.localId!, created.id);
          break;
        case SyncOperation.update:
          final data = item.data!;
          final expense = Expense.fromJson(data);
          try {
            await _api.updateExpense(expense);
          } catch (e) {
            debugPrint('Warning: Failed to update expense ${expense.id}: $e');
          }
          break;
        case SyncOperation.delete:
          try {
            await _api.deleteExpense(item.remoteId!);
          } catch (e) {
            debugPrint('Warning: Failed to delete expense ${item.remoteId}: $e');
          }
          break;
      }
    } catch (e) {
      debugPrint('Error processing expense sync item: $e');
      rethrow;
    }
  }

  Future<void> _replaceLocalId(String type, String localId, String remoteId) async {
    if (type == 'apartment') {
      final apartments = await _localDb.getApartments();
      final updated = apartments.map((a) {
        if (a.id == localId) return a.copyWith(id: remoteId);
        return a;
      }).toList();
      await _localDb.saveApartments(updated);
    } else if (type == 'rental') {
      final rentals = await _localDb.getRentals();
      final updated = rentals.map((r) {
        if (r.id == localId) return r.copyWith(id: remoteId);
        return r;
      }).toList();
      await _localDb.saveRentals(updated);
    } else if (type == 'expense') {
      final expenses = await _localDb.getExpenses();
      final updated = expenses.map((e) {
        if (e.id == localId) return e.copyWith(id: remoteId);
        return e;
      }).toList();
      await _localDb.saveExpenses(updated);
    }
  }

  Future<void> _pullAll() async {
    if (!_connectivity.connected) return;
    
    debugPrint('Pulling latest data from server...');
    
    try {
      final apartments = await _api.getApartments();
      await _localDb.saveApartments(apartments);
    } catch (e) {
      debugPrint('Failed to pull apartments: $e');
    }

    try {
      final rentals = await _api.getRentals();
      await _localDb.saveRentals(rentals);
    } catch (e) {
      debugPrint('Failed to pull rentals: $e');
    }

    try {
      final expenses = await _api.getExpenses();
      await _localDb.saveExpenses(expenses);
    } catch (e) {
      debugPrint('Failed to pull expenses: $e');
    }
    
    _lastSyncTime = DateTime.now();
    notifyListeners();
  }

  void _updateStatus() {
    if (!_connectivity.connected) {
      _status = _queue.hasPending ? SyncStatus.pending : SyncStatus.idle;
    } else if (_status == SyncStatus.syncing) {
      return;
    } else if (_queue.hasPending) {
      _status = SyncStatus.pending;
    } else {
      _status = SyncStatus.synced;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _stopAutoSync();
    super.dispose();
  }
}

