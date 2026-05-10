import 'package:flutter/material.dart';
import 'package:gmap_routing_engine/models/search_result.dart';
import 'package:gmap_routing_engine/notifiers/navigation_notifier.dart';

class SearchResultsList extends StatelessWidget {
  final NavigationState navState;
  final NavigationNotifier notifier;

  const SearchResultsList({required this.navState, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 72;
    return Positioned(
      top: top,
      left: 12,
      right: 12,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: navState.searchResults.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 52),
            itemBuilder: (context, index) {
              final result = navState.searchResults[index];
              return ListTile(
                leading: const Icon(Icons.location_on, color: Color(0xFF5F6368)),
                title: Text(
                  result.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                dense: true,
                onTap: () => notifier.selectDestination(result),
              );
            },
          ),
        ),
      ),
    );
  }
}
