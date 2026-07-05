import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';
import '../../main.dart';
import 'dashboard/dashboard_screen.dart';
import 'apartments/apartments_screen.dart';
import 'income/income_screen.dart';
import 'expenses/expenses_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    ApartmentsScreen(),
    IncomeScreen(),
    ExpensesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isWide = MediaQuery.of(context).size.width > 700;

    if (isWide) {
      return _buildDesktop(loc);
    }
    return _buildMobile(loc);
  }

  Widget _buildMobile(AppLocalizations loc) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, loc.dashboard),
                _buildNavItem(1, Icons.apartment_rounded, loc.apartments),
                _buildNavItem(2, Icons.trending_up_rounded, loc.income),
                _buildNavItem(3, Icons.trending_down_rounded, loc.expenses),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppColors.accent : AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.accent : AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(AppLocalizations loc) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              children: [
                const SizedBox(height: 36),
                // Logo
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.sky],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.apartment_rounded,
                          color: Colors.white, size: 26),
                      const SizedBox(width: 12),
                      Text(
                        'إيجار الشقق',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                // Nav items
                _buildDesktopNav(
                    0, Icons.dashboard_rounded, loc.dashboard),
                _buildDesktopNav(
                    1, Icons.apartment_rounded, loc.apartments),
                _buildDesktopNav(
                    2, Icons.trending_up_rounded, loc.income),
                _buildDesktopNav(
                    3, Icons.trending_down_rounded, loc.expenses),
                const Spacer(),
                // Version
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
    );
  }

  Widget _buildDesktopNav(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _currentIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.35),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.35),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
