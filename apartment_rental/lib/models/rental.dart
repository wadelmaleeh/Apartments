enum RentalType { daily, monthly }

RentalType rentalTypeFromString(String value) {
  return RentalType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => RentalType.monthly,
  );
}

String rentalTypeToString(RentalType type) => type.name;

class Rental {
  final String id;
  final String apartmentId;
  final RentalType rentalType;
  final double amount;
  final int days;
  final DateTime date;
  final DateTime createdAt;

  double get total => rentalType == RentalType.daily ? amount * days : amount;

  Rental({
    required this.id,
    required this.apartmentId,
    required this.rentalType,
    required this.amount,
    this.days = 1,
    required this.date,
    required this.createdAt,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'] as String,
      apartmentId: json['apartment_id'] as String,
      rentalType: rentalTypeFromString(json['rental_type'] as String),
      amount: (json['amount'] as num).toDouble(),
      days: (json['days'] as num?)?.toInt() ?? 1,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartment_id': apartmentId,
      'rental_type': rentalTypeToString(rentalType),
      'amount': amount,
      'days': days,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Rental copyWith({
    String? id,
    String? apartmentId,
    RentalType? rentalType,
    double? amount,
    int? days,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Rental(
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      rentalType: rentalType ?? this.rentalType,
      amount: amount ?? this.amount,
      days: days ?? this.days,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
