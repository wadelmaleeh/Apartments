import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../providers/apartment_provider.dart';
import '../../providers/rental_provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../utils/constants.dart';
import '../../models/rental.dart';
import '../../models/expense.dart';
import '../../main.dart';
import 'apartment_form_sheet.dart';
import '../income/rental_form_sheet.dart';
import '../expenses/expense_form_sheet.dart';

class ApartmentDetailsScreen extends StatefulWidget {
  final String apartmentId;

  const ApartmentDetailsScreen({super.key, required this.apartmentId});

  @override
  State<ApartmentDetailsScreen> createState() =>
      _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<RentalProvider>()
          .loadRentals(apartmentId: widget.apartmentId);
      context
          .read<ExpenseProvider>()
          .loadExpenses(apartmentId: widget.apartmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final apartmentProvider = context.watch<ApartmentProvider>();
    final rentalProvider = context.watch<RentalProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    final apartment = apartmentProvider.apartments
        .where((a) => a.id == widget.apartmentId)
        .firstOrNull;

    if (apartment == null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.apartmentDetails)),
        body: Center(child: Text(loc.noData)),
      );
    }

    final totalIncome =
        rentalProvider.totalIncomeForApartment(widget.apartmentId);
    final totalExpenses =
        expenseProvider.totalExpensesForApartment(widget.apartmentId);
    final netProfit = totalIncome - totalExpenses;

    final apartmentRentals =
        rentalProvider.rentalsForApartment(widget.apartmentId);
    final apartmentExpenses =
        expenseProvider.expensesForApartment(widget.apartmentId);

    return Scaffold(
      appBar: AppBar(
        title: Text(apartment.name),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => _showEditSheet(context, apartment),
            icon: const Icon(Icons.edit_rounded, color: AppColors.accent),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Stats
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: (width - 24) / 3,
                    child: StatCard(
                      title: loc.income,
                      value: Formatters.currency(totalIncome),
                      icon: Icons.trending_up_rounded,
                      color: AppColors.success,
                      isCompact: true,
                    ),
                  ),
                  SizedBox(
                    width: (width - 24) / 3,
                    child: StatCard(
                      title: loc.expenses,
                      value: Formatters.currency(totalExpenses),
                      icon: Icons.trending_down_rounded,
                      color: AppColors.danger,
                      isCompact: true,
                    ),
                  ),
                  SizedBox(
                    width: (width - 24) / 3,
                    child: StatCard(
                      title: loc.netProfit,
                      value: Formatters.currency(netProfit),
                      icon: Icons.account_balance_wallet_rounded,
                      color:
                          netProfit >= 0 ? AppColors.success : AppColors.warning,
                      isCompact: true,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Rental History
          _SectionHeader(
            title: loc.rentalHistory,
            onAdd: () => _showAddRental(context),
          ),
          const SizedBox(height: 12),
          if (apartmentRentals.isEmpty)
            EmptyState(
              icon: Icons.receipt_long_rounded,
              titleKey: 'no_rentals',
              subtitleKey: 'no_rentals',
            )
          else
            ...apartmentRentals.map(
              (rental) => _RentalTile(
                rental: rental,
                onEdit: () => _showEditRental(context, rental),
                onDelete: () => _confirmDeleteRental(context, rental),
              ),
            ),
          const SizedBox(height: 28),

          // Expense History
          _SectionHeader(
            title: loc.expenseHistory,
            onAdd: () => _showAddExpense(context),
          ),
          const SizedBox(height: 12),
          if (apartmentExpenses.isEmpty)
            EmptyState(
              icon: Icons.receipt_long_rounded,
              titleKey: 'no_expenses',
              subtitleKey: 'no_expenses',
            )
          else
            ...apartmentExpenses.map(
              (expense) => _ExpenseTile(
                expense: expense,
                onEdit: () => _showEditExpense(context, expense),
                onDelete: () => _confirmDeleteExpense(context, expense),
              ),
            ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, apartment) {
    final formKey = GlobalKey<FormState>();
    final formStateKey = GlobalKey<ApartmentFormSheetState>();

    AppBottomSheet.show(
      context,
      title: AppLocalizations.of(context).editApartment,
      children: [
        ApartmentFormSheet(
            key: formStateKey, apartment: apartment, formKey: formKey),
      ],
      onSave: () async {
        if (formKey.currentState?.validate() ?? false) {
          await formStateKey.currentState?.save();
        }
      },
    );
  }

  void _showAddRental(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final formStateKey = GlobalKey<RentalFormSheetState>();

    AppBottomSheet.show(
      context,
      title: AppLocalizations.of(context).addRental,
      children: [
        RentalFormSheet(
            key: formStateKey,
            apartmentId: widget.apartmentId,
            formKey: formKey),
      ],
      onSave: () async {
        if (formKey.currentState?.validate() ?? false) {
          await formStateKey.currentState?.save();
        }
      },
    );
  }

  void _showEditRental(BuildContext context, Rental rental) {
    final formKey = GlobalKey<FormState>();
    final formStateKey = GlobalKey<RentalFormSheetState>();

    AppBottomSheet.show(
      context,
      title: AppLocalizations.of(context).editRental,
      children: [
        RentalFormSheet(key: formStateKey, rental: rental, formKey: formKey),
      ],
      onSave: () async {
        if (formKey.currentState?.validate() ?? false) {
          await formStateKey.currentState?.save();
        }
      },
    );
  }

  void _showAddExpense(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final formStateKey = GlobalKey<ExpenseFormSheetState>();

    AppBottomSheet.show(
      context,
      title: AppLocalizations.of(context).addExpense,
      children: [
        ExpenseFormSheet(
            key: formStateKey,
            apartmentId: widget.apartmentId,
            formKey: formKey),
      ],
      onSave: () async {
        if (formKey.currentState?.validate() ?? false) {
          await formStateKey.currentState?.save();
        }
      },
    );
  }

  void _showEditExpense(BuildContext context, Expense expense) {
    final formKey = GlobalKey<FormState>();
    final formStateKey = GlobalKey<ExpenseFormSheetState>();

    AppBottomSheet.show(
      context,
      title: AppLocalizations.of(context).editExpense,
      children: [
        ExpenseFormSheet(
            key: formStateKey, expense: expense, formKey: formKey),
      ],
      onSave: () async {
        if (formKey.currentState?.validate() ?? false) {
          await formStateKey.currentState?.save();
        }
      },
    );
  }

  Future<void> _confirmDeleteRental(
      BuildContext context, Rental rental) async {
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_outline_rounded,
              size: 32, color: AppColors.danger),
        ),
        title: Text(loc.deleteRental,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(loc.deleteRentalConfirm,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(loc.cancel),
          ),
          const SizedBox(width: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<RentalProvider>().deleteRental(rental.id);
    }
  }

  Future<void> _confirmDeleteExpense(
      BuildContext context, Expense expense) async {
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_outline_rounded,
              size: 32, color: AppColors.danger),
        ),
        title: Text(loc.deleteExpense,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(loc.deleteExpenseConfirm,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(loc.cancel),
          ),
          const SizedBox(width: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ExpenseProvider>().deleteExpense(expense.id);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAdd;

  const _SectionHeader({required this.title, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
        ),
        if (onAdd != null)
          Container(
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded,
                  color: AppColors.accent, size: 22),
            ),
          ),
      ],
    );
  }
}

