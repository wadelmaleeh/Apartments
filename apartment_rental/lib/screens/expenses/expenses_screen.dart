import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../providers/expense_provider.dart';
import '../../providers/apartment_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart' as custom;
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/sync_indicator.dart';
import '../../models/expense.dart';
import '../../main.dart';
import 'expense_form_sheet.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
      context.read<ApartmentProvider>().loadApartments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.expenses),
        centerTitle: false,
        actions: const [SyncStatusIcon(), SizedBox(width: 8), LogoutButton()],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.danger, Color(0xFFDC2626)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddSheet(context),
          icon: const Icon(Icons.add_rounded),
          label: Text(loc.addExpense),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      body: Consumer2<ExpenseProvider, ApartmentProvider>(
        builder: (context, expenseProvider, apartmentProvider, _) {
          if (expenseProvider.isLoading && expenseProvider.expenses.isEmpty) {
            return const LoadingWidget();
          }

          if (expenseProvider.error != null &&
              expenseProvider.expenses.isEmpty) {
            return custom.ErrorWidget(
              message: expenseProvider.error!,
              onRetry: () => expenseProvider.loadExpenses(),
            );
          }

          if (expenseProvider.expenses.isEmpty) {
            return EmptyState(
              icon: Icons.trending_down_rounded,
              titleKey: 'no_expenses',
              subtitleKey: 'no_expenses',
            );
          }

          final sortedExpenses = List<Expense>.from(expenseProvider.expenses)
            ..sort((a, b) => b.date.compareTo(a.date));

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.danger, Color(0xFFB91C1C)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.receipt_long_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.totalExpenses,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          Formatters.currency(expenseProvider.totalExpenses),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => expenseProvider.loadExpenses(),
                  color: AppColors.danger,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: sortedExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = sortedExpenses[index];
                      final apartment = apartmentProvider.apartments
                          .where((a) => a.id == expense.apartmentId)
                          .firstOrNull;

                      return _ExpenseCard(
                        expense: expense,
                        apartmentName: apartment?.name ?? '-',
                        onEdit: () => _showEditSheet(context, expense),
                        onDelete: () => _confirmDelete(context, expense),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final formStateKey = GlobalKey<ExpenseFormSheetState>();

    AppBottomSheet.show(
      context,
      title: AppLocalizations.of(context).addExpense,
      children: [ExpenseFormSheet(key: formStateKey, formKey: formKey)],
      onSave: () async {
        if (formKey.currentState?.validate() ?? false) {
          await formStateKey.currentState?.save();
        }
      },
    );
  }

  void _showEditSheet(BuildContext context, Expense expense) {
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

  Future<void> _confirmDelete(BuildContext context, Expense expense) async {
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

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final String apartmentName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.expense,
    required this.apartmentName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.trending_down_rounded,
              color: AppColors.danger, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                Formatters.currency(expense.amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                loc.translate(expense.expenseType),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(Icons.apartment_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                apartmentName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                Formatters.date(expense.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
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
