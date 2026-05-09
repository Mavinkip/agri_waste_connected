import 'package:flutter/material.dart';

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
  double? _selectedLat;
  double? _selectedLng;

  @override
  void initState() {
    super.initState();
    _selectedLat = widget.latitude;
    _selectedLng = widget.longitude;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                // Map background grid pattern
                CustomPaint(
                  size: Size(double.infinity, widget.height),
                  painter: _MapGridPainter(),
                ),
                // Center pin
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.location_on,
                          color: Colors.red, size: 36),
                    ],
                  ),
                ),
                // Coordinates overlay
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${(_selectedLat ?? widget.latitude).toStringAsFixed(4)}, '
                            '${(_selectedLng ?? widget.longitude).toStringAsFixed(4)}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ),
                // Tap overlay for location selection
                if (widget.canSelectLocation)
                  Positioned.fill(
                    child: GestureDetector(
                      onTapDown: (details) {
                        if (!widget.canSelectLocation) return;
                        // Simulate a location offset from center based on tap
                        final box =
                        context.findRenderObject() as RenderBox?;
                        if (box == null) return;
                        final size = box.size;
                        final tapX = details.localPosition.dx;
                        final tapY = details.localPosition.dy;
                        final centerX = size.width / 2;
                        final centerY = size.height / 2;
                        // Rough offset: 0.001 degrees per 10px
                        final lat = widget.latitude +
                            (centerY - tapY) * 0.0001;
                        final lng = widget.longitude +
                            (tapX - centerX) * 0.0001;
                        setState(() {
                          _selectedLat = lat;
                          _selectedLng = lng;
                        });
                        widget.onLocationSelected?.call(lat, lng);
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.canSelectLocation)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _selectedLat != widget.latitude
                  ? '📍 Location selected — tap to adjust'
                  : '👆 Tap map to fine-tune location',
              style: TextStyle(
                  fontSize: 11,
                  color: _selectedLat != widget.latitude
                      ? Colors.green
                      : Colors.grey),
            ),
          ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    // Draw grid lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw a subtle green tint for the "land"
    final fill = Paint()..color = Colors.green.shade50;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fill);

    // Redraw grid on top
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter old) => false;
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