# gmap-osrm-flutter

A Flutter navigation app that simulates real-time car routing using OpenStreetMap tiles and the OSRM (Open Source Routing Machine) API — no paid API keys required.

## Preview

<div align="center">
  <video src="https://github.com/user-attachments/assets/3e8e684b-3221-4db9-8ead-110e3b916d9c" controls autoplay loop muted width="300"></video>
</div>

## 📱 Features

- Detects device real GPS location
- Search any destination using Nominatim (OpenStreetMap search)
- Displays a driving route on the map
- Animated marker that moves along the route
- Car rotates based on direction of travel
- Shows estimated distance and duration
- Destination pin marker
- controls: zoom in/out, go to my location

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| [Flutter](https://flutter.dev) | UI framework |
| [flutter_map](https://pub.dev/packages/flutter_map) | Map rendering |
| [OpenStreetMap](https://www.openstreetmap.org) | Map tiles |
| [OSRM](http://project-osrm.org) | Route calculation |
| [Nominatim](https://nominatim.org) | Location search |
| [geolocator](https://pub.dev/packages/geolocator) | GPS location |
| [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) | State management |
| [latlong2](https://pub.dev/packages/latlong2) | Lat/lng utilities |

---

## 📦 Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  flutter_riverpod: ^2.5.1
  geolocator: ^13.0.1
  http: ^1.2.1
```

---

## Setup

### Android

Add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show navigation</string>
```

## 🌍 APIs Used

- **OSRM** — `http://router.project-osrm.org/route/v1/driving/` — free, no key needed
- **Nominatim** — `https://nominatim.openstreetmap.org/search` — free, no key needed
- **OpenStreetMap tiles** — `https://tile.openstreetmap.org/{z}/{x}/{y}.png` — free

---

## 📄 License

This project is open source.
