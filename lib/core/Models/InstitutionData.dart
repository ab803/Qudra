import 'package:flutter/material.dart';

class InstitutionData {
  final String title;
  final String category;
  final double rating;
  final String distance;
  final String description;
  final List<String> tags;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  InstitutionData({
    required this.title,
    required this.category,
    required this.rating,
    required this.distance,
    required this.description,
    required this.tags,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}