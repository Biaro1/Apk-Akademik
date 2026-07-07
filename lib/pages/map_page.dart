import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  static const double _latitude = -7.0165903;
  static const double _longitude = 110.3971656;
  static const String _label = 'Universitas STIKUBANK (UNISBANK) Kendeng';
  static final LatLng _campus = LatLng(_latitude, _longitude);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Layanan lokasi dimatikan. Silakan nyalakan GPS.';
          _isLoading = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Izin lokasi ditolak. Aktifkan izin lokasi di pengaturan.';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.best),
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Gagal mendapatkan lokasi: $error';
        _isLoading = false;
      });
    }
  }

  double get _distanceToCampus {
    if (_currentPosition == null) return 0;
    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          MapPage._latitude,
          MapPage._longitude,
        ) /
        1000;
  }

  String get _distanceLabel {
    return _distanceToCampus >= 1
        ? '${_distanceToCampus.toStringAsFixed(2)} km'
        : '${(_distanceToCampus * 1000).toStringAsFixed(0)} m';
  }

  String get _bearingLabel {
    if (_currentPosition == null) {
      return '-';
    }
    final bearing = _calculateBearing(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      MapPage._latitude,
      MapPage._longitude,
    );
    return _cardinalDirection(bearing);
  }

  double _calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final startLatRad = _degreesToRadians(startLat);
    final startLngRad = _degreesToRadians(startLng);
    final endLatRad = _degreesToRadians(endLat);
    final endLngRad = _degreesToRadians(endLng);

    final dLng = endLngRad - startLngRad;
    final x = math.sin(dLng) * math.cos(endLatRad);
    final y = math.cos(startLatRad) * math.sin(endLatRad) -
        math.sin(startLatRad) * math.cos(endLatRad) * math.cos(dLng);
    final initialBearing = math.atan2(x, y);
    final degrees = (_radiansToDegrees(initialBearing) + 360) % 360;
    return degrees;
  }

  String _cardinalDirection(double bearing) {
    const directions = [
      'Utara',
      'Timur Laut',
      'Timur',
      'Tenggara',
      'Selatan',
      'Barat Daya',
      'Barat',
      'Barat Laut',
      'Utara',
    ];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  double _degreesToRadians(double degree) => degree * (math.pi / 180);

  double _radiansToDegrees(double radian) => radian * (180 / math.pi);

  Uri get _directionsUri {
    final destination = '${MapPage._latitude},${MapPage._longitude}';
    if (_currentPosition == null) {
      return Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$destination');
    }

    final origin =
        '${_currentPosition!.latitude},${_currentPosition!.longitude}';
    return Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving');
  }

  Future<void> _openExternalMap() async {
    if (!await launchUrl(_directionsUri,
        mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak dapat membuka peta eksternal');
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : MapPage._campus;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        title: const Text('Lokasi Kampus',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: center,
                zoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flutter_app',
                ),
                if (_currentPosition != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          MapPage._campus,
                        ],
                        strokeWidth: 4,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80,
                      height: 80,
                      point: MapPage._campus,
                      builder: (ctx) => const Icon(
                        Icons.location_pin,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                    if (_currentPosition != null)
                      Marker(
                        width: 60,
                        height: 60,
                        point: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        builder: (ctx) => const Icon(
                          Icons.my_location,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(MapPage._label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Koordinat: ${MapPage._latitude}, ${MapPage._longitude}',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 14),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (_currentPosition != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi Anda: ${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Jarak ke kampus: $_distanceLabel',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Arah: $_bearingLabel',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.directions),
                    label: const Text('Buka di Google Maps'),
                    onPressed: _openExternalMap,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Perbarui Lokasi'),
                    onPressed: _initializeLocation,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
