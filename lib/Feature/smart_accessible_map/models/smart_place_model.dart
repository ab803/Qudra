import 'package:latlong2/latlong.dart';

// This enum defines the smart map place categories shown in the filters.
enum SmartPlaceCategory {
  all,
  food,
  healthcare,
  pharmacy,
  transport,
}

// This enum defines the accessibility status extracted from OpenStreetMap tags.
enum SmartAccessibilityStatus {
  accessible,
  limited,
  notAccessible,
  unknown,
}

// This extension converts place categories into stable UI/filter values.
extension SmartPlaceCategoryX on SmartPlaceCategory {
  String get value {
    switch (this) {
      case SmartPlaceCategory.all:
        return 'all';
      case SmartPlaceCategory.food:
        return 'food';
      case SmartPlaceCategory.healthcare:
        return 'healthcare';
      case SmartPlaceCategory.pharmacy:
        return 'pharmacy';
      case SmartPlaceCategory.transport:
        return 'transport';
    }
  }

  // This helper returns the localization key used by the UI.
  String get labelKey {
    switch (this) {
      case SmartPlaceCategory.all:
        return 'smart_map_filter_all';
      case SmartPlaceCategory.food:
        return 'smart_map_filter_food';
      case SmartPlaceCategory.healthcare:
        return 'smart_map_filter_healthcare';
      case SmartPlaceCategory.pharmacy:
        return 'smart_map_filter_pharmacy';
      case SmartPlaceCategory.transport:
        return 'smart_map_filter_transport';
    }
  }
}

// This extension provides labels and ranking priority for accessibility status.
extension SmartAccessibilityStatusX on SmartAccessibilityStatus {
  String get labelKey {
    switch (this) {
      case SmartAccessibilityStatus.accessible:
        return 'smart_map_accessible';
      case SmartAccessibilityStatus.limited:
        return 'smart_map_limited_access';
      case SmartAccessibilityStatus.notAccessible:
        return 'smart_map_not_accessible';
      case SmartAccessibilityStatus.unknown:
        return 'smart_map_unknown_accessibility';
    }
  }

  // This priority is used to sort accessible places before unknown places.
  int get priority {
    switch (this) {
      case SmartAccessibilityStatus.accessible:
        return 0;
      case SmartAccessibilityStatus.limited:
        return 1;
      case SmartAccessibilityStatus.unknown:
        return 2;
      case SmartAccessibilityStatus.notAccessible:
        return 3;
    }
  }
}

class SmartPlaceModel {
  final String id;
  final String osmType;
  final String name;
  final SmartPlaceCategory category;
  final SmartAccessibilityStatus accessibilityStatus;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final String? address;
  final String? phone;
  final String? website;
  final String? openingHours;
  final String? wheelchairDescription;
  final Map<String, dynamic> rawTags;

  const SmartPlaceModel({
    required this.id,
    required this.osmType,
    required this.name,
    required this.category,
    required this.accessibilityStatus,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.address,
    this.phone,
    this.website,
    this.openingHours,
    this.wheelchairDescription,
    this.rawTags = const {},
  });

  // This getter returns the map coordinate used by flutter_map markers.
  LatLng get point => LatLng(latitude, longitude);

  // This getter returns true when the place has confirmed or partial accessibility information.
  bool get hasPositiveAccessibility =>
      accessibilityStatus == SmartAccessibilityStatus.accessible ||
          accessibilityStatus == SmartAccessibilityStatus.limited;

  // This getter returns true when the place has an external website.
  bool get hasWebsite => website != null && website!.trim().isNotEmpty;

  SmartPlaceModel copyWith({
    String? id,
    String? osmType,
    String? name,
    SmartPlaceCategory? category,
    SmartAccessibilityStatus? accessibilityStatus,
    double? latitude,
    double? longitude,
    double? distanceKm,
    String? address,
    String? phone,
    String? website,
    String? openingHours,
    String? wheelchairDescription,
    Map<String, dynamic>? rawTags,
  }) {
    return SmartPlaceModel(
      id: id ?? this.id,
      osmType: osmType ?? this.osmType,
      name: name ?? this.name,
      category: category ?? this.category,
      accessibilityStatus: accessibilityStatus ?? this.accessibilityStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      wheelchairDescription:
      wheelchairDescription ?? this.wheelchairDescription,
      rawTags: rawTags ?? this.rawTags,
    );
  }
}