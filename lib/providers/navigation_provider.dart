import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gmap_routing_engine/models/search_result.dart';
import 'package:gmap_routing_engine/notifiers/navigation_notifier.dart';

final navigationProvider = NotifierProvider<NavigationNotifier, NavigationState>(
  NavigationNotifier.new,
);
