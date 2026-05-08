import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/services/navigation_service.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text(AppStrings.driverHome),
=======
        title: Text(AppStrings.driverHome),
>>>>>>> upstream/master
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              NavigationService.pushReplacement('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Today', '5', 'collections'),
                      _buildStat('Completed', '42', 'total'),
                      _buildStat('Rating', '4.8', '⭐'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
<<<<<<< HEAD

=======
            
>>>>>>> upstream/master
            // Today's Schedule
            const Text(
              "Today's Collections",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildCollectionCard(
                    farmer: 'John\'s Farm',
                    wasteType: 'Crop Residue',
                    weight: '500 kg',
                    distance: '2.5 km',
                    onTap: () {
                      NavigationService.push('/driver/arrival');
                    },
                  ),
                  _buildCollectionCard(
                    farmer: 'Green Acres',
                    wasteType: 'Fruit Waste',
                    weight: '300 kg',
                    distance: '4.2 km',
                    onTap: () {
                      NavigationService.push('/driver/arrival');
                    },
                  ),
                  _buildCollectionCard(
                    farmer: 'Sunrise Farm',
                    wasteType: 'Vegetable Waste',
                    weight: '450 kg',
                    distance: '6.8 km',
                    onTap: () {
                      NavigationService.push('/driver/arrival');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD

=======
  
>>>>>>> upstream/master
  Widget _buildStat(String label, String value, String subtitle) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
<<<<<<< HEAD

=======
  
>>>>>>> upstream/master
  Widget _buildCollectionCard({
    required String farmer,
    required String wasteType,
    required String weight,
    required String distance,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          child: const Icon(Icons.person, color: AppColors.primaryBlue),
        ),
        title: Text(farmer),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$wasteType • $weight'),
<<<<<<< HEAD
            Text('📍 $distance away',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
=======
            Text('📍 $distance away', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
>>>>>>> upstream/master
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
          ),
          child: const Text('Start'),
        ),
      ),
    );
  }
}
