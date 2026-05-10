import 'package:flutter/material.dart';
import 'package:gmap_routing_engine/notifiers/navigation_notifier.dart';

class MapButtons extends StatelessWidget {
  final NavigationNotifier notifier;
  const MapButtons({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 220,
      child: Column(
        children: [
          RoundButton(
            icon: Icons.add,
            onTap: () => notifier.mapController.move(
              notifier.mapController.camera.center,
              notifier.mapController.camera.zoom + 1,
            ),
          ),
          const SizedBox(height: 2),
          RoundButton(
            icon: Icons.remove,
            onTap: () => notifier.mapController.move(
              notifier.mapController.camera.center,
              notifier.mapController.camera.zoom - 1,
            ),
          ),
          const SizedBox(height: 10),
          RoundButton(icon: Icons.my_location, onTap: notifier.goToMyLocation),
        ],
      ),
    );
  }
}

class RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF5F6368)),
      ),
    );
  }
}
