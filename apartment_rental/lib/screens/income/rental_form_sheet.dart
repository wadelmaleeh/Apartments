import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../localization/app_localizations.dart';
import '../../models/rental.dart';
import '../../providers/rental_provider.dart';
import '../../providers/apartment_provider.dart';
import '../../main.dart';

class RentalFormSheet extends StatefulWidget {
  final Rental? rental;
  final String? apartmentId;
  final GlobalKey<FormState>? formKey;

  const RentalFormSheet(
      {super.key, this.rental, this.apartmentId, this.formKey});

  @override
  State<RentalFormSheet> createState() => RentalFormSheetState();
}

class RentalFormSheetState extends State<RentalFormSheet> {
  late final GlobalKey<FormState> _formKey;
  String? _selectedApartmentId;
  RentalType _rentalType = RentalType.monthly;
  late final TextEditingController _amountController;
  late final TextEditingController _daysController;
  DateTime _selectedDate = DateTime.now();

  bool get isEditing => widget.rental != null;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
    _selectedApartmentId = widget.rental?.apartmentId ?? widget.apartmentId;
    _rentalType = widget.rental?.rentalType ?? RentalType.monthly;
    _amountController = TextEditingController(
      text: widget.rental != null ? widget.rental!.amount.toString() : '',
    );
    _daysController = TextEditingController(
      text: widget.rental != null ? widget.rental!.days.toString() : '1',
    );
    _selectedDate = widget.rental?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final apartments = context.watch<ApartmentProvider>().apartments;
    final isDaily = _rentalType == RentalType.daily;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isEditing && widget.apartmentId == null)
            DropdownButtonFormField<String>(
              initialValue: _selectedApartmentId,
              decoration: InputDecoration(
                labelText: loc.selectApartment,
                prefixIcon: const Icon(Icons.apartment_rounded,
                    color: AppColors.accent),
              ),
              items: apartments.map((a) {
                return DropdownMenuItem(value: a.id, child: Text(a.name));
              }).toList(),
              onChanged: (v) => setState(() => _selectedApartmentId = v),
              validator: (v) => v == null ? loc.selectApartment : null,
            ),
          if (!isEditing && widget.apartmentId == null)
            const SizedBox(height: 16),
          DropdownButtonFormField<RentalType>(
            initialValue: _rentalType,
            decoration: InputDecoration(
              labelText: loc.rentalType,
              prefixIcon: const Icon(Icons.category_rounded,
                  color: AppColors.accent),
            ),
            items: [
              DropdownMenuItem(
                  value: RentalType.daily, child: Text(loc.daily)),
              DropdownMenuItem(
                  value: RentalType.monthly, child: Text(loc.monthly)),
            ],
            onChanged: (v) => setState(() => _rentalType = v!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: isDaily ? loc.pricePerDay : loc.amount,
              hintText: loc.enterAmount,
              prefixIcon: const Icon(Icons.attach_money_rounded,
                  color: AppColors.accent),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return loc.amountRequired;
              if (double.tryParse(v) == null) return loc.amountRequired;
              return null;
            },
          ),
          if (isDaily) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _daysController,
              decoration: InputDecoration(
                labelText: loc.numberOfDays,
                hintText: '1',
                prefixIcon: const Icon(Icons.today_rounded,
                    color: AppColors.accent),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return loc.amountRequired;
                final n = int.tryParse(v);
                if (n == null || n < 1) return loc.amountRequired;
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calculate_rounded,
                      color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${loc.total}: ${_calculateTotal()}',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: loc.date,
                prefixIcon: const Icon(Icons.calendar_today_rounded,
                    color: AppColors.accent),
              ),
              child: Text(DateFormat.yMMMd().format(_selectedDate)),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotal() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final days = int.tryParse(_daysController.text) ?? 1;
    final total = amount * days;
    final formatter = NumberFormat('#,##0.##', 'en_US');
    final formattedTotal = formatter.format(total);
    return '$formattedTotal جنيه';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> save() async {
    final provider = context.read<RentalProvider>();
    bool success;

    final now = DateTime.now();
    final days = _rentalType == RentalType.daily
        ? (int.tryParse(_daysController.text) ?? 1)
        : 1;
    final rental = Rental(
      id: widget.rental?.id ?? '',
      apartmentId: _selectedApartmentId!,
      rentalType: _rentalType,
      amount: double.parse(_amountController.text.trim()),
      days: days,
      date: _selectedDate,
      createdAt: widget.rental?.createdAt ?? now,
    );

    if (isEditing) {
      success = await provider.updateRental(rental);
    } else {
      success = await provider.addRental(rental);
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}
