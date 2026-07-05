import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../localization/app_localizations.dart';
import '../../providers/apartment_provider.dart';
import '../../providers/rental_provider.dart';
import '../../providers/expense_provider.dart';
import '../../services/pdf_report_service.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import '../../widgets/logout_button.dart';
import '../../widgets/sync_indicator.dart';
import '../../main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<ApartmentProvider>().loadApartments();
    context.read<RentalProvider>().loadRentals();
    context.read<ExpenseProvider>().loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.dashboard),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: loc.monthlyReport,
            onPressed: () => _showReportSheet(context),
          ),
          const SyncStatusIcon(),
          const SizedBox(width: 8),
          const LogoutButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: AppColors.accent,
        child: Consumer3<ApartmentProvider, RentalProvider, ExpenseProvider>(
          builder: (context, apartments, rentals, expenses, _) {
            if (apartments.isLoading && apartments.apartments.isEmpty) {
              return const LoadingWidget();
            }

            final totalApartments = apartments.apartments.length;
            final totalIncome = rentals.totalIncome;
            final totalExpenses = expenses.totalExpenses;
            final totalProfit = totalIncome - totalExpenses;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                  isWide ? 32 : 20, 8, isWide ? 32 : 20, 32),
              children: [
                // Header
                Text(
                  loc.welcome,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.overview,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Stat cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = isWide ? 4 : 2;
                    final spacing = 14.0;
                    final cardWidth =
                        (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                            crossAxisCount;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: StatCard(
                            title: loc.totalApartments,
                            value: totalApartments.toString(),
                            icon: Icons.apartment_rounded,
                            color: AppColors.accent,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatCard(
                            title: loc.totalRentalIncome,
                            value: Formatters.currency(totalIncome),
                            icon: Icons.trending_up_rounded,
                            color: AppColors.success,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatCard(
                            title: loc.totalExpenses,
                            value: Formatters.currency(totalExpenses),
                            icon: Icons.trending_down_rounded,
                            color: AppColors.danger,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatCard(
                            title: loc.totalProfits,
                            value: Formatters.currency(totalProfit),
                            icon: Icons.account_balance_wallet_rounded,
                            color: totalProfit >= 0
                                ? AppColors.sky
                                : AppColors.warning,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Chart
                if (totalIncome > 0 || totalExpenses > 0)
                  _buildChart(loc, totalIncome, totalExpenses, isWide),

                if (totalIncome == 0 && totalExpenses == 0) ...[
                  const SizedBox(height: 20),
                  EmptyState(
                    icon: Icons.pie_chart_rounded,
                    titleKey: 'no_data',
                    subtitleKey: 'add_first_apartment',
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _showReportSheet(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final now = DateTime.now();
    DateTime selectedMonth = DateTime(now.year, now.month);

    final months = List.generate(12, (i) {
      final date = DateTime(now.year, now.month - i);
      return date;
    });

    final monthNames = [
      loc.january, loc.february, loc.march, loc.april,
      loc.may, loc.june, loc.july, loc.august,
      loc.september, loc.october, loc.november, loc.december,
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.monthlyReport,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.selectMonth,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<DateTime>(
                        value: selectedMonth,
                        isExpanded: true,
                        items: months.map((date) {
                          return DropdownMenuItem(
                            value: date,
                            child: Text(
                              '${monthNames[date.month - 1]} ${date.year}',
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() => selectedMonth = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _generateAndPreviewReport(context, selectedMonth);
                    },
                    icon: const Icon(Icons.preview_rounded),
                    label: Text(loc.previewReport),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _generateAndPreviewReport(
      BuildContext context, DateTime month) async {
    final apartments = context.read<ApartmentProvider>().apartments;
    final rentals = context.read<RentalProvider>().rentals;
    final expenses = context.read<ExpenseProvider>().expenses;

    final pdfBytes = await PdfReportService.generateMonthlyReport(
      month: month,
      apartments: apartments,
      rentals: rentals,
      expenses: expenses,
    );

    if (!context.mounted) return;

    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => _PdfPreviewScreen(
          pdfBytes: pdfBytes,
          month: month,
        ),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildChart(
      AppLocalizations loc, double totalIncome, double totalExpenses, bool isWide) {
    final total = totalIncome + totalExpenses;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildPieChart(loc, totalIncome, totalExpenses, total),
                ),
                const SizedBox(width: 40),
                Expanded(
                  flex: 2,
                  child: _buildChartDetails(loc, totalIncome, totalExpenses, total),
                ),
              ],
            )
          : Column(
              children: [
                _buildPieChart(loc, totalIncome, totalExpenses, total),
                const SizedBox(height: 20),
                _buildChartDetails(loc, totalIncome, totalExpenses, total),
              ],
            ),
    );
  }

  Widget _buildPieChart(
      AppLocalizations loc, double totalIncome, double totalExpenses, double total) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius: 56,
          sections: [
            if (totalIncome > 0)
              PieChartSectionData(
                value: totalIncome,
                color: AppColors.success,
                title:
                    total > 0 ? '${((totalIncome / total) * 100).toStringAsFixed(0)}%' : '',
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                radius: 50,
              ),
            if (totalExpenses > 0)
              PieChartSectionData(
                value: totalExpenses,
                color: AppColors.danger,
                title:
                    total > 0 ? '${((totalExpenses / total) * 100).toStringAsFixed(0)}%' : '',
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                radius: 50,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartDetails(
      AppLocalizations loc, double totalIncome, double totalExpenses, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chartDetail(
          color: AppColors.success,
          label: loc.income,
          value: Formatters.currency(totalIncome),
          percent: total > 0 ? (totalIncome / total) : 0,
        ),
        const SizedBox(height: 16),
        _chartDetail(
          color: AppColors.danger,
          label: loc.expenses,
          value: Formatters.currency(totalExpenses),
          percent: total > 0 ? (totalExpenses / total) : 0,
        ),
      ],
    );
  }

  Widget _chartDetail({
    required Color color,
    required String label,
    required String value,
    required double percent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(right: 22),
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _PdfPreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  final DateTime month;

  const _PdfPreviewScreen({
    required this.pdfBytes,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final monthName = '${_monthNames[month.month - 1]} ${month.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(monthName),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: AppLocalizations.of(context).shareReport,
            onPressed: () => _sharePdf(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) async => pdfBytes,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: 'report_${month.year}_${month.month}.pdf',
      ),
    );
  }

  Future<void> _sharePdf(BuildContext context) async {
    final monthName = '${_monthNames[month.month - 1]} ${month.year}';
    final xFile = XFile.fromData(
      pdfBytes,
      mimeType: 'application/pdf',
      name: 'report_${month.year}_${month.month}.pdf',
    );
    await Share.shareXFiles(
      [xFile],
      text: 'التقرير الشهري - $monthName',
    );
  }

  static const _monthNames = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];
}
