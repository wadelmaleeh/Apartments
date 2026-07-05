import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../localization/app_localizations.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/apartment_provider.dart';
import '../../utils/constants.dart';
import '../../main.dart';

class ExpenseFormSheet extends StatefulWidget {
  final Expense? expense;
  final String? apartmentId;
  final GlobalKey<FormState>? formKey;

  const ExpenseFormSheet(
      {super.key, this.expense, this.apartmentId, this.formKey});

  @override
  State<ExpenseFormSheet> createState() => ExpenseFormSheetState();
}

class ExpenseFormSheetState extends State<ExpenseFormSheet> {
  late final GlobalKey<FormState> _formKey;
  String? _selectedApartmentId;
  late String _selectedExpenseType;
  late final TextEditingController _amountController;
  DateTime _selectedDate = DateTime.now();

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
    _selectedApartmentId = widget.expense?.apartmentId ?? widget.apartmentId;
    _selectedExpenseType =
        widget.expense?.expenseType ?? AppConstants.expenseTypes.first;
    _amountController = TextEditingController(
      text: widget.expense != null ? widget.expense!.amount.toString() : '',
    );
    _selectedDate = widget.expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final apartments = context.watch<ApartmentProvider>().apartments;

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
          DropdownButtonFormField<String>(
            initialValue: _selectedExpenseType,
            decoration: InputDecoration(
              labelText: loc.expenseType,
              prefixIcon: const Icon(Icons.category_rounded,
                  color: AppColors.accent),
            ),
            items: AppConstants.expenseTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(loc.translate(type)),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedExpenseType = v!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: loc.amount,
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
    final provider = context.read<ExpenseProvider>();
    bool success;

    final now = DateTime.now();
    final expense = Expense(
      id: widget.expense?.id ?? '',
      apartmentId: _selectedApartmentId!,
      expenseType: _selectedExpenseType,
      amount: double.parse(_amountController.text.trim()),
      date: _selectedDate,
      createdAt: widget.expense?.createdAt ?? now,
    );

    if (isEditing) {
      success = await provider.updateExpense(expense);
    } else {
      success = await provider.addExpense(expense);
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}
