import 'package:flutter/material.dart';

class AppLocalizations {
  final String locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('ar')];

  String translate(String key) => _strings[key] ?? key;

  // Common
  String get appName => translate('app_name');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get confirm => translate('confirm');
  String get yes => translate('yes');
  String get no => translate('no');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get noData => translate('no_data');
  String get retry => translate('retry');
  String get search => translate('search');
  String get all => translate('all');
  String get total => translate('total');
  String get welcome => translate('welcome');
  String get overview => translate('overview');
  String get quickOverview => translate('quick_overview');

  // Navigation
  String get dashboard => translate('dashboard');
  String get apartments => translate('apartments');
  String get income => translate('income');
  String get expenses => translate('expenses');
  String get logout => translate('logout');
  String get logoutConfirm => translate('logout_confirm');
  String get syncing => translate('syncing');
  String get synced => translate('synced');
  String get pending => translate('pending');
  String get offline => translate('offline');
  String get syncError => translate('sync_error');

  // Dashboard
  String get totalApartments => translate('total_apartments');
  String get totalRentalIncome => translate('total_rental_income');
  String get totalExpenses => translate('total_expenses');
  String get totalProfits => translate('total_profits');

  // Apartments
  String get apartmentName => translate('apartment_name');
  String get apartmentDescription => translate('apartment_description');
  String get addApartment => translate('add_apartment');
  String get editApartment => translate('edit_apartment');
  String get deleteApartment => translate('delete_apartment');
  String get deleteApartmentConfirm =>
      translate('delete_apartment_confirm');
  String get apartmentDetails => translate('apartment_details');
  String get noApartments => translate('no_apartments');
  String get addFirstApartment => translate('add_first_apartment');
  String get netProfit => translate('net_profit');

  // Rentals
  String get rentalType => translate('rental_type');
  String get daily => translate('daily');

  String get monthly => translate('monthly');
  String get amount => translate('amount');
  String get date => translate('date');
  String get numberOfDays => translate('number_of_days');
  String get pricePerDay => translate('price_per_day');
  String get days => translate('days');
  String get addRental => translate('add_rental');
  String get editRental => translate('edit_rental');
  String get deleteRental => translate('delete_rental');
  String get deleteRentalConfirm => translate('delete_rental_confirm');
  String get rentalHistory => translate('rental_history');
  String get noRentals => translate('no_rentals');
  String get apartment => translate('apartment');

  // Expenses
  String get expenseType => translate('expense_type');
  String get addExpense => translate('add_expense');
  String get editExpense => translate('edit_expense');
  String get deleteExpense => translate('delete_expense');
  String get deleteExpenseConfirm => translate('delete_expense_confirm');
  String get expenseHistory => translate('expense_history');
  String get noExpenses => translate('no_expenses');
  String get maintenance => translate('maintenance');
  String get electricity => translate('electricity');
  String get water => translate('water');
  String get internet => translate('internet');
  String get cleaning => translate('cleaning');
  String get repair => translate('repair');
  String get insurance => translate('insurance');
  String get tax => translate('tax');
  String get other => translate('other');

  // Forms
  String get nameRequired => translate('name_required');
  String get amountRequired => translate('amount_required');
  String get dateRequired => translate('date_required');
  String get selectApartment => translate('select_apartment');
  String get selectRentalType => translate('select_rental_type');
  String get selectExpenseType => translate('select_expense_type');
  String get enterAmount => translate('enter_amount');
  String get enterName => translate('enter_name');
  String get enterDescription => translate('enter_description');

  // Reports
  String get monthlyReport => translate('monthly_report');
  String get generateReport => translate('generate_report');
  String get selectMonth => translate('select_month');
  String get reportSummary => translate('report_summary');
  String get incomeBreakdown => translate('income_breakdown');
  String get expenseBreakdown => translate('expense_breakdown');
  String get netProfitLabel => translate('net_profit_label');
  String get apartmentsCount => translate('apartments_count');
  String get reportPeriod => translate('report_period');
  String get generatedOn => translate('generated_on');
  String get shareReport => translate('share_report');
  String get previewReport => translate('preview_report');
  String get noDataForMonth => translate('no_data_for_month');
  String get january => translate('january');
  String get february => translate('february');
  String get march => translate('march');
  String get april => translate('april');
  String get may => translate('may');
  String get june => translate('june');
  String get july => translate('july');
  String get august => translate('august');
  String get september => translate('september');
  String get october => translate('october');
  String get november => translate('november');
  String get december => translate('december');

  static const Map<String, String> _strings = {
    'app_name': 'إيجار الشقق',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'delete': 'حذف',
    'edit': 'تعديل',
    'add': 'إضافة',
    'confirm': 'تأكيد',
    'yes': 'نعم',
    'no': 'لا',
    'loading': 'جاري التحميل...',
    'error': 'خطأ',
    'success': 'نجاح',
    'no_data': 'لا توجد بيانات',
    'retry': 'إعادة المحاولة',
    'search': 'بحث',
    'all': 'الكل',
    'total': 'المجموع',
    'welcome': 'مرحباً',
    'overview': 'نظرة عامة على أعمال الإيجار',
    'quick_overview': 'الدخل مقابل المصروفات',

    'dashboard': 'لوحة التحكم',
    'apartments': 'الشقق',
    'income': 'الدخل',
    'expenses': 'المصروفات',
    'logout': 'تسجيل خروج',
    'logout_confirm': 'هل أنت متأكد من تسجيل الخروج؟',
    'syncing': 'جاري المزامنة...',
    'synced': 'متزامن',
    'pending': 'معلّق',
    'offline': 'غير متصل',
    'sync_error': 'خطأ في المزامنة',

    'total_apartments': 'إجمالي الشقق',
    'total_rental_income': 'إجمالي دخل الإيجار',
    'total_expenses': 'إجمالي المصروفات',
    'total_profits': 'إجمالي الأرباح',

    'apartment_name': 'اسم الشقة',
    'apartment_description': 'الوصف',
    'add_apartment': 'إضافة شقة',
    'edit_apartment': 'تعديل الشقة',
    'delete_apartment': 'حذف الشقة',
    'delete_apartment_confirm': 'هل أنت متأكد من حذف هذه الشقة وجميع سجلاتها؟',
    'apartment_details': 'تفاصيل الشقة',
    'no_apartments': 'لا توجد شقق بعد',
    'add_first_apartment': 'أضف شقتك الأولى للبدء',
    'net_profit': 'صافي الربح',

    'rental_type': 'نوع الإيجار',
    'daily': 'يومي',

    'monthly': 'شهري',
    'amount': 'المبلغ',
    'date': 'التاريخ',
    'number_of_days': 'عدد الأيام',
    'price_per_day': 'سعر اليوم',
    'days': 'أيام',
    'add_rental': 'إضافة إيجار',
    'edit_rental': 'تعديل الإيجار',
    'delete_rental': 'حذف الإيجار',
    'delete_rental_confirm': 'هل أنت متأكد من حذف سجل الإيجار هذا؟',
    'rental_history': 'سجل الإيجار',
    'no_rentals': 'لا توجد سجلات إيجار بعد',
    'apartment': 'الشقة',

    'expense_type': 'نوع المصروف',
    'add_expense': 'إضافة مصروف',
    'edit_expense': 'تعديل المصروف',
    'delete_expense': 'حذف المصروف',
    'delete_expense_confirm': 'هل أنت متأكد من حذف هذا المصروف؟',
    'expense_history': 'سجل المصروفات',
    'no_expenses': 'لا توجد مصروفات بعد',
    'maintenance': 'صيانة',
    'electricity': 'كهرباء',
    'water': 'مياه',
    'internet': 'إنترنت',
    'cleaning': 'تنظيف',
    'repair': 'إصلاح',
    'insurance': 'تأمين',
    'tax': 'ضريبة',
    'other': 'أخرى',

    'name_required': 'الاسم مطلوب',
    'amount_required': 'المبلغ مطلوب',
    'date_required': 'التاريخ مطلوب',
    'select_apartment': 'اختر الشقة',
    'select_rental_type': 'اختر نوع الإيجار',
    'select_expense_type': 'اختر نوع المصروف',
    'enter_amount': 'أدخل المبلغ',
    'enter_name': 'أدخل الاسم',
    'enter_description': 'أدخل الوصف (اختياري)',

    'monthly_report': 'تقرير شهري',
    'generate_report': 'إنشاء التقرير',
    'select_month': 'اختر الشهر',
    'report_summary': 'ملخص التقرير',
    'income_breakdown': 'تفاصيل الدخل',
    'expense_breakdown': 'تفاصيل المصروفات',
    'net_profit_label': 'صافي الربح',
    'apartments_count': 'عدد الشقق',
    'report_period': 'الفترة',
    'generated_on': 'تاريخ الإنشاء',
    'share_report': 'مشاركة التقرير',
    'preview_report': 'معاينة التقرير',
    'no_data_for_month': 'لا توجد بيانات لهذا الشهر',
    'january': 'يناير',
    'february': 'فبراير',
    'march': 'مارس',
    'april': 'أبريل',
    'may': 'مايو',
    'june': 'يونيو',
    'july': 'يوليو',
    'august': 'أغسطس',
    'september': 'سبتمبر',
    'october': 'أكتوبر',
    'november': 'نوفمبر',
    'december': 'ديسمبر',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale.languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
