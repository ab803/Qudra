import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/Services/Localization/translation_extension.dart';
import '../models/smart_place_model.dart';
import '../viewmodel/smart_accessible_map_cubit.dart';
import '../viewmodel/smart_accessible_map_state.dart';

class SmartAccessibleMapView extends StatelessWidget {
  const SmartAccessibleMapView({super.key});

  @override
  Widget build(BuildContext context) {
    // This provider loads nearby places as soon as the Smart Map screen opens.
    return BlocProvider(
      create: (_) => SmartAccessibleMapCubit()..loadNearbyPlaces(),
      child: const _SmartAccessibleMapContent(),
    );
  }
}

class _SmartAccessibleMapContent extends StatelessWidget {
  const _SmartAccessibleMapContent();

  // This helper returns an accent color for each place category.
  Color _categoryColor(SmartPlaceCategory category) {
    switch (category) {
      case SmartPlaceCategory.food:
        return const Color(0xFFF97316);
      case SmartPlaceCategory.healthcare:
        return const Color(0xFFEF4444);
      case SmartPlaceCategory.pharmacy:
        return const Color(0xFF22C55E);
      case SmartPlaceCategory.transport:
        return const Color(0xFF3B82F6);
      case SmartPlaceCategory.all:
        return const Color(0xFF111827);
    }
  }

  // This helper returns an icon for each place category.
  IconData _categoryIcon(SmartPlaceCategory category) {
    switch (category) {
      case SmartPlaceCategory.food:
        return Icons.restaurant_outlined;
      case SmartPlaceCategory.healthcare:
        return Icons.local_hospital_outlined;
      case SmartPlaceCategory.pharmacy:
        return Icons.local_pharmacy_outlined;
      case SmartPlaceCategory.transport:
        return Icons.directions_bus_outlined;
      case SmartPlaceCategory.all:
        return Icons.place_outlined;
    }
  }

  // This helper returns a marker color depending on accessibility priority.
  Color _markerColor(SmartPlaceModel place) {
    switch (place.accessibilityStatus) {
      case SmartAccessibilityStatus.accessible:
        return const Color(0xFF16A34A);
      case SmartAccessibilityStatus.limited:
        return const Color(0xFFF59E0B);
      case SmartAccessibilityStatus.notAccessible:
        return const Color(0xFFEF4444);
      case SmartAccessibilityStatus.unknown:
        return _categoryColor(place.category);
    }
  }

