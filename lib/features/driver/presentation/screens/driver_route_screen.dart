import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/constants/app_colors.dart';

class DriverRouteScreen extends StatefulWidget {
  const DriverRouteScreen({super.key});

  @override
  State<DriverRouteScreen> createState() => _DriverRouteScreenState();
}

class _DriverRouteScreenState extends State<DriverRouteScreen> {
  Map<String, dynamic>? _routeData;
  Map<String, dynamic>? _driverData;
  bool _loading = true;
  String? _error;
  bool _isGeocoding = false;

  // Map controllers
  MapController? _mapController;
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  LatLng? _currentLocation;
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _routeData = args;
      _driverData = _routeData?['driverData'];
      _loadLocations();
    } else {
      setState(() {
        _error = 'No route data found';
        _loading = false;
      });
    }
  }

  Future<void> _loadLocations() async {
    setState(() {
      _loading = true;
      _isGeocoding = true;
    });

    try {
      // Get pickup location from route data
      final pickupLocation = _routeData?['pickupLocation'] as Map<String, dynamic>?;
      final destination = _routeData?['destination'];

      LatLng? pickupLatLng;
      LatLng? destinationLatLng;

      // Get pickup coordinates
      if (pickupLocation != null) {
        // Check if we have stored coordinates
        if (pickupLocation['latitude'] != null && pickupLocation['longitude'] != null) {
          pickupLatLng = LatLng(
            pickupLocation['latitude'] as double,
            pickupLocation['longitude'] as double,
          );
          print('✅ Pickup coordinates from data: $pickupLatLng');
        } else {
          // Geocode the address
          final address = pickupLocation['fullAddress'] ?? '';
          if (address.isNotEmpty) {
            print('🔍 Geocoding pickup address: $address');
            pickupLatLng = await _geocodeAddress(address);
          }
        }
      }

      // Get destination coordinates
      if (destination != null && destination.toString().isNotEmpty) {
        // Check if we have stored coordinates
        if (_routeData?['destinationLat'] != null && _routeData?['destinationLng'] != null) {
          destinationLatLng = LatLng(
            _routeData!['destinationLat'] as double,
            _routeData!['destinationLng'] as double,
          );
          print('✅ Destination coordinates from data: $destinationLatLng');
        } else {
          // Geocode the destination address
          print('🔍 Geocoding destination: $destination');
          destinationLatLng = await _geocodeAddress(destination.toString());
        }
      }

      // If geocoding failed, try fallback coordinates
      if (pickupLatLng == null) {
        print('⚠️ Pickup geocoding failed, using fallback');
        pickupLatLng = await _getFallbackCoordinates(pickupLocation);
      }

      if (destinationLatLng == null && destination != null) {
        print('⚠️ Destination geocoding failed, using fallback');
        destinationLatLng = await _getFallbackDestination(destination.toString());
      }

      // Get current location
      final currentLocation = await _getCurrentLocation();

      setState(() {
        _pickupLocation = pickupLatLng;
        _destinationLocation = destinationLatLng;
        _currentLocation = currentLocation;
        _updateMarkers();
        _updatePolylines();
        _loading = false;
        _isGeocoding = false;
      });

      print('📍 Pickup: $_pickupLocation');
      print('📍 Destination: $_destinationLocation');
      print('📍 Current: $_currentLocation');

    } catch (e) {
      print('❌ Error loading locations: $e');
      setState(() {
        _error = 'Could not load map locations. Please check your internet connection.';
        _loading = false;
        _isGeocoding = false;
      });
    }
  }

  Future<LatLng?> _geocodeAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        print('✅ Geocoded "$address" to: ${loc.latitude}, ${loc.longitude}');
        return LatLng(loc.latitude, loc.longitude);
      }
      return null;
    } catch (e) {
      print('❌ Geocoding error for "$address": $e');
      return null;
    }
  }

  Future<LatLng?> _getFallbackCoordinates(Map<String, dynamic>? pickupLocation) async {
    if (pickupLocation == null) return null;

    final county = pickupLocation['county'] as String?;
    final subCounty = pickupLocation['subCounty'] as String?;
    final ward = pickupLocation['ward'] as String?;

    // Try to geocode the most specific location first
    if (ward != null && ward.isNotEmpty) {
      final result = await _geocodeAddress('$ward, Kenya');
      if (result != null) return result;
    }

    if (subCounty != null && subCounty.isNotEmpty) {
      final result = await _geocodeAddress('$subCounty, Kenya');
      if (result != null) return result;
    }

    if (county != null && county.isNotEmpty) {
      final result = await _geocodeAddress('$county, Kenya');
      if (result != null) return result;
    }

    // Default to Nairobi if all else fails
    return const LatLng(-1.286389, 36.817223);
  }

  Future<LatLng?> _getFallbackDestination(String destination) async {
    // Try to geocode the full address
    final result = await _geocodeAddress('$destination, Kenya');
    if (result != null) return result;

    // Try with just the name
    final result2 = await _geocodeAddress(destination);
    if (result2 != null) return result2;

    // Default to Nairobi
    return const LatLng(-1.286389, 36.817223);
  }

  Future<LatLng?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Location services disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ Location permission denied');
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      print('✅ Current location: ${position.latitude}, ${position.longitude}');
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('❌ Error getting current location: $e');
      return null;
    }
  }

  void _updateMarkers() {
    final List<Marker> newMarkers = [];

    // Current location marker
    if (_currentLocation != null) {
      newMarkers.add(
        Marker(
          point: _currentLocation!,
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    // Pickup marker
    if (_pickupLocation != null) {
      final pickupLocation = _routeData?['pickupLocation'] as Map<String, dynamic>?;
      final pickupAddress = pickupLocation?['fullAddress'] ?? 'Pickup Location';

      newMarkers.add(
        Marker(
          point: _pickupLocation!,
          width: 100,
          height: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  pickupAddress.length > 25 ? '${pickupAddress.substring(0, 25)}...' : pickupAddress,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Destination marker
    if (_destinationLocation != null) {
      newMarkers.add(
        Marker(
          point: _destinationLocation!,
          width: 100,
          height: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  _routeData?['destination']?.length > 25
                      ? '${_routeData?['destination']?.substring(0, 25)}...'
                      : _routeData?['destination'] ?? 'Destination',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.location_city,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  void _updatePolylines() {
    final List<Polyline> newPolylines = [];

    if (_pickupLocation != null && _destinationLocation != null) {
      newPolylines.add(
        Polyline(
          points: [
            _pickupLocation!,
            _destinationLocation!,
          ],
          strokeWidth: 4,
          color: Colors.blue,
        ),
      );
    }

    // Add route from current location to pickup
    if (_currentLocation != null && _pickupLocation != null) {
      newPolylines.add(
        Polyline(
          points: [
            _currentLocation!,
            _pickupLocation!,
          ],
          strokeWidth: 3,
          color: Colors.green,
        ),
      );
    }

    setState(() {
      _polylines = newPolylines;
    });
  }

  void _centerMap() {
    if (_pickupLocation != null && _destinationLocation != null) {
      // Center between pickup and destination
      final lat = (_pickupLocation!.latitude + _destinationLocation!.latitude) / 2;
      final lng = (_pickupLocation!.longitude + _destinationLocation!.longitude) / 2;

      _mapController?.move(
        LatLng(lat, lng),
        12,
      );
    } else if (_pickupLocation != null) {
      _mapController?.move(_pickupLocation!, 15);
    } else if (_currentLocation != null) {
      _mapController?.move(_currentLocation!, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _isGeocoding) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Today's Route"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading map location...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Today's Route"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadLocations,
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final driverName = _driverData?['fullName'] ?? 'Driver';
    final vehicle = _driverData?['vehicleType'] ?? 'N/A';
    final vehicleNumber = _driverData?['vehicleNumber'] ?? '';
    final routeName = _routeData?['routeName'] ?? 'Route';
    final pickupLocation = _routeData?['pickupLocation'] as Map<String, dynamic>?;
    final pickupAddress = pickupLocation?['fullAddress'] ?? 'Pickup Location';
    final destination = _routeData?['destination'] ?? 'Destination';
    final scheduledDate = _routeData?['scheduledDate'] ?? 'Not scheduled';

    final hasLocations = _pickupLocation != null || _destinationLocation != null;

    // Default center (Nairobi)
    final center = _pickupLocation ?? _currentLocation ?? const LatLng(-1.286389, 36.817223);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Route"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLocations,
          ),
        ],
      ),
      body: Column(
        children: [
          // Map
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.agri_waste_connected',
                ),
                MarkerLayer(
                  markers: _markers,
                ),
                PolylineLayer(
                  polylines: _polylines,
                ),
              ],
            ),
          ),
          // Route Details
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver Info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Text(
                          driverName.isNotEmpty ? driverName[0].toUpperCase() : 'D',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driverName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '🚗 $vehicle ${vehicleNumber.isNotEmpty ? "($vehicleNumber)" : ""}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _driverData?['status'] == 'active'
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _driverData?['status'] ?? 'idle',
                          style: TextStyle(
                            color: _driverData?['status'] == 'active'
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Route Info
                  Row(
                    children: [
                      Icon(Icons.route, size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          routeName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '📅 $scheduledDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Pickup and Destination Summary
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: Colors.green),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    pickupAddress,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_city, size: 14, color: Colors.red),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    destination,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.center_focus_strong),
                        onPressed: _centerMap,
                        tooltip: 'Center Map',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_pickupLocation != null) {
                              _mapController?.move(_pickupLocation!, 15);
                            } else if (_currentLocation != null) {
                              _mapController?.move(_currentLocation!, 15);
                            }
                          },
                          icon: const Icon(Icons.navigation, size: 18),
                          label: const Text('Navigate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to arrival
                            NavigationService.pushNamed(
                              '/driver/arrival',
                              arguments: _routeData,
                            );
                          },
                          icon: const Icon(Icons.flag, size: 18),
                          label: const Text('Arrived'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}