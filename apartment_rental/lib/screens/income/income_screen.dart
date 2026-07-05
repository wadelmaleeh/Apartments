import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../providers/rental_provider.dart';
import '../../providers/apartment_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart' as custom;
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/sync_indicator.dart';
import '../../models/rental.dart';
import '../../main.dart';
import 'rental_form_sheet.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalProvider>().loadRentals();
      context.read<ApartmentProvider>().loadApartments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.income),
        centerTitle: false,
        actions: const [SyncStatusIcon(), SizedBox(width: 8), LogoutButton()],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.success, Color(0xFF34D399)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddSheet(context),
          icon: const Icon(Icons.add_rounded),
          label: Text(loc.addRental),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      body: Consumer2<RentalProvider, ApartmentProvider>(
        builder: (context, rentalProvider, apartmentProvider, _) {
          if (rentalProvider.isLoading && rentalProvider.rentals.isEmpty) {
            return const LoadingWidget();
          }

          if (rentalProvider.error != null &&
              rentalProvider.rentals.isEmpty) {
            return custom.ErrorWidget(
              message: rentalProvider.error!,
              onRetry: () => rentalProvider.loadRentals(),
            );
          }

          if (rentalProvider.rentals.isEmpty) {
            return EmptyState(
              icon: Icons.trending_up_rounded,
              titleKey: 'no_rentals',
              subtitleKey: 'no_rentals',
            );
          }

          final sortedRentals = List<Rental>.from(rentalProvider.rentals)
            ..sort((a, b) => b.date.compareTo(a.date));

          return Column(
            children: [
              // Summary banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.success, Color(0xFF059669)],
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
                      child: const Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.totalRentalIncome,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          Formatters.currency(rentalProvider.totalIncome),
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
                  onRefresh: () => rentalProvider.loadRentals(),
                  color: AppColors.success,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: sortedRentals.length,
                    itemBuilder: (context, index) {
                      final rental = sortedRentals[index];
                      final apartment = apartmentProvider.apartments
                          .where((a) => a.id == rental.apartmentId)
                          .firstOrNull;

                      return _RentalCard(
                        rental: rental,
                        apartmentName: apartment?.name ?? '-',
                        onEdit: () => _showEditSheet(context, rental),
                        onDelete: () => _confirmDelete(context, rental),
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
    final formStateKey = GlobalKey<RentalFormSheetState>();

    AppBottomSheet.show(
      context,
      title: AppLocalizations.of(context).addRental,
      children: [RentalFormSheet(key: formStateKey, formKey: formKey)],
      onSave: () async {
        if (formKey.currentState?.validate() ?? false) {
          await formStateKey.currentState?.save();
        }
      },
    );
  }

  void _showEditSheet(BuildContext context, Rental rental) {
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

  Future<void> _confirmDelete(BuildContext context, Rental rental) async {
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
}

class _RentalCard extends StatelessWidget {
  final Rental rental;
  final String apartmentName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RentalCard({
    required this.rental,
    required this.apartmentName,
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
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.trending_up_rounded,
              color: AppColors.success, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                Formatters.currency(rental.total),
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
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                typeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (rental.rentalType == RentalType.daily)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${Formatters.currency(rental.amount)} × ${rental.days} ${loc.days}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Row(
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
                    Formatters.date(rental.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
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
