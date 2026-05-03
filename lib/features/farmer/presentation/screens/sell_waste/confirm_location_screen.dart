import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _counties = KenyaLocations.getCountyNames();
  }

  void _onCountyChanged(String? v) {
    setState(() {
      _selectedCounty = v;
      _selectedSubCounty = null;
      _selectedWard = null;
      _subCounties = v != null ? KenyaLocations.getSubCountyNames(v) : [];
      _wards = [];
    });
  }

  void _onSubCountyChanged(String? v) {
    setState(() {
      _selectedSubCounty = v;
      _selectedWard = null;
      _wards = (v != null && _selectedCounty != null) ? KenyaLocations.getWardNames(_selectedCounty!, v) : [];
    });
  }

  void _setLocation() {
    if (_selectedCounty == null || _selectedSubCounty == null) return;
    String address = _villageController.text.isNotEmpty
        ? '${_villageController.text}, ${_selectedWard ?? ""}, $_selectedSubCounty, $_selectedCounty'
        : '${_selectedWard ?? ""}, $_selectedSubCounty, $_selectedCounty';
    context.read<SellWizardCubit>().updatePickupLocation(latitude: '-0.3031', longitude: '36.0800', address: address.trim());
    setState(() {});
  }

  @override
  void dispose() {
    _villageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellWizardCubit>();
    final hasLocation = cubit.pickupLat != null;
    final canSubmit = hasLocation && cubit.pickupType != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Location'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        actions: const [FarmerAppMenu(currentScreen: 'sell')],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LinearProgressIndicator(value: 1.0, backgroundColor: Colors.grey.shade200),
          const SizedBox(height: 16),
          const Text('Where is your farm?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedCounty,
            decoration: const InputDecoration(labelText: 'County', border: OutlineInputBorder()),
            items: _counties.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: _onCountyChanged,
          ),
          const SizedBox(height: 12),

          if (_selectedCounty != null)
            DropdownButtonFormField<String>(
              value: _selectedSubCounty,
              decoration: const InputDecoration(labelText: 'Sub-County', border: OutlineInputBorder()),
              items: _subCounties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: _onSubCountyChanged,
            ),
          if (_selectedCounty != null) const SizedBox(height: 12),

          if (_selectedSubCounty != null)
            DropdownButtonFormField<String>(
              value: _selectedWard,
              decoration: const InputDecoration(labelText: 'Ward/Location', border: OutlineInputBorder()),
              items: _wards.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
              onChanged: (v) => setState(() => _selectedWard = v),
            ),
          if (_selectedSubCounty != null) const SizedBox(height: 12),

          if (_selectedSubCounty != null)
            TextField(controller: _villageController, decoration: const InputDecoration(labelText: 'Village (optional)', hintText: 'e.g., Kijabe', border: OutlineInputBorder())),
          if (_selectedSubCounty != null) const SizedBox(height: 8),

          if (_selectedSubCounty != null)
            SizedBox(width: double.infinity, height: 42, child: ElevatedButton.icon(onPressed: _setLocation, icon: const Icon(Icons.check_circle, size: 18), label: const Text('Set Location'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue))),
          if (_selectedSubCounty != null) const SizedBox(height: 12),

          if (hasLocation)
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade200)), child: Row(children: [const Icon(Icons.location_on, color: Colors.green), const SizedBox(width: 8), Expanded(child: Text(cubit.pickupAddress ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))), const Icon(Icons.check_circle, color: Colors.green, size: 20)])),
          if (hasLocation) const SizedBox(height: 12),

          const Text('Pickup Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _pickupType(cubit, Icons.calendar_month, 'Routine', PickupType.routine)),
            const SizedBox(width: 8),
            Expanded(child: _pickupType(cubit, Icons.touch_app, 'Manual', PickupType.manual)),
          ]),
          const SizedBox(height: 10),

          TextField(maxLines: 2, decoration: const InputDecoration(hintText: 'Notes for driver (optional)', prefixIcon: Icon(Icons.note_alt_outlined), border: OutlineInputBorder()), onChanged: (v) => cubit.addNotes(v)),
          const SizedBox(height: 20),

          SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: canSubmit ? () => Navigator.of(context).pushNamed('/farmer/sell/success') : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, disabledBackgroundColor: Colors.grey.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Submit Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _pickupType(SellWizardCubit cubit, IconData icon, String label, PickupType type) {
    final selected = cubit.pickupType == type;
    return GestureDetector(
      onTap: () => cubit.selectPickupType(type),
      child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: selected ? Colors.green.withValues(alpha: 0.1) : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? Colors.green : Colors.grey.shade300, width: selected ? 2 : 1)),
        child: Column(children: [Icon(icon, color: selected ? Colors.green : Colors.grey, size: 26), const SizedBox(height: 4), Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: selected ? Colors.green : Colors.black87))])),
    );
  }
}
