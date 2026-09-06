import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const String _prefKey = 'selected_language_code';

  LanguageBloc() : super(const LanguageState(Locale('bn'))) {
    on<LoadSavedLanguageEvent>(_onLoadSavedLanguage);
    on<ChangeLanguageEvent>(_onChangeLanguage);
  }

  Future<void> _onLoadSavedLanguage(
    LoadSavedLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey) ?? 'bn';
      emit(LanguageState(Locale(code)));
    } catch (_) {
      emit(const LanguageState(Locale('bn')));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, event.languageCode);
      emit(LanguageState(Locale(event.languageCode)));
    } catch (_) {
      emit(LanguageState(Locale(event.languageCode)));
    }
  }
}
