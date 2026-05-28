import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import '../models/smart_place_model.dart';

class OverpassPlacesService {
  final Dio _dio;

  OverpassPlacesService({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
          sendTimeout: const Duration(seconds: 8),
          headers: const {
            'User-Agent': 'Qudra Smart Accessible Map/1.0',
            'Accept': 'application/json',
          },
        ),
      );

  // This endpoint is the public Overpass API endpoint for querying OpenStreetMap data.
  static const String _overpassEndpoint =
      'https://overpass-api.de/api/interpreter';

  // This helper calculates distance between the user and a place.
  final Distance _distance = const Distance();

  // This method fetches nearby places using a small fast radius first.
  Future<List<SmartPlaceModel>> fetchNearbyPlaces({
    required double latitude,
    required double longitude,
    int radiusMeters = 1500,
  }) async {
    final candidateRadii = <int>[
      radiusMeters,
      1000,
    ].toSet().toList();

    Object? lastError;

    for (final radius in candidateRadii) {
      try {
        final query = _buildOverpassQuery(
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radius,
        );

        final response = await _dio
            .post(
          _overpassEndpoint,
          data: {
            'data': query,
          },
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            responseType: ResponseType.plain,
            receiveDataWhenStatusError: true,
            validateStatus: (status) {
              return status != null && status >= 200 && status < 300;
            },
          ),
        )
            .timeout(const Duration(seconds: 14));

        final decodedData = _decodeResponse(response.data);

        if (decodedData == null) {
          continue;
        }

        final elements = decodedData['elements'];

        if (elements is! List) {
          continue;
        }

        final userPoint = LatLng(latitude, longitude);
        final Map<String, SmartPlaceModel> uniquePlaces = {};

        for (final element in elements) {
          if (element is! Map) continue;

          final normalizedElement = Map<String, dynamic>.from(element);
          final place = _parseElement(normalizedElement, userPoint);

          if (place == null) continue;

          uniquePlaces[place.id] = place;
        }

        final places = uniquePlaces.values.toList();

        places.sort(_comparePlacesByAccessibilityThenDistance);

        return places;
      } catch (e) {
        lastError = e;
      }
    }

    // This fallback prevents the screen from getting stuck or showing retry forever.
    // ignore: avoid_print
    print('SMART_MAP_OVERPASS_FALLBACK_EMPTY: $lastError');

