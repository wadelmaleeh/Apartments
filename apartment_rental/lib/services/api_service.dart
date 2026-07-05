import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/apartment.dart';
import '../models/rental.dart';
import '../models/expense.dart';
import 'api_config.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Auth
  Future<bool> login(String username, String password) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  // Apartments
  Future<List<Apartment>> getApartments() async {
    final response = await _client
        .get(Uri.parse('${ApiConfig.baseUrl}/api/apartments'))
        .timeout(ApiConfig.timeout);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((j) => Apartment.fromJson(j)).toList();
    }
    throw Exception('Failed to load apartments');
  }

  Future<Apartment> createApartment(Apartment apartment) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/apartments'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(apartment.toJson()..remove('id')),
        )
        .timeout(ApiConfig.timeout);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Apartment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create apartment');
  }

  Future<Apartment> updateApartment(Apartment apartment) async {
    final response = await _client
        .put(
          Uri.parse('${ApiConfig.baseUrl}/api/apartments/${apartment.id}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(apartment.toJson()),
        )
        .timeout(ApiConfig.timeout);
    if (response.statusCode == 200) {
      return Apartment.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update apartment');
  }

  Future<void> deleteApartment(String id) async {
    final response = await _client
        .delete(Uri.parse('${ApiConfig.baseUrl}/api/apartments/$id'))
        .timeout(ApiConfig.timeout);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete apartment');
    }
  }

  // Rentals
  Future<List<Rental>> getRentals({String? apartmentId}) async {
    final uri = apartmentId != null
        ? Uri.parse(
            '${ApiConfig.baseUrl}/api/rentals?apartment_id=$apartmentId')
        : Uri.parse('${ApiConfig.baseUrl}/api/rentals');
    final response = await _client.get(uri).timeout(ApiConfig.timeout);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((j) => Rental.fromJson(j)).toList();
    }
    throw Exception('Failed to load rentals');
  }

  Future<Rental> createRental(Rental rental) async {
    final body = rental.toJson()
      ..remove('id')
      ..remove('created_at');
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/rentals'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.timeout);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Rental.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create rental');
  }

  Future<Rental> updateRental(Rental rental) async {
    final response = await _client
        .put(
          Uri.parse('${ApiConfig.baseUrl}/api/rentals/${rental.id}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(rental.toJson()),
        )
        .timeout(ApiConfig.timeout);
    if (response.statusCode == 200) {
      return Rental.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update rental');
  }

  Future<void> deleteRental(String id) async {
    final response = await _client
        .delete(Uri.parse('${ApiConfig.baseUrl}/api/rentals/$id'))
        .timeout(ApiConfig.timeout);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete rental');
    }
  }

  // Expenses
  Future<List<Expense>> getExpenses({String? apartmentId}) async {
    final uri = apartmentId != null
        ? Uri.parse(
            '${ApiConfig.baseUrl}/api/expenses?apartment_id=$apartmentId')
        : Uri.parse('${ApiConfig.baseUrl}/api/expenses');
    final response = await _client.get(uri).timeout(ApiConfig.timeout);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((j) => Expense.fromJson(j)).toList();
    }
    throw Exception('Failed to load expenses');
  }

  Future<Expense> createExpense(Expense expense) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/api/expenses'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(expense.toJson()..remove('id')),
        )
        .timeout(ApiConfig.timeout);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create expense');
  }

  Future<Expense> updateExpense(Expense expense) async {
    final response = await _client
        .put(
          Uri.parse('${ApiConfig.baseUrl}/api/expenses/${expense.id}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(expense.toJson()),
        )
        .timeout(ApiConfig.timeout);
    if (response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update expense');
  }

  Future<void> deleteExpense(String id) async {
    final response = await _client
        .delete(Uri.parse('${ApiConfig.baseUrl}/api/expenses/$id'))
        .timeout(ApiConfig.timeout);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete expense');
    }
  }
}
