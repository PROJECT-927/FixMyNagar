import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'notification.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geocoding/geocoding.dart'; 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'track.dart';
bool _notificationSent = false;
class TrackPage extends StatefulWidget {
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  LatLng? _userLocation;
  final MapController _mapController = MapController();
   final Random _random = Random();
   List<Map<String, dynamic>> _civicIssues = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _listenLocationChanges();
  }

  // Request permission + get initial location
  Future<void> _getUserLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  // Check current permission
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permission denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permission permanently denied. Please enable from settings.');
  }

  // Get current position
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  setState(() {
    _userLocation = LatLng(position.latitude, position.longitude);
  });
  WidgetsBinding.instance.addPostFrameCallback((_) {
  _generateFakeIssues();
  _mapController.move(_userLocation!, 16); // center map
  setState(() {}); // force rebuild to show civic issue markers
});

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 16);
    }
  });
}
Future<String> _getLandmark(double lat, double lng) async {
  try {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1");

    final response = await http.get(url, headers: {
      "User-Agent": "civic-alert-app" // ⚠️ required by Nominatim policy
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final address = data["address"];

      if (address != null) {
        if (address["road"] != null && address["suburb"] != null) {
          return "${address["road"]}, ${address["suburb"]}";
        } else if (address["road"] != null) {
          return address["road"];
        } else if (address["suburb"] != null) {
          return address["suburb"];
        } else if (address["neighbourhood"] != null) {
          return address["neighbourhood"];
        }
      }
      return data["display_name"] ?? "Unknown location";
    }
  } catch (e) {
    debugPrint("Nominatim error: $e");
  }
  return "Unknown location";
}




void _generateFakeIssues() async {
  if (_userLocation == null) return;

  double offset() => (_random.nextBool() ? 1 : -1) * 0.001; // ~100m

  final fakeLat1 = _userLocation!.latitude + offset();
  final fakeLng1 = _userLocation!.longitude + offset();
  final fakeLat2 = _userLocation!.latitude - offset();
  final fakeLng2 = _userLocation!.longitude + offset();

  final addr1 = await _getLandmark(fakeLat1, fakeLng1);
  final addr2 = await _getLandmark(fakeLat2, fakeLng2);

  setState(() {
    _civicIssues = [
      {"title": "Pothole", "lat": fakeLat1, "lng": fakeLng1, "address": addr1},
      {"title": "Overflowing Trashcan", "lat": fakeLat2, "lng": fakeLng2, "address": addr2},
    ];
  });

  // schedule notification once after 10 seconds
  Future.delayed(const Duration(seconds: 10), () async {
    if (_civicIssues.isNotEmpty && !_notificationSent && _userLocation != null) {
      final firstIssue = _civicIssues.first;

      final dist = _calculateDistance(
        _userLocation!,
        LatLng(firstIssue["lat"], firstIssue["lng"]),
      );

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'civic_channel',
          title: "⚠️ ${firstIssue["title"]} Nearby",
          body: "${firstIssue["title"]} in ${dist.toStringAsFixed(0)} meters near ${firstIssue["address"]}",
          notificationLayout: NotificationLayout.Default,
        ),
      );

      _notificationSent = true;
    }
  });
}

double _calculateDistance(LatLng from, LatLng to) {
  return Geolocator.distanceBetween(
    from.latitude,
    from.longitude,
    to.latitude,
    to.longitude,
  );
}
void _showMessages() {
  if (_userLocation == null) return;

  showModalBottomSheet(
    context: context,
    builder: (context) => ListView(
      padding: const EdgeInsets.all(16),
      children: _civicIssues.map((issue) {
        final dist = _calculateDistance(
          _userLocation!,
          LatLng(issue["lat"], issue["lng"]),
        ).toStringAsFixed(1);

        return ListTile(
          leading: const Icon(Icons.warning, color: Colors.orange),
          title: Text(issue["title"]),
          subtitle: Text(
            "Distance: $dist m | Location: ${issue["address"]}",
          ),
        );
      }).toList(),
    ),
  );
}

  // Stream for continuous location updates
  void _listenLocationChanges() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // meters
      ),
    ).listen((Position position) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _generateFakeIssues();
      });
      _mapController.move(_userLocation!, _mapController.zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation!,
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
  markers: [
    Marker(
      
      point: _userLocation!,
      width: 60,
      height: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon (3D-like person pin)
          Icon(
            Icons.person_pin_circle,
            color: const Color.fromARGB(255, 37, 15, 162),
            size: 40,
            shadows: [
              Shadow(
                blurRadius: 8,
                color: Colors.black38,
                offset: Offset(2, 2),
              )
            ],
          ),
          // Label "You"
          const Text(
            "You",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              backgroundColor: Colors.white70,
            ),
          ),
        ],
      ),
    ),
     ..._civicIssues.map((issue) => Marker(
          point: LatLng(issue["lat"], issue["lng"]),
          width: 60,
          height: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                color: const Color.fromARGB(255, 229, 33, 33),
                size: 40,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.black45,
                    offset: Offset(2, 2),
                  )
                ],
              ),
              Text(
                issue["title"],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  backgroundColor: Colors.white70,
                ),
              ),
            ],
          ),
        )),
  ],
),
              ],
            ),
            floatingActionButton: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    FloatingActionButton.extended(
      onPressed: () {
        Navigator.pop(context); // Back to report page
      },
      label: const Text("Back"),
      icon: const Icon(Icons.arrow_back),
    ),
    const SizedBox(height: 12),
    FloatingActionButton.extended(
      onPressed: _showMessages,
      label: const Text("Alerts"),
      icon: const Icon(Icons.message),
    ),
    FloatingActionButton.extended(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationPage()),
    );
  },
  label: const Text("Test Notification"),
  icon: const Icon(Icons.notifications),
),

  ],
),

    );
  }
}