    return <SmartPlaceModel>[];
  }

  // This method returns only places matching a selected category.
  List<SmartPlaceModel> filterByCategory({
    required List<SmartPlaceModel> places,
    required SmartPlaceCategory category,
  }) {
    if (category == SmartPlaceCategory.all) {
      return List<SmartPlaceModel>.from(places);
    }

    return places.where((place) => place.category == category).toList();
  }

  // This method returns only places that have confirmed or partial accessibility.
  List<SmartPlaceModel> accessibleOnly(List<SmartPlaceModel> places) {
    return places.where((place) => place.hasPositiveAccessibility).toList();
  }

  // This helper builds a lighter Overpass QL query for nearby food, healthcare, pharmacy, and transport places.
  String _buildOverpassQuery({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) {
    return '''
[out:json][timeout:10];
(
  node["amenity"~"^(restaurant|cafe|fast_food|hospital|clinic|doctors|pharmacy|bus_station)\$"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"~"^(restaurant|cafe|fast_food|hospital|clinic|doctors|pharmacy|bus_station)\$"](around:$radiusMeters,$latitude,$longitude);

  node["highway"="bus_stop"](around:$radiusMeters,$latitude,$longitude);

  node["public_transport"~"^(platform|station)\$"](around:$radiusMeters,$latitude,$longitude);

  node["railway"~"^(station|halt|tram_stop)\$"](around:$radiusMeters,$latitude,$longitude);
);
out center tags;
''';
  }

  // This helper decodes Overpass API responses even when Dio returns plain text.
  Map<String, dynamic>? _decodeResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }

    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }

    if (responseData is String) {
      final trimmed = responseData.trim();

      if (trimmed.isEmpty) return null;

      final decoded = jsonDecode(trimmed);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    return null;
  }

  // This helper parses one Overpass element into a SmartPlaceModel.
  SmartPlaceModel? _parseElement(
      Map<String, dynamic> element,
      LatLng userPoint,
      ) {
    final tags = _normalizeTags(element['tags']);

    if (tags.isEmpty) return null;

    final point = _extractPoint(element);

    if (point == null) return null;

    final category = _categoryFromTags(tags);

    if (category == null) return null;

    final id = '${element['type'] ?? 'osm'}_${element['id'] ?? ''}';
    final osmType = (element['type'] ?? 'unknown').toString();

    final name = _extractName(tags, category);
    final address = _buildAddress(tags);

    final phone = _firstNonEmpty([
      tags['phone'],
      tags['contact:phone'],
    ]);

    final website = _firstNonEmpty([
      tags['website'],
      tags['contact:website'],
      tags['url'],
    ]);

    final openingHours = _firstNonEmpty([
      tags['opening_hours'],
    ]);

    final wheelchairDescription = _firstNonEmpty([
      tags['wheelchair:description'],
      tags['wheelchair:description:en'],
    ]);

    final distanceKm = _distance.as(
      LengthUnit.Kilometer,
      userPoint,
      point,
    );

    return SmartPlaceModel(
      id: id,
      osmType: osmType,
      name: name,
      category: category,
      accessibilityStatus: _accessibilityFromTags(tags),
      latitude: point.latitude,
      longitude: point.longitude,
      distanceKm: distanceKm,
      address: address,
      phone: phone,
      website: website,
      openingHours: openingHours,
      wheelchairDescription: wheelchairDescription,
      rawTags: tags,
    );
  }

  // This helper normalizes OSM tags into Map<String, dynamic>.
  Map<String, dynamic> _normalizeTags(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
            (key, val) => MapEntry(key.toString(), val),
      );
    }

    return <String, dynamic>{};
  }

  // This helper extracts latitude and longitude from node or way center.
  LatLng? _extractPoint(Map<String, dynamic> element) {
    final lat = _toDouble(element['lat']);
    final lon = _toDouble(element['lon']);

    if (lat != null && lon != null) {
      return LatLng(lat, lon);
    }

    final center = element['center'];

    if (center is Map) {
      final centerLat = _toDouble(center['lat']);
      final centerLon = _toDouble(center['lon']);

      if (centerLat != null && centerLon != null) {
        return LatLng(centerLat, centerLon);
      }
    }

    return null;
  }

  // This helper converts dynamic numeric values to double safely.
  double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    if (value is num) return value.toDouble();

    if (value is String) return double.tryParse(value.trim());

    return null;
  }

  // This helper identifies the smart map category from OSM tags.
  SmartPlaceCategory? _categoryFromTags(Map<String, dynamic> tags) {
    final amenity = _tag(tags, 'amenity');
    final highway = _tag(tags, 'highway');
    final publicTransport = _tag(tags, 'public_transport');
    final railway = _tag(tags, 'railway');

    if (amenity == 'restaurant' ||
        amenity == 'cafe' ||
        amenity == 'fast_food') {
      return SmartPlaceCategory.food;
    }

    if (amenity == 'hospital' || amenity == 'clinic' || amenity == 'doctors') {
      return SmartPlaceCategory.healthcare;
    }

    if (amenity == 'pharmacy') {
      return SmartPlaceCategory.pharmacy;
    }

    if (amenity == 'bus_station' ||
        highway == 'bus_stop' ||
        publicTransport == 'platform' ||
        publicTransport == 'station' ||
        railway == 'station' ||
        railway == 'halt' ||
        railway == 'tram_stop') {
      return SmartPlaceCategory.transport;
    }

    return null;
  }

  // This helper extracts accessibility status from OSM wheelchair/ramp tags.
  SmartAccessibilityStatus _accessibilityFromTags(Map<String, dynamic> tags) {
    final wheelchair = _tag(tags, 'wheelchair');
    final ramp = _tag(tags, 'ramp');

    if (wheelchair == 'yes' ||
        wheelchair == 'designed' ||
        wheelchair == 'designated' ||
        ramp == 'yes') {
      return SmartAccessibilityStatus.accessible;
    }

    if (wheelchair == 'limited') {
      return SmartAccessibilityStatus.limited;
    }

    if (wheelchair == 'no') {
      return SmartAccessibilityStatus.notAccessible;
    }

    return SmartAccessibilityStatus.unknown;
  }

  // This helper extracts a readable place name.
  String _extractName(
      Map<String, dynamic> tags,
      SmartPlaceCategory category,
      ) {
    final name = _firstNonEmpty([
      tags['name'],
      tags['name:en'],
      tags['name:ar'],
      tags['brand'],
      tags['operator'],
    ]);

    if (name != null) return name;

    switch (category) {
      case SmartPlaceCategory.food:
        return 'Food place';
      case SmartPlaceCategory.healthcare:
        return 'Healthcare place';
      case SmartPlaceCategory.pharmacy:
        return 'Pharmacy';
      case SmartPlaceCategory.transport:
        return 'Transport stop';
      case SmartPlaceCategory.all:
        return 'Nearby place';
    }
  }

  // This helper builds a readable address from OSM address tags.
  String? _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[
      if (_stringOrNull(tags['addr:housenumber']) != null)
        _stringOrNull(tags['addr:housenumber'])!,
      if (_stringOrNull(tags['addr:street']) != null)
        _stringOrNull(tags['addr:street'])!,
      if (_stringOrNull(tags['addr:suburb']) != null)
        _stringOrNull(tags['addr:suburb'])!,
      if (_stringOrNull(tags['addr:city']) != null)
        _stringOrNull(tags['addr:city'])!,
    ];

    if (parts.isEmpty) {
      return _firstNonEmpty([
        tags['addr:full'],
        tags['address'],
      ]);
    }

    return parts.join(', ');
  }

  // This helper safely returns a lowercase tag value for comparisons.
  String? _tag(Map<String, dynamic> tags, String key) {
    final value = tags[key];

    if (value == null) return null;

    final text = value.toString().trim().toLowerCase();

    return text.isEmpty ? null : text;
  }

  // This helper returns a clean string or null.
  String? _stringOrNull(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  // This helper returns the first non-empty value in a list.
  String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = _stringOrNull(value);

      if (text != null) return text;
    }

    return null;
  }

  // This helper sorts accessible places first, then by shortest distance.
  int _comparePlacesByAccessibilityThenDistance(
      SmartPlaceModel a,
      SmartPlaceModel b,
      ) {
    final priorityCompare = a.accessibilityStatus.priority.compareTo(
      b.accessibilityStatus.priority,
    );

    if (priorityCompare != 0) return priorityCompare;

    return a.distanceKm.compareTo(b.distanceKm);
  }
}