  // This helper opens Google Maps directions externally for the selected place.
  Future<void> _openDirections(BuildContext context, SmartPlaceModel place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}',
    );

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('smart_map_directions_error')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // This helper opens device settings when location permission is denied forever.
  Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // This helper opens location settings when location service is disabled.
  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // This helper shows a bottom sheet with full place details.
  Future<void> _showPlaceDetails(
      BuildContext context,
      SmartPlaceModel place,
      ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _markerColor(place);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // This drag handle indicates that the details sheet can be dismissed.
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // This badge displays the accessibility status.
                  _SmartMapBadge(
                    label: context.tr(place.accessibilityStatus.labelKey),
                    icon: Icons.accessible_forward_rounded,
                    color: accentColor,
                  ),

                  const SizedBox(height: 14),

                  Text(
                    place.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _NeutralInfoPill(
                        icon: _categoryIcon(place.category),
                        text: context.tr(place.category.labelKey),
                      ),
                      _NeutralInfoPill(
                        icon: Icons.near_me_outlined,
                        text:
                        '${place.distanceKm.toStringAsFixed(1)} ${context.tr('km_short')}',
                      ),
                      if (place.openingHours != null)
                        _NeutralInfoPill(
                          icon: Icons.schedule_outlined,
                          text: place.openingHours!,
                        ),
                    ],
                  ),

                  if (place.address != null) ...[
                    const SizedBox(height: 18),
                    _DetailsRow(
                      icon: Icons.location_on_outlined,
                      title: context.tr('smart_map_address'),
                      value: place.address!,
                    ),
                  ],

                  if (place.phone != null) ...[
                    const SizedBox(height: 12),
                    _DetailsRow(
                      icon: Icons.phone_outlined,
                      title: context.tr('smart_map_phone'),
                      value: place.phone!,
                    ),
                  ],

                  if (place.wheelchairDescription != null) ...[
                    const SizedBox(height: 12),
                    _DetailsRow(
                      icon: Icons.info_outline_rounded,
                      title: context.tr('smart_map_accessibility_notes'),
                      value: place.wheelchairDescription!,
                    ),
                  ],

                  const SizedBox(height: 22),

                  // This notice explains that OSM accessibility data can be incomplete.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(
                        theme.brightness == Brightness.dark ? 0.14 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.16),
                      ),
                    ),
                    child: Text(
                      context.tr('smart_map_data_notice'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _openDirections(context, place),
                      icon: const Icon(Icons.directions_outlined),
                      label: Text(
                        context.tr('smart_map_open_directions'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmartAccessibleMapCubit, SmartAccessibleMapState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              context.tr('smart_accessible_map'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (state is SmartAccessibleMapLoaded)
                IconButton(
                  tooltip: context.tr('retry'),
                  onPressed: () =>
                      context.read<SmartAccessibleMapCubit>().refresh(),
                  icon: const Icon(Icons.refresh_rounded),
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context,
      SmartAccessibleMapState state,
      ) {
    if (state is SmartAccessibleMapLoading ||
        state is SmartAccessibleMapInitial) {
      return _LoadingView();
    }

    if (state is SmartAccessibleMapLocationServiceDisabled) {
      return _ActionMessageView(
        icon: Icons.location_disabled_outlined,
        message: context.tr(state.messageKey),
        actionLabel: context.tr('permission_open_location_settings'),
        onAction: _openLocationSettings,
      );
    }

    if (state is SmartAccessibleMapPermissionDenied) {
      return _ActionMessageView(
        icon: Icons.location_off_outlined,
        message: context.tr(state.messageKey),
        actionLabel: context.tr('permission_location_enable'),
        onAction: _openAppSettings,
      );
    }

    if (state is SmartAccessibleMapError) {
      return _ActionMessageView(
        icon: Icons.error_outline_rounded,
        message: context.tr(state.messageKey),
        actionLabel: context.tr('retry'),
        onAction: () => context.read<SmartAccessibleMapCubit>().loadNearbyPlaces(),
      );
    }

    if (state is SmartAccessibleMapLoaded) {
      return _LoadedSmartMapView(
        state: state,
        categoryColor: _categoryColor,
        categoryIcon: _categoryIcon,
        markerColor: _markerColor,
        onPlaceTap: (place) => _showPlaceDetails(context, place),
        onDirectionsTap: (place) => _openDirections(context, place),
      );
    }

    return const SizedBox.shrink();
  }
}

class _LoadedSmartMapView extends StatelessWidget {
  final SmartAccessibleMapLoaded state;
  final Color Function(SmartPlaceCategory category) categoryColor;
  final IconData Function(SmartPlaceCategory category) categoryIcon;
  final Color Function(SmartPlaceModel place) markerColor;
  final ValueChanged<SmartPlaceModel> onPlaceTap;
  final ValueChanged<SmartPlaceModel> onDirectionsTap;

  const _LoadedSmartMapView({
    required this.state,
    required this.categoryColor,
    required this.categoryIcon,
    required this.markerColor,
    required this.onPlaceTap,
    required this.onDirectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final places = state.visiblePlaces;

    return Column(
      children: [
        // This filter row lets users switch between nearby place categories.
        _SmartMapFilters(
          selectedCategory: state.selectedCategory,
          accessibleOnly: state.accessibleOnly,
          onCategoryChanged: (category) {
            context.read<SmartAccessibleMapCubit>().selectCategory(category);
          },
          onAccessibleOnlyChanged: (value) {
            context.read<SmartAccessibleMapCubit>().toggleAccessibleOnly(value);
          },
        ),

        // This area renders the interactive OpenStreetMap with nearby place markers.
        Expanded(
          flex: 6,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: state.userLocation,
              initialZoom: 15,
              minZoom: 3,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.qudra.app',
              ),
              MarkerLayer(
                markers: [
                  // This marker shows the user's current location.
                  Marker(
                    point: state.userLocation,
                    width: 46,
                    height: 46,
                    child: const _UserLocationMarker(),
                  ),

                  // These markers show nearby public places returned from OpenStreetMap.
                  ...places.map(
                        (place) => Marker(
                      point: place.point,
                      width: 48,
                      height: 48,
                      child: GestureDetector(
                        onTap: () => onPlaceTap(place),
                        child: _PlaceMarker(
                          color: markerColor(place),
                          icon: categoryIcon(place.category),
                          isAccessible: place.hasPositiveAccessibility,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // This panel renders the nearby places list sorted by accessibility priority.
        Expanded(
          flex: 5,
          child: _PlacesListPanel(
            state: state,
            places: places,
            categoryColor: categoryColor,
            categoryIcon: categoryIcon,
            onPlaceTap: onPlaceTap,
            onDirectionsTap: onDirectionsTap,
          ),
        ),
      ],
    );
  }
}

class _SmartMapFilters extends StatelessWidget {
  final SmartPlaceCategory selectedCategory;
  final bool accessibleOnly;
  final ValueChanged<SmartPlaceCategory> onCategoryChanged;
  final ValueChanged<bool> onAccessibleOnlyChanged;

  const _SmartMapFilters({
    required this.selectedCategory,
    required this.accessibleOnly,
    required this.onCategoryChanged,
    required this.onAccessibleOnlyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = const [
      SmartPlaceCategory.all,
      SmartPlaceCategory.food,
      SmartPlaceCategory.healthcare,
      SmartPlaceCategory.pharmacy,
      SmartPlaceCategory.transport,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((category) {
                final selected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: selected,
                    label: Text(context.tr(category.labelKey)),
                    onSelected: (_) => onCategoryChanged(category),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('smart_map_accessible_only'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch.adaptive(
                value: accessibleOnly,
                onChanged: onAccessibleOnlyChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlacesListPanel extends StatelessWidget {
  final SmartAccessibleMapLoaded state;
  final List<SmartPlaceModel> places;
  final Color Function(SmartPlaceCategory category) categoryColor;
  final IconData Function(SmartPlaceCategory category) categoryIcon;
  final ValueChanged<SmartPlaceModel> onPlaceTap;
  final ValueChanged<SmartPlaceModel> onDirectionsTap;

  const _PlacesListPanel({
    required this.state,
    required this.places,
    required this.categoryColor,
    required this.categoryIcon,
    required this.onPlaceTap,
    required this.onDirectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (places.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        color: theme.scaffoldBackgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 42,
              color: theme.colorScheme.onSurface.withOpacity(0.35),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('smart_map_no_places_found'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('smart_map_no_places_found_desc'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.62),
                height: 1.45,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // This summary shows the number of nearby results after filters.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              context
                  .tr('smart_map_nearby_results')
                  .replaceAll('{count}', places.length.toString()),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: places.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final place = places[index];

                return _SmartPlaceCard(
                  place: place,
                  categoryColor: categoryColor(place.category),
                  categoryIcon: categoryIcon(place.category),
                  onTap: () => onPlaceTap(place),
                  onDirectionsTap: () => onDirectionsTap(place),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartPlaceCard extends StatelessWidget {
  final SmartPlaceModel place;
  final Color categoryColor;
  final IconData categoryIcon;
  final VoidCallback onTap;
  final VoidCallback onDirectionsTap;

  const _SmartPlaceCard({
    required this.place,
    required this.categoryColor,
    required this.categoryIcon,
    required this.onTap,
    required this.onDirectionsTap,
  });

  Color _accessibilityColor() {
    switch (place.accessibilityStatus) {
      case SmartAccessibilityStatus.accessible:
        return const Color(0xFF16A34A);
      case SmartAccessibilityStatus.limited:
        return const Color(0xFFF59E0B);
      case SmartAccessibilityStatus.notAccessible:
        return const Color(0xFFEF4444);
      case SmartAccessibilityStatus.unknown:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accessibilityColor = _accessibilityColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // This icon identifies the place category.
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(
                    theme.brightness == Brightness.dark ? 0.18 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SmartMapBadge(
                          label: context.tr(place.category.labelKey),
                          icon: categoryIcon,
                          color: categoryColor,
                        ),
                        _SmartMapBadge(
                          label: context.tr(place.accessibilityStatus.labelKey),
                          icon: Icons.accessible_forward_rounded,
                          color: accessibilityColor,
                        ),
                        _NeutralInfoPill(
                          icon: Icons.near_me_outlined,
                          text:
                          '${place.distanceKm.toStringAsFixed(1)} ${context.tr('km_short')}',
                        ),
                      ],
                    ),
                    if (place.address != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        place.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.62),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: context.tr('smart_map_open_directions'),
                onPressed: onDirectionsTap,
                icon: const Icon(Icons.directions_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.18),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.onPrimary, width: 3),
          ),
        ),
      ),
    );
  }
}

class _PlaceMarker extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool isAccessible;

  const _PlaceMarker({
    required this.color,
    required this.icon,
    required this.isAccessible,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.30),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 21,
          ),
        ),
        if (isAccessible)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.check,
                size: 11,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              context.tr('smart_map_loading_places'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionMessageView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final Future<void> Function() onAction;

  const _ActionMessageView({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 46, color: colorScheme.primary),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.72),
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () async => onAction(),
                child: Text(actionLabel),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    context.read<SmartAccessibleMapCubit>().loadNearbyPlaces(),
                child: Text(context.tr('retry')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmartMapBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SmartMapBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(
          theme.brightness == Brightness.dark ? 0.18 : 0.10,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _NeutralInfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _NeutralInfoPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: onSurface.withOpacity(
          theme.brightness == Brightness.dark ? 0.10 : 0.05,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: onSurface.withOpacity(0.62)),
          const SizedBox(width: 5),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: onSurface.withOpacity(0.72),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailsRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: onSurface.withOpacity(0.60)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onSurface.withOpacity(0.55),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: onSurface.withOpacity(0.82),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
