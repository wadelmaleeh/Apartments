import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/apartment.dart';
import '../models/rental.dart';
import '../models/expense.dart';

class PdfReportService {
  static Future<Uint8List> generateMonthlyReport({
    required DateTime month,
    required List<Apartment> apartments,
    required List<Rental> rentals,
    required List<Expense> expenses,
  }) async {
    // Load Arabic font
    final fontData = await rootBundle.load('assets/fonts/NotoSansArabic.ttf');
    final ttf = pw.Font.ttf(fontData);

    // Create PDF document
    final pdf = pw.Document();

    // Filter data for the selected month
    final startDate = DateTime(month.year, month.month, 1);
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;
    final endDate = isCurrentMonth 
        ? now 
        : DateTime(month.year, month.month + 1, 0);

    final monthRentals = rentals.where((r) {
      return r.date.year == month.year && r.date.month == month.month;
    }).toList();

    final monthExpenses = expenses.where((e) {
      return e.date.year == month.year && e.date.month == month.month;
    }).toList();

    // Calculate totals
    final totalIncome = monthRentals.fold(0.0, (sum, r) => sum + r.amount);
    final totalExpenses = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final netProfit = totalIncome - totalExpenses;

    // Create apartment name map
    final apartmentMap = {for (var a in apartments) a.id: a.name};

    // Format dates for display
    final monthNames = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final monthName = monthNames[month.month - 1];
    final dateRange = '${startDate.day} - ${endDate.day} $monthName ${month.year}';

    // Add page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: ttf),
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          _buildHeader(ttf, monthName, month.year, dateRange),
          pw.SizedBox(height: 30),

          // Summary cards
          _buildSummary(ttf, totalIncome, totalExpenses, netProfit, apartments.length),
          pw.SizedBox(height: 30),

          // Income table
          if (monthRentals.isNotEmpty) ...[
            _buildIncomeTable(ttf, monthRentals, apartmentMap),
            pw.SizedBox(height: 25),
          ],

          // Expenses table
          if (monthExpenses.isNotEmpty) ...[
            _buildExpensesTable(ttf, monthExpenses, apartmentMap),
            pw.SizedBox(height: 25),
          ],

          // Empty state
          if (monthRentals.isEmpty && monthExpenses.isEmpty)
            _buildEmptyState(ttf),
        ],
        footer: (context) => _buildFooter(ttf, context),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.Font font, String monthName, int year, String dateRange) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'التقرير المالي الشهري',
            style: pw.TextStyle(
              font: font,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '$monthName $year',
            style: pw.TextStyle(
              font: font,
              fontSize: 18,
              color: PdfColors.blue700,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              dateRange,
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                color: PdfColors.blue900,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Divider(thickness: 2, color: PdfColors.blue700),
      ],
    );
  }

  static pw.Widget _buildSummary(
    pw.Font font,
    double income,
    double expenses,
    double profit,
    int apartmentCount,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'الملخص المالي',
              style: pw.TextStyle(
                font: font,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard(
                  font,
                  'صافي الربح',
                  _formatCurrency(profit),
                  profit >= 0 ? PdfColors.green700 : PdfColors.red700,
                ),
                _buildSummaryCard(font, 'إجمالي المصروفات', _formatCurrency(expenses), PdfColors.red600),
                _buildSummaryCard(font, 'إجمالي الدخل', _formatCurrency(income), PdfColors.green600),
                _buildSummaryCard(font, 'عدد الشقق', apartmentCount.toString(), PdfColors.blue600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCard(pw.Font font, String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        margin: const pw.EdgeInsets.symmetric(horizontal: 4),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: color, width: 1.5),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: PdfColors.grey700,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildIncomeTable(
    pw.Font font,
    List<Rental> rentals,
    Map<String, String> apartmentMap,
  ) {
    // Sort by date (newest first)
    rentals.sort((a, b) => b.date.compareTo(a.date));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'تفاصيل الدخل',
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green700,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            defaultColumnWidth: const pw.FlexColumnWidth(),
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.green50),
                children: [
                  _buildTableHeader(font, 'الشقة'),
                  _buildTableHeader(font, 'النوع'),
                  _buildTableHeader(font, 'المبلغ'),
                  _buildTableHeader(font, 'الأيام'),
                  _buildTableHeader(font, 'المجموع'),
                ],
              ),
              // Data rows
              ...rentals.map((rental) {
                final apartmentName = apartmentMap[rental.apartmentId] ?? 'غير معروف';
                final rentalTypeAr = _getRentalTypeArabic(rental.rentalType);
                final total = rental.amount * rental.days;
                // Show "-" for days if rental type is monthly
                final daysText = rental.rentalType == RentalType.monthly 
                    ? '-' 
                    : rental.days.toString();
                
                return pw.TableRow(
                  children: [
                    _buildTableCell(font, apartmentName),
                    _buildTableCell(font, rentalTypeAr),
                    _buildTableCell(font, _formatCurrency(rental.amount)),
                    _buildTableCell(font, daysText),
                    _buildTableCell(font, _formatCurrency(total)),
                  ],
                );
              }),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'الإجمالي: ${_formatCurrency(rentals.fold(0.0, (sum, r) => sum + (r.amount * r.days)))}',
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green700,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildExpensesTable(
    pw.Font font,
    List<Expense> expenses,
    Map<String, String> apartmentMap,
  ) {
    // Sort by date (newest first)
    expenses.sort((a, b) => b.date.compareTo(a.date));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'تفاصيل المصروفات',
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red700,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            defaultColumnWidth: const pw.FlexColumnWidth(),
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.red50),
                children: [
                  _buildTableHeader(font, 'الشقة'),
                  _buildTableHeader(font, 'النوع'),
                  _buildTableHeader(font, 'المبلغ'),
                  _buildTableHeader(font, 'التاريخ'),
                ],
              ),
              // Data rows
              ...expenses.map((expense) {
                final apartmentName = apartmentMap[expense.apartmentId] ?? 'غير معروف';
                final expenseTypeAr = _getExpenseTypeArabic(expense.expenseType);
                final dateStr = DateFormat('d/M/yyyy').format(expense.date);
                
                return pw.TableRow(
                  children: [
                    _buildTableCell(font, apartmentName),
                    _buildTableCell(font, expenseTypeAr),
                    _buildTableCell(font, _formatCurrency(expense.amount)),
                    _buildTableCell(font, dateStr),
                  ],
                );
              }),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'الإجمالي: ${_formatCurrency(expenses.fold(0.0, (sum, e) => sum + e.amount))}',
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red700,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(pw.Font font, String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
        textDirection: pw.TextDirection.rtl,
      ),
    );
  }

  static pw.Widget _buildTableCell(pw.Font font, String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 9,
        ),
        textDirection: pw.TextDirection.rtl,
      ),
    );
  }

  static pw.Widget _buildEmptyState(pw.Font font) {
    return pw.Center(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Text(
          'لا توجد بيانات لهذا الشهر',
          style: pw.TextStyle(
            font: font,
            fontSize: 14,
            color: PdfColors.grey600,
          ),
          textDirection: pw.TextDirection.rtl,
        ),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font font, pw.Context context) {
    final now = DateTime.now();
    final dateStr = DateFormat('d MMMM yyyy - HH:mm', 'ar').format(now);
    
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'تم الإنشاء: $dateStr',
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
                color: PdfColors.grey600,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
            pw.Text(
              'صفحة ${context.pageNumber} من ${context.pagesCount}',
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
                color: PdfColors.grey600,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'ar');
    return '${formatter.format(amount)} جنيه';
  }

  static String _getRentalTypeArabic(RentalType type) {
    switch (type) {
      case RentalType.monthly:
        return 'شهري';
      case RentalType.daily:
        return 'يومي';
    }
  }

  static String _getExpenseTypeArabic(String type) {
    const expenseTypeMap = {
      'maintenance': 'صيانة',
      'electricity': 'كهرباء',
      'water': 'مياه',
      'internet': 'إنترنت',
      'cleaning': 'تنظيف',
      'repair': 'إصلاح',
      'insurance': 'تأمين',
      'tax': 'ضريبة',
      'other': 'أخرى',
    };
    return expenseTypeMap[type] ?? type;
  }
}
