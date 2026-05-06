import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../bloc/sell_wizard_cubit.dart';
import '../../../../../shared/models/waste_listing_model.dart';
import '../../../../../shared/data/kenya_locations.dart';
import '../../widgets/farmer_app_menu.dart';

class ConfirmLocationScreen extends StatefulWidget {
  const ConfirmLocationScreen({super.key});
  @override
  State<ConfirmLocationScreen> createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends State<ConfirmLocationScreen> {
  String? _selectedCounty, _selectedSubCounty, _selectedWard;
  final _villageController = TextEditingController();
  List<String> _counties = [], _subCounties = [], _wards = [];
  bool _loadingGPS = false;
  String? _gpsAddress, _gpsLat, _gpsLng;

  @override
  void initState() {
    super.initState();
    _counties = KenyaLocations.getCountyNames();
    _getGPS();
  }

  Future<void> _getGPS() async {
    setState(() => _loadingGPS = true);
    try {
      final service = await Geolocator.isLocationServiceEnabled();
      if (!service) {
        setState(() => _loadingGPS = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GPS is off. Enable location or use manual selection.'), backgroundColor: Colors.orange));
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() => _loadingGPS = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied. Use manual selection.'), backgroundColor: Colors.orange));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _gpsLat = pos.latitude.toString();
          _gpsLng = pos.longitude.toString();
          _gpsAddress = 'GPS: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
          _loadingGPS = false;
        });
        context.read<SellWizardCubit>().updatePickupLocation(latitude: _gpsLat!, longitude: _gpsLng!, address: _gpsAddress!);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GPS location set! Select pickup type below.'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingGPS = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('GPS error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _onCounty(String? v) => setState(() { _selectedCounty = v; _selectedSubCounty = null; _selectedWard = null; _subCounties = v != null ? KenyaLocations.getSubCountyNames(v) : []; _wards = []; });
  void _onSubCounty(String? v) => setState(() { _selectedSubCounty = v; _selectedWard = null; _wards = (v != null && _selectedCounty != null) ? KenyaLocations.getWardNames(_selectedCounty!, v) : []; });

  void _setManual() {
    if (_selectedCounty == null || _selectedSubCounty == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select County and Sub-County first'), backgroundColor: Colors.orange));
      return;
    }
    final addr = _villageController.text.isNotEmpty
        ? '${_villageController.text}, ${_selectedWard ?? ""}, $_selectedSubCounty, $_selectedCounty'
        : '${_selectedWard ?? ""}, $_selectedSubCounty, $_selectedCounty';
    context.read<SellWizardCubit>().updatePickupLocation(latitude: '-0.3031', longitude: '36.0800', address: addr.trim());
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location set! Select pickup type below.'), backgroundColor: Colors.green));
  }

  @override
  void dispose() { _villageController.dispose(); super.dispose(); }

  Widget _step(int n, bool active) => Container(width: 28, height: 28, decoration: BoxDecoration(color: active ? const Color(0xFF2D5A27) : Colors.grey.shade300, borderRadius: BorderRadius.circular(14)), child: Center(child: Text('$n', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))));
  Widget _line() => Expanded(child: Container(height: 2, color: Colors.grey.shade300));

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellWizardCubit>();
    final hasLoc = cubit.pickupLat != null;
    final canSubmit = hasLoc && cubit.pickupType != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Location'), centerTitle: true, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()), actions: const [FarmerAppMenu(currentScreen: 'home')]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_step(1, true), _line(), _step(2, true), _line(), _step(3, true), _line(), _step(4, true)]),
          const SizedBox(height: 20),
          const Text('Where is your farm?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // GPS Section
          Card(
            elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _gpsAddress != null ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(_gpsAddress != null ? Icons.gps_fixed : Icons.gps_off, color: _gpsAddress != null ? Colors.green : Colors.blue, size: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_gpsAddress != null ? 'GPS Location Set' : 'GPS Location', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (_gpsAddress != null) Text(_gpsAddress!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ])),
                  if (_loadingGPS) const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  else if (_gpsAddress == null) TextButton.icon(onPressed: _getGPS, icon: const Icon(Icons.refresh, size: 18), label: const Text('Detect')),
                ]),
                if (_gpsAddress == null && !_loadingGPS) const Text('Tap Detect to use GPS, or select manually below', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Manual Selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Or Select Manually', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 10),
              _dropdown(_selectedCounty, 'County', _counties, _onCounty),
              const SizedBox(height: 10),
              if (_selectedCounty != null) _dropdown(_selectedSubCounty, 'Sub-County', _subCounties, _onSubCounty),
              if (_selectedCounty != null) const SizedBox(height: 10),
              if (_selectedSubCounty != null) _dropdown(_selectedWard, 'Ward', _wards, (v) => setState(() => _selectedWard = v)),
              if (_selectedSubCounty != null) const SizedBox(height: 10),
              if (_selectedSubCounty != null) TextField(controller: _villageController, decoration: const InputDecoration(labelText: 'Village (optional)', hintText: 'e.g., Kijabe', border: OutlineInputBorder())),
              if (_selectedSubCounty != null) const SizedBox(height: 8),
              if (_selectedSubCounty != null) SizedBox(width: double.infinity, height: 40, child: ElevatedButton.icon(onPressed: _setManual, icon: const Icon(Icons.check, size: 16), label: const Text('Set Manual Location', style: TextStyle(fontSize: 13)), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue))),
            ]),
          ),

          // Location Preview
          if (hasLoc) ...[
            const SizedBox(height: 12),
            Card(elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), color: Colors.green.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [const Icon(Icons.location_on, color: Colors.green), const SizedBox(width: 8), Expanded(child: Text(cubit.pickupAddress ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))), const Icon(Icons.check_circle, color: Colors.green, size: 20)]))),
          ],

          // Pickup Type
          if (hasLoc) const SizedBox(height: 16),
          if (hasLoc) const Text('Pickup Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          if (hasLoc) const SizedBox(height: 8),
          if (hasLoc) Row(children: [
            Expanded(child: _pType(cubit, Icons.calendar_month, 'Routine', 'Regular collection', PickupType.routine)),
            const SizedBox(width: 8),
            Expanded(child: _pType(cubit, Icons.touch_app, 'Manual', 'One-time request', PickupType.manual)),
          ]),

          if (hasLoc) const SizedBox(height: 12),
          if (hasLoc) TextField(maxLines: 2, decoration: const InputDecoration(hintText: 'Notes for driver (optional)', prefixIcon: Icon(Icons.note_alt_outlined), border: OutlineInputBorder(), filled: true, fillColor: Colors.white), onChanged: (v) => cubit.addNotes(v)),

          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: canSubmit ? () => Navigator.of(context).pushNamed('/farmer/sell/success') : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5A27), disabledBackgroundColor: Colors.grey.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text(canSubmit ? 'Submit Order' : hasLoc ? 'Select pickup type above' : 'Set location first', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _dropdown(String? value, String label, List<String> items, Function(String?) onChange) {
    return DropdownButtonFormField<String>(value: value, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChange);
  }

  Widget _pType(SellWizardCubit cubit, IconData icon, String label, String sub, PickupType type) {
    final sel = cubit.pickupType == type;
    return GestureDetector(
      onTap: () { cubit.selectPickupType(type); setState(() {}); },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: sel ? Colors.green.withValues(alpha: 0.1) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? Colors.green : Colors.grey.shade300, width: sel ? 2 : 1)),
        child: Column(children: [Icon(icon, color: sel ? Colors.green : Colors.grey, size: 28), const SizedBox(height: 4), Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: sel ? Colors.green : Colors.black87)), Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey))])),
    );
  }
}
