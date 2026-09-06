import 'package:flutter/widgets.dart';

class LanguageState {
  final Locale locale;
  const LanguageState(this.locale);

  bool get isBengali => locale.languageCode == 'bn';
  bool get isEnglish => locale.languageCode == 'en';
}
