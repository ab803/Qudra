import 'package:flutter/material.dart';

abstract class LanguageState {
  final Locale locale;

  const LanguageState(this.locale);
}

class LanguageInitial extends LanguageState {
  const LanguageInitial() : super(const Locale('en'));
}

class LanguageChanged extends LanguageState {
  const LanguageChanged(Locale locale) : super(locale);
}