import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/admin/data/models/location_models.dart';
import '../../../../shared/data/kenya_locations.dart';

class FleetManagementScreen extends StatefulWidget {
  const FleetManagementScreen({super.key});

  @override
  State<FleetManagementScreen> createState() => _FleetManagementScreenState();
}

class _FleetManagementScreenState extends State<FleetManagementScreen> {
  // Selected values for location
  String? _selectedCounty;
  String? _selectedSubCounty;
  String? _selectedWard;
  String? _selectedDriverId;
  String? _selectedDriverName;
  String? _selectedDestination;

  // Controllers
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // List of farmers with their locations
  List<Map<String, dynamic>> _availableFarmers = [];
  bool _loadingFarmers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Management'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          _buildStatsSection(),
          const SizedBox(height: 16),
          // Fleet List
          Expanded(
            child: _buildFleetList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAssignRouteDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Assign Route'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ── Stats Section ──
  Widget _buildStatsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'driver')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildStatsCard(0, 0, 0);
        }

        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final drivers = snapshot.data!.docs;
        int active = 0;
        int idle = 0;
        int maintenance = 0;

        for (var doc in drivers) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'idle';
          switch (status.toString().toLowerCase()) {
            case 'active':
              active++;
              break;
            case 'maintenance':
              maintenance++;
              break;
            default:
              idle++;
          }
        }

        return _buildStatsCard(active, idle, maintenance);
      },
    );
  }

  Widget _buildStatsCard(int active, int idle, int maintenance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Active', active, Colors.green),
          _buildStatItem('Idle', idle, Colors.orange),
          _buildStatItem('Maintenance', maintenance, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ── Fleet List ──
  Widget _buildFleetList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'driver')
          .orderBy('fullName')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 8),
                Text(
                  'Error loading fleet: ${snapshot.error}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text(
                  'No drivers registered',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to register driver
                  },
                  child: const Text('Register Driver'),
                ),
              ],
            ),
          );
        }

        final drivers = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            final driver = drivers[index];
            return _buildDriverCard(context, driver);
          },
        );
      },
    );
  }

  Widget _buildDriverCard(BuildContext context, DocumentSnapshot driver) {
    final data = driver.data() as Map<String, dynamic>;

    final name = data['fullName'] ?? data['name'] ?? 'Unknown Driver';
    final phone = data['phoneNumber'] ?? data['phone'] ?? 'N/A';
    final email = data['email'] ?? 'N/A';
    final vehicle = data['vehicle'] ?? data['vehicleNumber'] ?? 'N/A';
    final status = data['status'] ?? 'idle';
    final progress = data['routeProgress'] ?? 0.0;
    final location = data['currentLocation'] ?? data['county'] ?? 'Unknown';

    Color statusColor;
    IconData statusIcon;
    switch (status.toString().toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.route;
        break;
      case 'maintenance':
        statusColor = Colors.red;
        statusIcon = Icons.build;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pause;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name + Status
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Colors.green.shade800,
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
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        vehicle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status.toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(Icons.phone, 'Phone', phone),
                ),
                Expanded(
                  child: _buildDetailItem(Icons.email, 'Email', email),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(Icons.location_on, 'Location', location),
                ),
                Expanded(
                  child: _buildDetailItem(Icons.calendar_today, 'Joined',
                      data['createdAt'] != null
                          ? _formatDate((data['createdAt'] as Timestamp).toDate())
                          : 'N/A'
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar (only if active)
            if (status == 'active') ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Route Progress',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Action Buttons with Wrap
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (status == 'active')
                  ElevatedButton.icon(
                    onPressed: () {
                      // Pass the full route data to the driver
                      final assignedRoute = data['assignedRoute'] as Map<String, dynamic>?;
                      if (assignedRoute != null) {
                        Navigator.pushNamed(
                          context,
                          '/driver/route',
                          arguments: {
                            'routeName': assignedRoute['routeName'],
                            'pickupLocation': assignedRoute['pickupLocation'],
                            'destination': assignedRoute['destination'],
                            'scheduledDate': assignedRoute['scheduledDate'],
                            'driverData': data,
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No route assigned'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text('View Route'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAssignRouteDialog(
                      context,
                      driverId: driver.id,
                      driverName: name,
                    );
                  },
                  icon: const Icon(Icons.route, size: 16),
                  label: Text(
                    status == 'active' ? 'Update Route' : 'Assign Route',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status == 'active' ? Colors.orange : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Assign Route Dialog with Location Selection ──
  void _showAssignRouteDialog(
      BuildContext context, {
        String? driverId,
        String? driverName,
      }) {
    _selectedDriverId = driverId;
    _selectedDriverName = driverName;
    _selectedCounty = null;
    _selectedSubCounty = null;
    _selectedWard = null;
    _selectedDestination = null;
    _availableFarmers = [];
    _loadingFarmers = false;
    _routeController.clear();
    _dateController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              driverId != null ? 'Update Route for $driverName' : 'Assign New Route',
              style: const TextStyle(fontSize: 18),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Location Selection (FIRST - Admin selects location) ──
                    const Text(
                      '📍 Select Pickup Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // County Dropdown
                    _buildCountyDropdown(setDialogState),
                    const SizedBox(height: 8),

                    // SubCounty Dropdown
                    _buildSubCountyDropdown(setDialogState),
                    const SizedBox(height: 8),

                    // Ward Dropdown
                    _buildWardDropdown(setDialogState),
                    const SizedBox(height: 16),

                    // ── Driver Selection (Filtered by location) ──
                    const Text(
                      '🚗 Select Driver (Filtered by Location)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFilteredDriverDropdown(setDialogState),
                    const SizedBox(height: 16),

                    // ── Route Name ──
                    TextField(
                      controller: _routeController,
                      decoration: const InputDecoration(
                        labelText: 'Route Name/Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.route),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Destination ──
                    const Text(
                      'Destination (Dropoff Location)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Destination Dropdown
                    _buildDestinationDropdown(setDialogState),
                    const SizedBox(height: 12),

                    // ── Date & Time ──
                    TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date & Time',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() {
                              _dateController.text =
                              '${date.day}/${date.month}/${date.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        }
                      },
                    ),

                    // ── Show Selected Location Summary ──
                    if (_selectedCounty != null && _selectedWard != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '📍 Selected Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'County: $_selectedCounty',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (_selectedSubCounty != null)
                                Text(
                                  'Sub-County: $_selectedSubCounty',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (_selectedWard != null)
                                Text(
                                  'Ward: $_selectedWard',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (_selectedDriverName != null)
                                Text(
                                  'Driver: $_selectedDriverName',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (_selectedDestination != null)
                                Text(
                                  'Destination: $_selectedDestination',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _assignRoute(
                    context,
                    driverId: _selectedDriverId,
                    route: _routeController.text,
                    county: _selectedCounty,
                    subCounty: _selectedSubCounty,
                    ward: _selectedWard,
                    destination: _selectedDestination,
                    date: _dateController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Assign Route'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Filtered Driver Dropdown (Based on Location) ──
  Widget _buildFilteredDriverDropdown(StateSetter setDialogState) {
    // If no location selected, show a message
    if (_selectedCounty == null || _selectedWard == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Please select a location first to see available drivers',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'driver')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final allDrivers = snapshot.data!.docs;

        // Filter drivers by location
        final filteredDrivers = allDrivers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final driverCounty = data['county'] ?? data['currentLocation'] ?? '';
          final driverStatus = data['status'] ?? 'idle';

          final isInSameCounty = driverCounty.toLowerCase().contains(_selectedCounty!.toLowerCase());
          final isAvailable = driverStatus == 'idle' || driverStatus == 'active';

          return (isInSameCounty || isAvailable) && driverStatus != 'maintenance';
        }).toList();

        if (filteredDrivers.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No drivers available in this area. Try selecting a different location.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Select Driver',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          value: _selectedDriverId,
          isExpanded: true,
          items: filteredDrivers.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['fullName'] ?? data['name'] ?? 'Unknown';
            final driverCounty = data['county'] ?? data['currentLocation'] ?? 'Unknown';
            final status = data['status'] ?? 'idle';
            final isInSameCounty = driverCounty.toLowerCase().contains(_selectedCounty!.toLowerCase());

            return DropdownMenuItem<String>(
              value: doc.id,
              child: Row(
                children: [
                  Icon(
                    isInSameCounty ? Icons.check_circle : Icons.location_on,
                    color: isInSameCounty ? Colors.green : Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          '📍 $driverCounty',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: isInSameCounty ? Colors.green.shade700 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isInSameCounty ? Colors.green.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isInSameCounty ? Colors.green.shade700 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setDialogState(() {
              _selectedDriverId = value;
              final doc = filteredDrivers.firstWhere((d) => d.id == value);
              final data = doc.data() as Map<String, dynamic>;
              _selectedDriverName = data['fullName'] ?? data['name'] ?? 'Unknown';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a driver';
            }
            return null;
          },
        );
      },
    );
  }

  // ── County Dropdown ──
  Widget _buildCountyDropdown(StateSetter setDialogState) {
    final counties = KenyaLocations.getDefaultCounties();
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select County',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_on),
      ),
      value: _selectedCounty,
      isExpanded: true,
      items: counties.map((county) {
        return DropdownMenuItem<String>(
          value: county.name,
          child: Text(
            county.name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setDialogState(() {
          _selectedCounty = value;
          _selectedSubCounty = null;
          _selectedWard = null;
          _selectedDriverId = null;
          _selectedDriverName = null;
        });
      },
    );
  }

  // ── SubCounty Dropdown ──
  Widget _buildSubCountyDropdown(StateSetter setDialogState) {
    final subCounties = _selectedCounty != null
        ? KenyaLocations.getSubCountyNames(_selectedCounty!)
        : [];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select Sub-County',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_city),
      ),
      value: _selectedSubCounty,
      isExpanded: true,
      items: subCounties.map((subCounty) {
        return DropdownMenuItem<String>(
          value: subCounty,
          child: Text(
            subCounty,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setDialogState(() {
          _selectedSubCounty = value;
          _selectedWard = null;
          _selectedDriverId = null;
          _selectedDriverName = null;
        });
      },
    );
  }

  // ── Ward Dropdown ──
  Widget _buildWardDropdown(StateSetter setDialogState) {
    final wards = _selectedCounty != null && _selectedSubCounty != null
        ? KenyaLocations.getWardNames(_selectedCounty!, _selectedSubCounty!)
        : [];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select Ward',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_pin),
      ),
      value: _selectedWard,
      isExpanded: true,
      isDense: true,
      items: wards.map((ward) {
        return DropdownMenuItem<String>(
          value: ward,
          child: Text(
            ward,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setDialogState(() {
          _selectedWard = value;
          _selectedDriverId = null;
          _selectedDriverName = null;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a ward';
        }
        return null;
      },
    );
  }

  // ── Destination Dropdown ──
  Widget _buildDestinationDropdown(StateSetter setDialogState) {
    final destinations = KenyaLocations.getDestinationNames();

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select Destination',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_city),
      ),
      value: _selectedDestination,
      isExpanded: true,
      isDense: true,
      items: destinations.map((destination) {
        return DropdownMenuItem<String>(
          value: destination,
          child: Text(
            destination,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setDialogState(() {
          _selectedDestination = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a destination';
        }
        return null;
      },
    );
  }

  // ── Assign Route to Driver with Coordinates ──
  Future<void> _assignRoute(
      BuildContext context, {
        String? driverId,
        required String route,
        String? county,
        String? subCounty,
        String? ward,
        String? destination,
        required String date,
      }) async {
    // Validation
    if (route.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a route name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (county == null || ward == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location (County and Ward)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (destination == null || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a destination'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (driverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a driver'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Get the selected driver's data
      final driverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(driverId)
          .get();
      final driverData = driverDoc.data() as Map<String, dynamic>;
      final driverName = driverData['fullName'] ?? driverData['name'] ?? 'Unknown';

      // ─── GET COORDINATES FOR PICKUP LOCATION ───
      final pickupCoords = KenyaLocations.getLocationCoordinates(
        county: county!,
        subCounty: subCounty,
        ward: ward,
      );

      // ─── GET COORDINATES FOR DESTINATION ───
      final destCoords = KenyaLocations.getDestinationLocation(destination!);

      // Build the full location string
      String pickupLocation = ward!;
      if (subCounty != null) pickupLocation = '$pickupLocation, $subCounty';
      if (county != null) pickupLocation = '$pickupLocation, $county';

      // Build the route data with coordinates
      final Map<String, dynamic> assignedRoute = {
        'routeName': route,
        'pickupLocation': {
          'county': county,
          'subCounty': subCounty,
          'ward': ward,
          'fullAddress': pickupLocation,
        },
        'destination': destination,
        'scheduledDate': date,
        'assignedAt': FieldValue.serverTimestamp(),
        'assignedBy': 'Admin',
      };

      // Add coordinates if available
      if (pickupCoords != null) {
        assignedRoute['pickupLocation']['latitude'] = pickupCoords.latitude;
        assignedRoute['pickupLocation']['longitude'] = pickupCoords.longitude;
        print('✅ Pickup coordinates: ${pickupCoords.latitude}, ${pickupCoords.longitude}');
      } else {
        print('⚠️ No pickup coordinates found for: $county, $subCounty, $ward');
      }

      if (destCoords != null) {
        assignedRoute['destinationLat'] = destCoords.latitude;
        assignedRoute['destinationLng'] = destCoords.longitude;
        print('✅ Destination coordinates: ${destCoords.latitude}, ${destCoords.longitude}');
      } else {
        print('⚠️ No destination coordinates found for: $destination');
      }

      // Update driver in users collection with route information including coordinates
      await FirebaseFirestore.instance
          .collection('users')
          .doc(driverId)
          .update({
        'status': 'active',
        'routeProgress': 0.0,
        'assignedRoute': assignedRoute,
        'currentLocation': pickupLocation,
      });

      Navigator.pop(context); // Close dialog

      // Show success message with coordinates info
      final coordsStatus = pickupCoords != null && destCoords != null
          ? ' with accurate GPS coordinates!'
          : ' (some locations may need manual GPS)';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Route assigned to $driverName$coordsStatus'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('❌ Error assigning route: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning route: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()}mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}