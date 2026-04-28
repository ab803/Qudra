import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(const LanguageInitial());

  void changeLanguage(String code) {
    final newLocale = Locale(code);

    if (state.locale == newLocale) return;

    emit(LanguageChanged(newLocale));
  }
}