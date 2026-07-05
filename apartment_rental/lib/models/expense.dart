class Expense {
  final String id;
  final String apartmentId;
  final String expenseType;
  final double amount;
  final DateTime date;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.apartmentId,
    required this.expenseType,
    required this.amount,
    required this.date,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      apartmentId: json['apartment_id'] as String,
      expenseType: json['expense_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartment_id': apartmentId,
      'expense_type': expenseType,
      'amount': amount,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Expense copyWith({
    String? id,
    String? apartmentId,
    String? expenseType,
    double? amount,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      expenseType: expenseType ?? this.expenseType,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
