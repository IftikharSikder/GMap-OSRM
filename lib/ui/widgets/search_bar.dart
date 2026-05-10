import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gmap_routing_engine/models/search_result.dart';
import 'package:gmap_routing_engine/notifiers/navigation_notifier.dart';

class MapSearchBar extends ConsumerStatefulWidget {
  final NavigationState navState;
  final NavigationNotifier notifier;

  const MapSearchBar({required this.navState, required this.notifier});

  @override
  ConsumerState<MapSearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<MapSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.notifier.searchLocation(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 12,
      right: 12,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              const SizedBox(width: 14),
              widget.navState.destination != null
                  ? GestureDetector(
                      onTap: () {
                        _controller.clear();
                        widget.notifier.clearRoute();
                      },
                      child: const Icon(Icons.arrow_back, color: Color(0xFF5F6368)),
                    )
                  : const Icon(Icons.search, color: Color(0xFF5F6368)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _onChanged,
                  decoration: InputDecoration(
                    hintText: 'Search here',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (widget.navState.isSearching)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.notifier.searchLocation('');
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.close, color: Color(0xFF5F6368)),
                  ),
                ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
