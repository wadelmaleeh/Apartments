import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../providers/apartment_provider.dart';
import '../../providers/rental_provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart' as custom;
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/sync_indicator.dart';
import '../../main.dart';
import 'apartment_form_sheet.dart';
import 'apartment_details_screen.dart';

class ApartmentsScreen extends StatefulWidget {
  const ApartmentsScreen({super.key});

  @override
  State<ApartmentsScreen> createState() => _ApartmentsScreenState();
}

class _ApartmentsScreenState extends State<ApartmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApartmentProvider>().loadApartments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.apartments),
        centerTitle: false,
        actions: const [SyncStatusIcon(), SizedBox(width: 8), LogoutButton()],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent, AppColors.sky],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddSheet(context),
          icon: const Icon(Icons.add_rounded),
          label: Text(loc.addApartment),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      body: Consumer<ApartmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.apartments.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.error != null && provider.apartments.isEmpty) {
            return custom.ErrorWidget(
              message: provider.error!,
              onRetry: () => provider.loadApartments(),
            );
          }

          if (provider.apartments.isEmpty) {
            return EmptyState(
              icon: Icons.apartment_rounded,
              titleKey: 'no_apartments',
              subtitleKey: 'add_first_apartment',
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadApartments(),
            color: AppColors.accent,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: provider.apartments.length,
              itemBuilder: (context, index) {
                final apartment = provider.apartments[index];
                return _ApartmentCard(
                  apartment: apartment,
                  onTap: () => _openDetails(context, apartment.id),
                  onEdit: () => _showEditSheet(context, apartment),
                  onDelete: () => _confirmDelete(context, apartment.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final formStateKey = GlobalKey<ApartmentFormSheetState>();

    AppBottomSheet.show(
      context,
      title: AppLocalizations.of(context).addApartment,
      children: [ApartmentFormSheet(key: formStateKey, formKey: formKey)],
      onSave: () async {
        if (formKey.currentState?.validate() ?? false) {
          await formStateKey.currentState?.save();
        }
      },
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

  void _openDetails(BuildContext context, String apartmentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApartmentDetailsScreen(apartmentId: apartmentId),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
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
          child: const Icon(
            Icons.delete_outline_rounded,
            size: 32,
            color: AppColors.danger,
          ),
        ),
        title: Text(loc.deleteApartment,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(loc.deleteApartmentConfirm,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      await context.read<ApartmentProvider>().deleteApartment(id);
    }
  }
}

class _ApartmentCard extends StatelessWidget {
  final dynamic apartment;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ApartmentCard({
    required this.apartment,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    final rentalProvider = context.watch<RentalProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    final totalIncome =
        rentalProvider.totalIncomeForApartment(apartment.id);
    final totalExpenses =
        expenseProvider.totalExpensesForApartment(apartment.id);
    final netProfit = totalIncome - totalExpenses;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.12),
                            AppColors.sky.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apartment.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (apartment.description.isNotEmpty)
                            Text(
                              apartment.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                                  style: const TextStyle(
                                      color: AppColors.danger)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: AppColors.accent.withValues(alpha: 0.06),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _MiniStat(
                      label: loc.income,
                      value: Formatters.currency(totalIncome),
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 16),
                    _MiniStat(
                      label: loc.expenses,
                      value: Formatters.currency(totalExpenses),
                      color: AppColors.danger,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (netProfit >= 0
                                ? AppColors.success
                                : AppColors.danger)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        Formatters.currency(netProfit),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: netProfit >= 0
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}
