import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gmap_routing_engine/models/search_result.dart';
import 'package:gmap_routing_engine/notifiers/navigation_notifier.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatelessWidget {
  final NavigationState navState;
  final NavigationNotifier notifier;

  const MapView({required this.navState, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: notifier.mapController,
      options: MapOptions(
        initialCenter: navState.userLocation ?? const LatLng(23.8103, 90.4125),
        initialZoom: 25.0,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.gmap.routing.engine',
        ),

        if (navState.routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: navState.routePoints,
                strokeWidth: 8.0,
                color: Colors.blue.withOpacity(0.25),
              ),
              Polyline(
                points: navState.routePoints,
                strokeWidth: 5.0,
                color: const Color(0xFF4285F4),
                borderStrokeWidth: 1.5,
                borderColor: Colors.white,
              ),
            ],
          ),

        MarkerLayer(
          markers: [
            if (navState.userLocation != null)
              Marker(point: navState.userLocation!, width: 26, height: 26, child: _UserDot()),
            if (navState.destination != null)
              Marker(
                point: navState.destination!,
                width: 40,
                height: 52,
                alignment: Alignment.topCenter,
                child: const Icon(
                  Icons.location_pin,
                  color: Color(0xFFEA4335),
                  size: 48,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 2))],
                ),
              ),
            if (navState.carPosition != null && navState.routePoints.isNotEmpty)
              Marker(
                point: navState.carPosition!,
                width: 40,
                height: 52,
                child: Transform.rotate(
                  angle: navState.carRotation * pi / 180,
                  //child: const Icon(Icons.directions_car_filled, color: Colors.black, size: 20),
                  child: Image.asset('images/car_marker.png', width: 20, height: 20),
                ),
              ),
          ],
        ),

        const RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }
}

class _UserDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFF4285F4).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: const Color(0xFF4285F4),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [BoxShadow(color: const Color(0xFF4285F4).withOpacity(0.4), blurRadius: 6)],
          ),
        ),
      ],
    );
  }
}
