import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gmap_routing_engine/providers/navigation_provider.dart';
import 'package:gmap_routing_engine/ui/widgets/error_banner.dart';
import 'package:gmap_routing_engine/ui/widgets/loading_overlay.dart';
import 'package:gmap_routing_engine/ui/widgets/map_buttons.dart';
import 'package:gmap_routing_engine/ui/widgets/route_info_card.dart';
import 'package:gmap_routing_engine/ui/widgets/search_bar.dart';
import 'package:gmap_routing_engine/ui/widgets/search_bar_result.dart';

import '../widgets/map_view.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    final notifier = ref.read(navigationProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          MapView(navState: navState, notifier: notifier),
          MapSearchBar(navState: navState, notifier: notifier),
          if (navState.searchResults.isNotEmpty)
            SearchResultsList(navState: navState, notifier: notifier),
          if (navState.distanceText != null) RouteInfoCard(navState: navState, notifier: notifier),
          if (navState.isLoadingRoute) const LoadingOverlay(),
          if (navState.errorMessage != null) ErrorBanner(message: navState.errorMessage!),
          MapButtons(notifier: notifier),
        ],
      ),
    );
  }
}
