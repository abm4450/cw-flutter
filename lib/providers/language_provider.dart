import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('ar'));

  void toggle() {
    state = state.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
  }

  void setLocale(Locale locale) {
    state = locale;
  }

  bool get isArabic => state.languageCode == 'ar';
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>(
  (ref) => LanguageNotifier(),
);
