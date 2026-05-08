import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../bloc/sell_wizard_cubit.dart';
import '../../../../../shared/models/waste_listing_model.dart';
import '../../../../../shared/data/kenya_locations.dart';
import '../../../../../shared/widgets/app_map.dart';
import '../../widgets/farmer_app_menu.dart';

class ConfirmLocationScreen extends StatefulWidget {
  const ConfirmLocationScreen({super.key});
  @override
  State<ConfirmLocationScreen> createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends State<ConfirmLocationScreen> {
  // ─── GPS State ───
  bool _loadingGPS = false;
  String? _gpsAddress;
  double? _gpsLat, _gpsLng;

  // ─── Manual Location State ───
  String? _selectedCounty, _selectedSubCounty, _selectedWard;
  final _villageController = TextEditingController();
  List<String> _counties = [], _subCounties = [], _wards = [];

  // ─── Submit State ───
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _counties = KenyaLocations.getCountyNames();
    _detectGPS();
  }

  @override
  void dispose() {
    _villageController.dispose();
    super.dispose();
  }

  // ─── GPS DETECTION ───
  Future<void> _detectGPS() async {
    setState(() => _loadingGPS = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage('GPS is turned off. Enable it or use manual selection.', Colors.orange);
        setState(() => _loadingGPS = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showMessage('Location permission denied. Use manual selection.', Colors.orange);
        setState(() => _loadingGPS = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        setState(() {
          _gpsLat = position.latitude;
          _gpsLng = position.longitude;
          _gpsAddress = 'GPS: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          _loadingGPS = false;
        });
        _applyGPSLocation();
        _showMessage('GPS location detected! You can now select pickup type.', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingGPS = false);
        _showMessage('Could not detect GPS. Use manual selection.', Colors.orange);
      }
    }
  }

  void _applyGPSLocation() {
    if (_gpsLat == null || _gpsLng == null) return;
    final cubit = context.read<SellWizardCubit>();
    cubit.updatePickupLocation(
      latitude: _gpsLat.toString(),
      longitude: _gpsLng.toString(),
      address: _gpsAddress!,
    );
    setState(() {});
  }

  // ─── MANUAL LOCATION ───
  void _onCountyChanged(String? value) {
    setState(() {
      _selectedCounty = value;
      _selectedSubCounty = null;
      _selectedWard = null;
      _subCounties = value != null ? KenyaLocations.getSubCountyNames(value) : [];
      _wards = [];
    });
  }

  void _onSubCountyChanged(String? value) {
    setState(() {
      _selectedSubCounty = value;
      _selectedWard = null;
      _wards = (value != null && _selectedCounty != null)
          ? KenyaLocations.getWardNames(_selectedCounty!, value)
          : [];
    });
  }

  void _applyManualLocation() {
    if (_selectedCounty == null || _selectedSubCounty == null) {
      _showMessage('Please select County and Sub-County first.', Colors.orange);
      return;
    }

    final village = _villageController.text.trim();
    final address = village.isNotEmpty
        ? '$village, ${_selectedWard ?? ""}, $_selectedSubCounty, $_selectedCounty'
        : '${_selectedWard ?? ""}, $_selectedSubCounty, $_selectedCounty';

    final cubit = context.read<SellWizardCubit>();
    cubit.updatePickupLocation(
      latitude: _gpsLat?.toString() ?? '-0.3031',
      longitude: _gpsLng?.toString() ?? '36.0800',
      address: address,
    );
    setState(() {});
    _showMessage('Location set! Select pickup type below.', Colors.green);
  }

  // ─── SUBMIT ───
  Future<void> _submitOrder() async {
    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Order'),
        content: const Text('Submit this waste listing for collection?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5A27)),
            child: const Text('Yes, Submit'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);

    try {
      await context.read<SellWizardCubit>().submitListing();
      if (mounted) {
        Navigator.of(context).pushNamed('/farmer/sell/success');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        _showMessage('Failed to submit. Please try again.', Colors.red);
      }
    }
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(color == Colors.green ? Icons.check_circle : Icons.info, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── BUILD ───
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellWizardCubit>();
    final hasLocation = cubit.pickupLat != null;
    final hasPickupType = cubit.pickupType != null;
    final canSubmit = hasLocation && hasPickupType && !_submitting;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Location'),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        actions: const [FarmerAppMenu(currentScreen: 'home')],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ─── STEP INDICATOR ───
          _buildStepIndicator(),
          const SizedBox(height: 20),
          const Text('Where is your farm?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('GPS auto-detects your location. Or select manually below.', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),

          // ─── MAP ───
          if (_gpsLat != null && _gpsLng != null)
            AppMap(
            canSelectLocation: true,
            onLocationSelected: (lat, lng) {
              final cubit = context.read<SellWizardCubit>();
              cubit.updatePickupLocation(
                latitude: lat.toString(),
                longitude: lng.toString(),
                address: 'Selected: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
              );
              setState(() {});
            },
              latitude: _gpsLat!,
              longitude: _gpsLng!,
              title: 'Your Farm',
              height: 200,
              zoom: 15.0,
            ),
          if (_gpsLat != null && _gpsLng != null) const SizedBox(height: 12),

          // ─── GPS SECTION ───
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _gpsAddress != null ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _gpsAddress != null ? Icons.gps_fixed : Icons.gps_off,
                      color: _gpsAddress != null ? Colors.green : Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        _gpsAddress != null ? 'GPS Location Detected' : 'GPS Location',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if (_gpsAddress != null)
                        Text(_gpsAddress!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ]),
                  ),
                  if (_loadingGPS)
                    const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    TextButton.icon(
                      onPressed: _detectGPS,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(_gpsAddress != null ? 'Refresh' : 'Detect'),
                    ),
                ]),
                if (_gpsAddress != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _applyGPSLocation,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Use GPS Location', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // ─── MANUAL LOCATION ───
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Or Select Manually', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 12),
                _buildDropdown(_selectedCounty, 'County', _counties, _onCountyChanged),
                const SizedBox(height: 10),
                if (_selectedCounty != null)
                  _buildDropdown(_selectedSubCounty, 'Sub-County', _subCounties, _onSubCountyChanged),
                if (_selectedCounty != null) const SizedBox(height: 10),
                if (_selectedSubCounty != null)
                  _buildDropdown(_selectedWard, 'Ward', _wards, (v) => setState(() => _selectedWard = v)),
                if (_selectedSubCounty != null) const SizedBox(height: 10),
                if (_selectedSubCounty != null)
                  TextField(
                    controller: _villageController,
                    decoration: const InputDecoration(
                      labelText: 'Village / Sublocation',
                      hintText: 'e.g., Kijabe',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                if (_selectedSubCounty != null) const SizedBox(height: 8),
                if (_selectedSubCounty != null)
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: _applyManualLocation,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Set Manual Location', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                  ),
              ]),
            ),
          ),

