import 'package:latlong2/latlong.dart';

class SearchResult {
  final String displayName;
  final LatLng position;

  const SearchResult({required this.displayName, required this.position});
}

class NavigationState {
  final LatLng? userLocation;
  final LatLng? destination;
  final List<LatLng> routePoints;
  final List<SearchResult> searchResults;
  final bool isSearching;
  final bool isLoadingRoute;
  final bool isNavigating;
  final double carProgress;
  final LatLng? carPosition;
  final double carRotation;
  final String? distanceText;
  final String? durationText;
  final String? errorMessage;

  const NavigationState({
    this.userLocation,
    this.destination,
    this.routePoints = const [],
    this.searchResults = const [],
    this.isSearching = false,
    this.isLoadingRoute = false,
    this.isNavigating = false,
    this.carProgress = 0.0,
    this.carPosition,
    this.carRotation = 0.0,
    this.distanceText,
    this.durationText,
    this.errorMessage,
  });

  NavigationState copyWith({
    LatLng? userLocation,
    LatLng? destination,
    List<LatLng>? routePoints,
    List<SearchResult>? searchResults,
    bool? isSearching,
    bool? isLoadingRoute,
    bool? isNavigating,
    double? carProgress,
    LatLng? carPosition,
    double? carRotation,
    String? distanceText,
    String? durationText,
    String? errorMessage,
    bool clearError = false,
    bool clearDestination = false,
    bool clearRoute = false,
    bool clearCarPosition = false,
    bool clearDistanceDuration = false,
  }) {
    return NavigationState(
      userLocation: userLocation ?? this.userLocation,
      destination: clearDestination ? null : (destination ?? this.destination),
      routePoints: clearRoute ? [] : (routePoints ?? this.routePoints),
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
      isNavigating: isNavigating ?? this.isNavigating,
      carProgress: carProgress ?? this.carProgress,
      carPosition: clearCarPosition ? null : (carPosition ?? this.carPosition),
      carRotation: carRotation ?? this.carRotation,
      distanceText: clearDistanceDuration ? null : (distanceText ?? this.distanceText),
      durationText: clearDistanceDuration ? null : (durationText ?? this.durationText),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
