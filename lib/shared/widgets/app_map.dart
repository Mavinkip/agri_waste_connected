import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AppMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String title;
  final List<MapPoint>? markers;
  final double zoom;
  final double height;
  final bool interactive;
  final bool canSelectLocation;
  final Function(double lat, double lng)? onLocationSelected;

  const AppMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.title = 'Location',
    this.markers,
    this.zoom = 14.0,
    this.height = 250,
    this.interactive = true,
    this.canSelectLocation = false,
    this.onLocationSelected,
  });

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  late double _selectedLat;
  late double _selectedLng;
  bool _hasSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedLat = widget.latitude;
    _selectedLng = widget.longitude;
  }

  void _onTap(dynamic tapPosition, LatLng point) {
    if (!widget.canSelectLocation) return;
    setState(() {
      _selectedLat = point.latitude;
      _selectedLng = point.longitude;
      _hasSelected = true;
    });
    widget.onLocationSelected?.call(point.latitude, point.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final displayLat = _hasSelected ? _selectedLat : widget.latitude;
    final displayLng = _hasSelected ? _selectedLng : widget.longitude;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: widget.height,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(displayLat, displayLng),
                initialZoom: widget.zoom,
                interactionOptions: InteractionOptions(
                  flags: widget.interactive ? InteractiveFlag.all : InteractiveFlag.none,
                ),
                onTap: _onTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.agri_waste_connected',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(displayLat, displayLng),
                      width: 160,
                      height: 80,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _hasSelected ? Colors.orange : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                            ),
                            child: Text(
                              _hasSelected ? 'Selected Location' : widget.title,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _hasSelected ? Colors.white : Colors.black),
                            ),
                          ),
                          Icon(
                            _hasSelected ? Icons.push_pin : Icons.location_on,
                            color: _hasSelected ? Colors.orange : Colors.red,
                            size: 34,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.markers != null)
                  MarkerLayer(
                    markers: widget.markers!.map((m) => Marker(
                      point: LatLng(m.latitude, m.longitude),
                      width: 80,
                      height: 40,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: m.color ?? Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(m.label, style: const TextStyle(color: Colors.white, fontSize: 9)),
                          ),
                          Icon(Icons.circle, color: m.color ?? Colors.blue, size: 14),
                        ],
                      ),
                    )).toList(),
                  ),
              ],
            ),
          ),
        ),
        if (widget.canSelectLocation)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _hasSelected ? '📍 Location selected - tap map to change' : '👆 Tap on the map to select your location',
              style: TextStyle(fontSize: 11, color: _hasSelected ? Colors.green : Colors.grey),
            ),
          ),
      ],
    );
  }
}

class MapPoint {
  final double latitude;
  final double longitude;
  final String label;
  final Color? color;

  const MapPoint({
    required this.latitude,
    required this.longitude,
    required this.label,
    this.color,
  });
}
