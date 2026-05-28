import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/smart_place_model.dart';
import '../services/overpass_places_service.dart';
import 'smart_accessible_map_state.dart';

class SmartAccessibleMapCubit extends Cubit<SmartAccessibleMapState> {
  final OverpassPlacesService _placesService;

  SmartAccessibleMapCubit({
    OverpassPlacesService? placesService,
  })  : _placesService = placesService ?? OverpassPlacesService(),
        super(const SmartAccessibleMapInitial());

  List<SmartPlaceModel> _allPlaces = [];
  LatLng? _userLocation;

  SmartPlaceCategory _selectedCategory = SmartPlaceCategory.all;
  bool _accessibleOnly = false;

  // This radius is intentionally small by default to keep the first mobile load fast.
  int _radiusMeters = 1500;

  // This getter exposes all available smart map category filters to the UI.
  List<SmartPlaceCategory> get availableCategories => const [
    SmartPlaceCategory.all,
    SmartPlaceCategory.food,
    SmartPlaceCategory.healthcare,
    SmartPlaceCategory.pharmacy,
    SmartPlaceCategory.transport,
  ];

  // This method loads nearby public places around the user's current location.
  Future<void> loadNearbyPlaces({
    int radiusMeters = 1500,
  }) async {
    emit(const SmartAccessibleMapLoading());

    _radiusMeters = radiusMeters;

    try {
      final locationResult = await _getCurrentUserLocation().timeout(
        const Duration(seconds: 8),
      );

      if (locationResult == null) {
        return;
      }

      _userLocation = locationResult;

      final places = await _placesService.fetchNearbyPlaces(
        latitude: locationResult.latitude,
        longitude: locationResult.longitude,
        radiusMeters: _radiusMeters,
      );

      _allPlaces = places;

      _emitLoadedState();
    } catch (e) {
      // This debug print helps identify the real mobile/web request issue.
      // ignore: avoid_print
      print('SMART_MAP_ERROR: $e');

      // This fallback keeps the map screen usable instead of showing retry forever.
      if (_userLocation != null) {
        _allPlaces = <SmartPlaceModel>[];
        _emitLoadedState();
        return;
      }

      emit(
        SmartAccessibleMapError(
          messageKey: 'smart_map_failed_load_places',
          debugMessage: e.toString(),
        ),
      );
    }
  }

  // This method refreshes nearby places using the last selected radius.
  Future<void> refresh() async {
    await loadNearbyPlaces(radiusMeters: _radiusMeters);
  }

  // This method changes the selected category filter without refetching data.
  void selectCategory(SmartPlaceCategory category) {
    _selectedCategory = category;
    _emitLoadedState();
  }

  // This method toggles whether only accessible and partially accessible places are shown.
  void toggleAccessibleOnly(bool value) {
    _accessibleOnly = value;
    _emitLoadedState();
  }

  // This method updates the search radius and fetches places again.
  Future<void> changeRadius(int radiusMeters) async {
    if (_radiusMeters == radiusMeters && state is SmartAccessibleMapLoaded) {
      return;
    }

    await loadNearbyPlaces(radiusMeters: radiusMeters);
  }

  // This helper emits a loaded state if the current location is available.
  void _emitLoadedState() {
    final currentLocation = _userLocation;

    if (currentLocation == null) {
      emit(
        const SmartAccessibleMapError(
          messageKey: 'smart_map_location_unavailable',
        ),
      );
      return;
    }

    emit(
      SmartAccessibleMapLoaded(
        userLocation: currentLocation,
        allPlaces: List<SmartPlaceModel>.unmodifiable(_allPlaces),
        selectedCategory: _selectedCategory,
        accessibleOnly: _accessibleOnly,
        radiusMeters: _radiusMeters,
      ),
    );
  }

  // This helper checks location service and permissions, then returns the user's current coordinates.
  Future<LatLng?> _getCurrentUserLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      emit(const SmartAccessibleMapLocationServiceDisabled());
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      emit(const SmartAccessibleMapPermissionDenied());
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      emit(
        const SmartAccessibleMapPermissionDenied(
          messageKey: 'smart_map_location_permission_denied_forever',
        ),
      );
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  }
}