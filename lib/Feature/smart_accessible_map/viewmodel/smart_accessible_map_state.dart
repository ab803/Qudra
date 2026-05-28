import 'package:latlong2/latlong.dart';

import '../models/smart_place_model.dart';

abstract class SmartAccessibleMapState {
  const SmartAccessibleMapState();
}

class SmartAccessibleMapInitial extends SmartAccessibleMapState {
  const SmartAccessibleMapInitial();
}

class SmartAccessibleMapLoading extends SmartAccessibleMapState {
  const SmartAccessibleMapLoading();
}

class SmartAccessibleMapLoaded extends SmartAccessibleMapState {
  final LatLng userLocation;
  final List<SmartPlaceModel> allPlaces;
  final SmartPlaceCategory selectedCategory;
  final bool accessibleOnly;
  final int radiusMeters;

  const SmartAccessibleMapLoaded({
    required this.userLocation,
    required this.allPlaces,
    required this.selectedCategory,
    required this.accessibleOnly,
    required this.radiusMeters,
  });

  // This getter returns places filtered by category and accessibility preference.
  List<SmartPlaceModel> get visiblePlaces {
    Iterable<SmartPlaceModel> filtered = allPlaces;

    if (selectedCategory != SmartPlaceCategory.all) {
      filtered = filtered.where(
            (place) => place.category == selectedCategory,
      );
    }

    if (accessibleOnly) {
      filtered = filtered.where(
            (place) => place.hasPositiveAccessibility,
      );
    }

    return filtered.toList();
  }

  // This getter returns whether the loaded result has no places after active filters.
  bool get isVisibleListEmpty => visiblePlaces.isEmpty;

  // This getter returns whether the fetched source returned no places at all.
  bool get hasNoFetchedPlaces => allPlaces.isEmpty;

  SmartAccessibleMapLoaded copyWith({
    LatLng? userLocation,
    List<SmartPlaceModel>? allPlaces,
    SmartPlaceCategory? selectedCategory,
    bool? accessibleOnly,
    int? radiusMeters,
  }) {
    return SmartAccessibleMapLoaded(
      userLocation: userLocation ?? this.userLocation,
      allPlaces: allPlaces ?? this.allPlaces,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      accessibleOnly: accessibleOnly ?? this.accessibleOnly,
      radiusMeters: radiusMeters ?? this.radiusMeters,
    );
  }
}

class SmartAccessibleMapPermissionDenied extends SmartAccessibleMapState {
  final String messageKey;

  const SmartAccessibleMapPermissionDenied({
    this.messageKey = 'smart_map_location_permission_denied',
  });
}

class SmartAccessibleMapLocationServiceDisabled
    extends SmartAccessibleMapState {
  final String messageKey;

  const SmartAccessibleMapLocationServiceDisabled({
    this.messageKey = 'smart_map_location_service_disabled',
  });
}

class SmartAccessibleMapError extends SmartAccessibleMapState {
  final String messageKey;
  final String? debugMessage;

  const SmartAccessibleMapError({
    required this.messageKey,
    this.debugMessage,
  });
}