class _RentalTile extends StatelessWidget {
  final Rental rental;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RentalTile({
    required this.rental,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    String typeLabel;
    switch (rental.rentalType) {
      case RentalType.daily:
        typeLabel = loc.daily;
        break;
      case RentalType.monthly:
        typeLabel = loc.monthly;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.trending_up_rounded,
              color: AppColors.success, size: 20),
        ),
        title: Text(
          Formatters.currency(rental.total),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '$typeLabel - ${Formatters.date(rental.date)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: PopupMenuButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          itemBuilder: (ctx) => [
            PopupMenuItem(
              onTap: onEdit,
              child: Row(
                children: [
                  const Icon(Icons.edit_rounded,
                      size: 20, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Text(loc.edit),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: onDelete,
              child: Row(
                children: [
                  const Icon(Icons.delete_rounded,
                      size: 20, color: AppColors.danger),
                  const SizedBox(width: 10),
                  Text(loc.delete,
                      style: const TextStyle(color: AppColors.danger)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseTile({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.trending_down_rounded,
              color: AppColors.danger, size: 20),
        ),
        title: Text(
          Formatters.currency(expense.amount),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${loc.translate(expense.expenseType)} - ${Formatters.date(expense.date)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: PopupMenuButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          itemBuilder: (ctx) => [
            PopupMenuItem(
              onTap: onEdit,
              child: Row(
                children: [
                  const Icon(Icons.edit_rounded,
                      size: 20, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Text(loc.edit),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: onDelete,
              child: Row(
                children: [
                  const Icon(Icons.delete_rounded,
                      size: 20, color: AppColors.danger),
                  const SizedBox(width: 10),
                  Text(loc.delete,
                      style: const TextStyle(color: AppColors.danger)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
