import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gmap_routing_engine/ui/screens/map_screens.dart';

void main() {
  runApp(const ProviderScope(child: GMapApp()));
}

class GMapApp extends StatelessWidget {
  const GMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GMap Routing Engine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4285F4)),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}
