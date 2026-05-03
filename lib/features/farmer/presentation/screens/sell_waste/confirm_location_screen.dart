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
  String? _selectedCounty;
  String? _selectedSubCounty;
  String? _selectedWard;
  final _villageController = TextEditingController();
  List<String> _counties = [];
  List<String> _subCounties = [];
  List<String> _wards = [];
  bool _gpsLoading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _counties = KenyaLocations.getCountyNames();
  }

  Future<void> _useGPS() async {
    setState(() => _gpsLoading = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) { _gpsError('GPS is off. Use manual entry.'); return; }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) { _gpsError('Location denied.'); return; }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        context.read<SellWizardCubit>().updatePickupLocation(
          latitude: pos.latitude.toString(), longitude: pos.longitude.toString(),
          address: 'GPS: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}');
        setState(() => _gpsLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GPS location set!'), backgroundColor: Colors.green));
      }
    } catch (e) { _gpsError('GPS error.'); }
  }

  void _gpsError(String msg) {
    setState(() => _gpsLoading = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _setManual() {
    if (_selectedCounty == null || _selectedSubCounty == null) return;
    String addr = _villageController.text.isNotEmpty
        ? '${_villageController.text}, ${_selectedWard ?? ''}, $_selectedSubCounty, $_selectedCounty'
        : '${_selectedWard ?? ''}, $_selectedSubCounty, $_selectedCounty';
    context.read<SellWizardCubit>().updatePickupLocation(latitude: '-0.3031', longitude: '36.0800', address: addr.trim());
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location set!'), backgroundColor: Colors.green));
  }

  void _submit() {
    setState(() => _submitting = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _submitting = false);
        Navigator.of(context).pushNamed('/farmer/sell/success');
      }
    });
  }

  @override
  void dispose() { _villageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellWizardCubit>();
    final hasLocation = cubit.pickupLat != null;
    final canSubmit = hasLocation && cubit.pickupType != null && !_submitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Pickup Location'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()), actions: const [FarmerAppMenu(currentScreen: 'sell')]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LinearProgressIndicator(value: 1.0, backgroundColor: Colors.grey.shade200),
          const SizedBox(height: 12),
          const Text('Where is your farm?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // MANUAL ENTRY (Primary)
          Text('Select your location:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade700)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(value: _selectedCounty, decoration: const InputDecoration(labelText: 'County', border: OutlineInputBorder()), items: _counties.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() { _selectedCounty = v; _selectedSubCounty = null; _selectedWard = null; _subCounties = v != null ? KenyaLocations.getSubCountyNames(v) : []; _wards = []; })),
          const SizedBox(height: 8),
          if (_selectedCounty != null) DropdownButtonFormField<String>(value: _selectedSubCounty, decoration: const InputDecoration(labelText: 'Sub-County', border: OutlineInputBorder()), items: _subCounties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() { _selectedSubCounty = v; _selectedWard = null; _wards = v != null ? KenyaLocations.getWardNames(_selectedCounty!, v) : []; })),
          const SizedBox(height: 8),
          if (_selectedSubCounty != null) DropdownButtonFormField<String>(value: _selectedWard, decoration: const InputDecoration(labelText: 'Ward/Location', border: OutlineInputBorder()), items: _wards.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(), onChanged: (v) => setState(() => _selectedWard = v)),
          const SizedBox(height: 8),
          if (_selectedSubCounty != null) TextField(controller: _villageController, decoration: const InputDecoration(labelText: 'Village (optional)', hintText: 'e.g., Kijabe', border: OutlineInputBorder())),
          if (_selectedSubCounty != null) const SizedBox(height: 8),
          if (_selectedSubCounty != null) SizedBox(width: double.infinity, height: 38, child: ElevatedButton.icon(onPressed: _setManual, icon: const Icon(Icons.check, size: 16), label: const Text('Set This Location'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue))),

          // GPS (Secondary)
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, height: 36, child: OutlinedButton.icon(onPressed: _gpsLoading ? null : _useGPS, icon: _gpsLoading ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location, size: 16), label: Text(_gpsLoading ? 'Getting GPS...' : 'Use My GPS Location'))),

          if (hasLocation) const SizedBox(height: 12),
          if (hasLocation) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)), child: Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 8), Expanded(child: Text(cubit.pickupAddress ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))])),

          const SizedBox(height: 16),

          // PICKUP TYPE
          const Text('Pickup Type', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _pickupType(cubit, Icons.calendar_month, 'Routine', PickupType.routine)),
            const SizedBox(width: 8),
            Expanded(child: _pickupType(cubit, Icons.touch_app, 'Manual', PickupType.manual)),
          ]),
          const SizedBox(height: 8),
          TextField(maxLines: 2, decoration: const InputDecoration(hintText: 'Notes for driver (optional)', border: OutlineInputBorder()), onChanged: (v) => cubit.addNotes(v)),
          const SizedBox(height: 16),

          // SUBMIT BUTTON
          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, disabledBackgroundColor: Colors.grey.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: _submitting ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)), SizedBox(width: 8), Text('Submitting...')]) : const Text('Submit Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          if (!hasLocation) const SizedBox(height: 6),
          if (!hasLocation) const Text('Set a location and select pickup type', style: TextStyle(color: Colors.grey, fontSize: 12)),
          if (hasLocation && cubit.pickupType == null) const Text('Select pickup type above', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _pickupType(SellWizardCubit cubit, IconData icon, String label, PickupType type) {
    final selected = cubit.pickupType == type;
    return GestureDetector(
      onTap: () => cubit.selectPickupType(type),
      child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: selected ? Colors.green.withValues(alpha: 0.1) : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: selected ? Colors.green : Colors.grey.shade300, width: selected ? 2 : 1)), child: Column(children: [Icon(icon, color: selected ? Colors.green : Colors.grey, size: 22), const SizedBox(height: 2), Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? Colors.green : Colors.black87))])),
    );
  }
}