          // ─── LOCATION CONFIRMED ───
          if (hasLocation) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 22),
                  const SizedBox(width: 10),
                  Expanded(child: Text(cubit.pickupAddress ?? 'Location set', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                ]),
              ),
            ),
          ],

          // ─── PICKUP TYPE ───
          if (hasLocation) ...[
            const SizedBox(height: 16),
            const Text('Pickup Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _buildPickupType(cubit, Icons.calendar_month, 'Routine', 'Recurring collection', PickupType.routine)),
              const SizedBox(width: 8),
              Expanded(child: _buildPickupType(cubit, Icons.touch_app, 'Manual', 'One-time request', PickupType.manual)),
            ]),
          ],

          // ─── NOTES ───
          if (hasLocation) ...[
            const SizedBox(height: 12),
            TextField(
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Notes for the driver (optional)',
                prefixIcon: Icon(Icons.note_alt_outlined),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => cubit.addNotes(v),
            ),
          ],

          const SizedBox(height: 24),

          // ─── SUBMIT BUTTON ───
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: canSubmit ? _submitOrder : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A27),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      canSubmit
                          ? 'Submit Order'
                          : hasLocation
                              ? 'Select pickup type above'
                              : 'Set your location first',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  // ─── WIDGET HELPERS ───
  Widget _buildStepIndicator() {
    return Row(children: [
      _step(1), _line(), _step(2), _line(), _step(3), _line(), _step(4),
    ]);
  }

  Widget _step(int n) {
    final active = n <= 4;
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2D5A27) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: Text('$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
    );
  }

  Widget _line() => Expanded(child: Container(height: 2, color: Colors.grey.shade300));

  Widget _buildDropdown(String? value, String label, List<String> items, Function(String?) onChange) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: onChange,
    );
  }

  Widget _buildPickupType(SellWizardCubit cubit, IconData icon, String title, String subtitle, PickupType type) {
    final selected = cubit.pickupType == type;
    return GestureDetector(
      onTap: () {
        cubit.selectPickupType(type);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.green.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.green : Colors.grey.shade300, width: selected ? 2 : 1),
        ),
        child: Column(children: [
          Icon(icon, color: selected ? Colors.green : Colors.grey, size: 28),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: selected ? Colors.green : Colors.black87)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
      ),
    );
  }
}
