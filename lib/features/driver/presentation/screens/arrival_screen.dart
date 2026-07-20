import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/navigation_service.dart';

class ArrivalScreen extends StatefulWidget {
  final String collectionId;
  const ArrivalScreen({super.key, required this.collectionId});

  @override
  State<ArrivalScreen> createState() => _ArrivalScreenState();
}

class _ArrivalScreenState extends State<ArrivalScreen> {
  bool _photoTaken = false;
  bool _isLoading = false;
  Map<String, dynamic>? _collectionData;
  Map<String, dynamic>? _driverData;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final driverDoc = await _firestore.collection('users').doc(user.uid).get();
        if (driverDoc.exists) {
          setState(() {
            _driverData = driverDoc.data() as Map<String, dynamic>;
          });
        }
      }

      final collectionDoc = await _firestore
          .collection('listings')
          .doc(widget.collectionId)
          .get();

      if (collectionDoc.exists) {
        setState(() {
          _collectionData = collectionDoc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> _recordArrival() async {
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('listings').doc(widget.collectionId).update({
        'status': 'arrived',
        'arrivalTime': FieldValue.serverTimestamp(),
        'driverId': user.uid,
        'driverName': _driverData?['fullName'] ?? 'Unknown',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Arrival recorded! Proceed to weigh-in.'),
            backgroundColor: Colors.green,
          ),
        );
        NavigationService.pushNamed('/driver/weigh', arguments: widget.collectionId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recording arrival: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final farmerName = _collectionData?['farmerName'] ?? 'Unknown Farm';
    final wasteType = _collectionData?['wasteType'] ?? 'Waste';
    final quantity = _collectionData?['estimatedQuantity'] ?? 0;
    final county = _collectionData?['county'] ?? '';
    final ward = _collectionData?['ward'] ?? '';

    String location = ward;
    if (county.isNotEmpty) location = '$location, $county';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arrival at Farm'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'YOU HAVE ARRIVED!',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Farm Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.store, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          farmerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location.isNotEmpty ? location : 'Address not provided',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.recycling, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '$wasteType • $quantity kg',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Driver: ${_driverData?['fullName'] ?? 'Unknown'}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.directions_car, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Vehicle: ${_driverData?['vehicle'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Photo Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: _photoTaken ? Colors.green.shade200 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: _photoTaken ? Colors.green.shade50 : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _photoTaken ? Icons.photo_camera : Icons.photo_camera_outlined,
                        color: _photoTaken ? Colors.green.shade700 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _photoTaken ? 'Photo taken ✓' : 'Take photo of waste pile',
                        style: TextStyle(
                          color: _photoTaken ? Colors.green.shade700 : Colors.grey.shade600,
                          fontWeight: _photoTaken ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  if (_photoTaken)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Waste photo captured successfully',
                            style: TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  if (!_photoTaken)
                    const SizedBox(height: 8),
                  if (!_photoTaken)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _photoTaken = true),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Record Weight Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _recordArrival,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'RECORD WEIGHT & CONTINUE',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will now be guided to record the waste weight and complete the collection.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}