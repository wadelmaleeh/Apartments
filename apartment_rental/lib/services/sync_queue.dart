import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum SyncOperation { create, update, delete }

enum SyncDataType { apartment, rental, expense }

class SyncItem {
  final String id;
  final SyncOperation operation;
  final SyncDataType dataType;
  final String? localId;
  final String? remoteId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  SyncItem({
    required this.id,
    required this.operation,
    required this.dataType,
    this.localId,
    this.remoteId,
    this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'operation': operation.name,
        'dataType': dataType.name,
        'localId': localId,
        'remoteId': remoteId,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SyncItem.fromJson(Map<String, dynamic> json) => SyncItem(
        id: json['id'] as String,
        operation: SyncOperation.values.firstWhere((e) => e.name == json['operation']),
        dataType: SyncDataType.values.firstWhere((e) => e.name == json['dataType']),
        localId: json['localId'] as String?,
        remoteId: json['remoteId'] as String?,
        data: json['data'] as Map<String, dynamic>?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class SyncQueue {
  static const _key = 'sync_queue';
  List<SyncItem> _items = [];
  late SharedPreferences _prefs;

  List<SyncItem> get items => List.unmodifiable(_items);
  int get pendingCount => _items.length;
  bool get hasPending => _items.isNotEmpty;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final json = _prefs.getString(_key);
    if (json != null) {
      final list = jsonDecode(json) as List;
      _items = list.map((e) => SyncItem.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> add(SyncItem item) async {
    // Smart merging: prevent UPDATE before CREATE is synced
    if (item.operation == SyncOperation.update && item.remoteId != null) {
      // Check if there's a pending CREATE for this item
      final pendingCreate = _items.where((e) =>
          e.dataType == item.dataType &&
          e.operation == SyncOperation.create &&
          e.localId == item.remoteId).toList();
      
      if (pendingCreate.isNotEmpty) {
        // Replace the CREATE with updated data instead of adding UPDATE
        for (final createItem in pendingCreate) {
          _items.removeWhere((e) => e.id == createItem.id);
          // Create new item with updated data but keep it as CREATE operation
          _items.add(SyncItem(
            id: createItem.id,
            operation: SyncOperation.create,
            dataType: createItem.dataType,
            localId: createItem.localId,
            remoteId: null,
            data: item.data, // Use the updated data
            createdAt: createItem.createdAt,
          ));
        }
        await _save();
        return; // Don't add the UPDATE
      }
    }
    
    // Check for duplicate operations on the same item
    if (item.operation == SyncOperation.update && item.remoteId != null) {
      // Remove previous UPDATE operations for the same item
      _items.removeWhere((e) =>
          e.dataType == item.dataType &&
          e.operation == SyncOperation.update &&
          e.remoteId == item.remoteId);
    }
    
    _items.add(item);
    await _save();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _save();
  }

  Future<void> clear() async {
    _items.clear();
    await _save();
  }

  Future<void> _save() async {
    final json = jsonEncode(_items.map((e) => e.toJson()).toList());
    await _prefs.setString(_key, json);
  }
}
