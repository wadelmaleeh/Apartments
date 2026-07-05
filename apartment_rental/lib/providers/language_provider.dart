import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale get locale => const Locale('ar');
  bool get isArabic => true;
  TextDirection get textDirection => TextDirection.rtl;
}
