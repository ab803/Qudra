import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

class AppTextStyles{
  static final TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Appcolors.primaryColor,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Appcolors.secondaryColor,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: Appcolors.secondaryColor,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Appcolors.butnColor,
  );

  static final TextStyle slogan = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Appcolors.secondaryColor,
  );

}