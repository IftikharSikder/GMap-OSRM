import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gmap_routing_engine/models/search_result.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class NavigationNotifier extends Notifier<NavigationState> {
  Timer? _carTimer;
  int _carIndex = 0;
  final MapController mapController = MapController();

  @override
  NavigationState build() {
    _getUserLocation();
    return const NavigationState();
  }

  // ── LOCATION ──────────────────────────────────────────────

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          userLocation: const LatLng(23.8103, 90.4125),
          errorMessage: 'GPS off. Using Dhaka as default.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        state = state.copyWith(
          userLocation: const LatLng(23.8103, 90.4125),
          errorMessage: 'Permission denied. Using Dhaka as default.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final userLatLng = LatLng(position.latitude, position.longitude);
      state = state.copyWith(userLocation: userLatLng, clearError: true);
      mapController.move(userLatLng, 15.0);
    } catch (e) {
      state = state.copyWith(
        userLocation: const LatLng(23.8103, 90.4125),
        errorMessage: 'Location error. Using Dhaka as default.',
      );
    }
  }

  void goToMyLocation() {
    if (state.userLocation != null) {
      mapController.move(state.userLocation!, 15.0);
    }
  }

  // ── SEARCH ────────────────────────────────────────────────

  Future<void> searchLocation(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: [], isSearching: false);
      return;
    }

    state = state.copyWith(isSearching: true, searchResults: []);

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json&limit=5&addressdetails=1',
      );

      final response = await http.get(url, headers: {'User-Agent': 'GMapRoutingEngine/1.0'});

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final results = data.map((item) {
          return SearchResult(
            displayName: item['display_name'] ?? '',
            position: LatLng(
              double.parse(item['lat'].toString()),
              double.parse(item['lon'].toString()),
            ),
          );
        }).toList();

        state = state.copyWith(searchResults: results, isSearching: false);
      } else {
        state = state.copyWith(isSearching: false);
      }
    } catch (e) {
      state = state.copyWith(isSearching: false, errorMessage: 'Search failed. Check internet.');
    }
  }

  // ── ROUTE ─────────────────────────────────────────────────

  Future<void> selectDestination(SearchResult result) async {
    state = state.copyWith(
      destination: result.position,
      searchResults: [],
      isLoadingRoute: true,
      clearError: true,
      clearRoute: true,
      clearCarPosition: true,
    );
    await _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final origin = state.userLocation;
    final dest = state.destination;
    if (origin == null || dest == null) return;

    try {
      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${dest.longitude},${dest.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;

        final routePoints = coords
            .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
            .toList();

        final distance = data['routes'][0]['distance'] as num;
        final duration = data['routes'][0]['duration'] as num;

        final distanceText = distance >= 1000
            ? '${(distance / 1000).toStringAsFixed(1)} km'
            : '${distance.toInt()} m';

        final durationText = duration >= 3600
            ? '${(duration / 3600).toStringAsFixed(1)} hr'
            : '${(duration / 60).toInt()} min';

        state = state.copyWith(
          routePoints: routePoints,
          isLoadingRoute: false,
          distanceText: distanceText,
          durationText: durationText,
          carPosition: routePoints.first,
          carProgress: 0.0,
        );

        _fitMapToRoute(routePoints);
      } else {
        state = state.copyWith(isLoadingRoute: false, errorMessage: 'Could not fetch route.');
      }
    } catch (e) {
      state = state.copyWith(isLoadingRoute: false, errorMessage: 'Route error. Check internet.');
    }
  }

  void _fitMapToRoute(List<LatLng> points) {
    if (points.isEmpty) return;
    final minLat = points.map((p) => p.latitude).reduce(min);
    final maxLat = points.map((p) => p.latitude).reduce(max);
    final minLng = points.map((p) => p.longitude).reduce(min);
    final maxLng = points.map((p) => p.longitude).reduce(max);

    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    final maxDiff = max(maxLat - minLat, maxLng - minLng);

    double zoom;
    if (maxDiff < 0.01)
      zoom = 15.0;
    else if (maxDiff < 0.05)
      zoom = 13.0;
    else if (maxDiff < 0.1)
      zoom = 12.0;
    else if (maxDiff < 0.5)
      zoom = 10.0;
    else
      zoom = 8.0;

    mapController.move(center, zoom);
  }

  // ── CAR ANIMATION ─────────────────────────────────────────

  void startNavigation() {
    if (state.routePoints.isEmpty) return;
    _carIndex = 0;
    _carTimer?.cancel();

    state = state.copyWith(
      isNavigating: true,
      carProgress: 0.0,
      carPosition: state.routePoints.first,
    );

    _carTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final points = state.routePoints;

      if (_carIndex >= points.length - 1) {
        timer.cancel();
        state = state.copyWith(isNavigating: false, carProgress: 1.0);
        return;
      }

      _carIndex++;
      final current = points[_carIndex];
      final previous = points[_carIndex - 1];
      final rotation = _calculateBearing(previous, current);
      final progress = _carIndex / (points.length - 1);

      state = state.copyWith(carPosition: current, carRotation: rotation, carProgress: progress);

      mapController.move(current, mapController.camera.zoom);
    });
  }

  void stopNavigation() {
    _carTimer?.cancel();
    state = state.copyWith(
      isNavigating: false,
      carProgress: 0.0,
      carPosition: state.routePoints.isNotEmpty ? state.routePoints.first : null,
    );
    _carIndex = 0;
  }

  void clearRoute() {
    _carTimer?.cancel();
    _carIndex = 0;
    state = state.copyWith(
      isNavigating: false,
      carProgress: 0.0,
      clearRoute: true,
      clearCarPosition: true,
      clearDestination: true,
      clearDistanceDuration: true,
    );
    if (state.userLocation != null) {
      mapController.move(state.userLocation!, 15.0);
    }
  }

  double _calculateBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * pi / 180;
    final lat2 = to.latitude * pi / 180;
    final dLng = (to.longitude - from.longitude) * pi / 180;
    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    return atan2(y, x) * 180 / pi;
  }
}
