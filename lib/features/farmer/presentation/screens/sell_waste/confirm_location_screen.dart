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
  bool _submitting = false;
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
      if (!service) { setState(() => _loadingGPS = false); return; }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) { setState(() => _loadingGPS = false); return; }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() { _gpsLat = pos.latitude.toString(); _gpsLng = pos.longitude.toString(); _gpsAddress = 'GPS: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}'; _loadingGPS = false; });
        context.read<SellWizardCubit>().updatePickupLocation(latitude: _gpsLat!, longitude: _gpsLng!, address: _gpsAddress!);
        setState(() {});
      }
    } catch (_) { if (mounted) setState(() => _loadingGPS = false); }
  }

  void _onCounty(String? v) => setState(() { _selectedCounty = v; _selectedSubCounty = null; _selectedWard = null; _subCounties = v != null ? KenyaLocations.getSubCountyNames(v) : []; _wards = []; });
  void _onSubCounty(String? v) => setState(() { _selectedSubCounty = v; _selectedWard = null; _wards = (v != null && _selectedCounty != null) ? KenyaLocations.getWardNames(_selectedCounty!, v) : []; });

  void _setManual() {
    if (_selectedCounty == null || _selectedSubCounty == null) return;
    final addr = _villageController.text.isNotEmpty ? '${_villageController.text}, ${_selectedWard ?? ""}, $_selectedSubCounty, $_selectedCounty' : '${_selectedWard ?? ""}, $_selectedSubCounty, $_selectedCounty';
    context.read<SellWizardCubit>().updatePickupLocation(latitude: '-0.3031', longitude: '36.0800', address: addr.trim());
    setState(() {});
  }

  Future<void> _submit() async {
    // Confirm dialog prevents accidental taps
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Confirm Order'),
      content: const Text('Submit this waste listing?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
      ],
    ));
    if (confirm != true) return;

    setState(() => _submitting = true);
    try {
      await context.read<SellWizardCubit>().submitListing();
      if (mounted) Navigator.of(context).pushNamed('/farmer/sell/success');
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() { _villageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellWizardCubit>();
    final hasLoc = cubit.pickupLat != null;
    final canSubmit = hasLoc && cubit.pickupType != null && !_submitting;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Location'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()), actions: const [FarmerAppMenu(currentScreen: 'home')]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Where is your farm?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // GPS
          Card(elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            Row(children: [
              Icon(_gpsAddress != null ? Icons.gps_fixed : Icons.gps_off, color: _gpsAddress != null ? Colors.green : Colors.grey, size: 24),
              const SizedBox(width: 10),
              Expanded(child: Text(_gpsAddress ?? 'GPS not available', style: TextStyle(color: _gpsAddress != null ? Colors.green : Colors.grey))),
              if (_loadingGPS) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else if (_gpsAddress == null) TextButton.icon(onPressed: _getGPS, icon: const Icon(Icons.refresh, size: 16), label: const Text('Detect')),
            ]),
          ]))),
          const SizedBox(height: 16),
          // Manual
          const Text('Or select manually:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _dd(_selectedCounty, 'County', _counties, _onCounty),
          const SizedBox(height: 10),
          if (_selectedCounty != null) _dd(_selectedSubCounty, 'Sub-County', _subCounties, _onSubCounty),
          if (_selectedCounty != null) const SizedBox(height: 10),
          if (_selectedSubCounty != null) _dd(_selectedWard, 'Ward', _wards, (v) => setState(() => _selectedWard = v)),
          if (_selectedSubCounty != null) const SizedBox(height: 10),
          if (_selectedSubCounty != null) TextField(controller: _villageController, decoration: const InputDecoration(labelText: 'Village (optional)', hintText: 'e.g., Kijabe', border: OutlineInputBorder())),
          if (_selectedSubCounty != null) const SizedBox(height: 8),
          if (_selectedSubCounty != null) SizedBox(width: double.infinity, height: 40, child: ElevatedButton.icon(onPressed: _setManual, icon: const Icon(Icons.check, size: 16), label: const Text('Set Location', style: TextStyle(fontSize: 13)), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue))),
          if (hasLoc) ...[
            const SizedBox(height: 12),
            Card(elevation: 1, color: Colors.green.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [const Icon(Icons.location_on, color: Colors.green), const SizedBox(width: 8), Expanded(child: Text(cubit.pickupAddress ?? ''))]))),
          ],
          const SizedBox(height: 16),
          // Pickup Type
          const Text('Pickup Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _pt(cubit, Icons.calendar_month, 'Routine', PickupType.routine)),
            const SizedBox(width: 8),
            Expanded(child: _pt(cubit, Icons.touch_app, 'Manual', PickupType.manual)),
          ]),
          const SizedBox(height: 12),
          TextField(maxLines: 2, decoration: const InputDecoration(hintText: 'Notes (optional)', border: OutlineInputBorder()), onChanged: (v) => cubit.addNotes(v)),
          const SizedBox(height: 20),
          // Submit
          SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5A27), disabledBackgroundColor: Colors.grey.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: _submitting ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(canSubmit ? 'Submit Order' : 'Set location & type', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _dd(String? value, String label, List<String> items, Function(String?) onChange) {
    return DropdownButtonFormField<String>(value: value, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChange);
  }

  Widget _pt(SellWizardCubit cubit, IconData icon, String label, PickupType type) {
    final sel = cubit.pickupType == type;
    return GestureDetector(
      onTap: () { cubit.selectPickupType(type); setState(() {}); },
      child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: sel ? Colors.green.withValues(alpha: 0.1) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? Colors.green : Colors.grey.shade300, width: sel ? 2 : 1)), child: Column(children: [Icon(icon, color: sel ? Colors.green : Colors.grey, size: 28), const SizedBox(height: 4), Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: sel ? Colors.green : Colors.black87))])),
    );
  }
}
