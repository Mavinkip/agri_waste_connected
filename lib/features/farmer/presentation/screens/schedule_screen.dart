import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';


import '../../data/repositories/farmer_repository.dart';
import '../bloc/farmer_bloc.dart';


import '../widgets/profile_menu.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FarmerBloc>().add(const LoadRoutineSchedule());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calendar_month_rounded, size: 26),
            SizedBox(width: 10),
            Text('Pickup Schedule'),
          ],
        ),
        actions: const [
          FarmerAppMenu(),
          SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<FarmerBloc, FarmerState>(
        builder: (context, state) {
          if (state is FarmerScheduleLoading || state is FarmerLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (state is FarmerScheduleLoaded) {
            return _buildScheduleContent(state.schedules);
          }

          if (state is FarmerError) {
            return _buildErrorWidget(state.message);
          }

          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        },
      ),
    );
  }

  Widget _buildScheduleContent(List<RoutineSchedule> schedules) {
    if (schedules.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FarmerBloc>().add(const LoadRoutineSchedule());
      },
      color: AppColors.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D5A27), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Routine Pickups',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your waste will be picked up automatically on scheduled days. '
                    'No need to create manual listings!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Schedule List
            const Text(
              'Your Schedule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 12),

            ...schedules.map((schedule) => _ScheduleCard(schedule: schedule)),

            const SizedBox(height: 24),

            // Update Schedule Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _showUpdateScheduleDialog(context),
                icon: const Icon(Icons.edit_calendar_rounded),
                label: const Text(
                  'Update Schedule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 64,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Schedule Set',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set up routine pickups and we\'ll\ncollect your waste automatically!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.mediumGray,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _showUpdateScheduleDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Set Up Schedule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<FarmerBloc>().add(const LoadRoutineSchedule());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateScheduleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _ScheduleForm(),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final RoutineSchedule schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final isActive = schedule.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primaryGreen.withOpacity(0.3) : Colors.grey.shade200,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Day icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryGreen.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getDayIcon(schedule.dayOfWeek),
              color: isActive ? AppColors.primaryGreen : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Schedule details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      schedule.dayOfWeek ?? 'Not Set',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppColors.darkGray : Colors.grey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.success.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Paused',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive ? AppColors.success : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: isActive ? AppColors.mediumGray : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      schedule.timeSlot ?? 'Flexible',
                      style: TextStyle(
                        fontSize: 14,
                        color: isActive ? AppColors.mediumGray : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.repeat_rounded,
                      size: 16,
                      color: isActive ? AppColors.mediumGray : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Weekly',
                      style: TextStyle(
                        fontSize: 14,
                        color: isActive ? AppColors.mediumGray : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Toggle switch
          Switch(
            value: isActive,
            onChanged: (value) {
              context.read<FarmerBloc>().add(
                    UpdateRoutineSchedule(
                      isActive: value,
                       preferredDay: schedule.dayOfWeek,
                       preferredTimeSlot: schedule.timeSlot,
                    ),
                  );
            },
            activeThumbColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  IconData _getDayIcon(String? day) {
    switch (day?.toLowerCase()) {
      case 'monday':
        return Icons.looks_one_rounded;
      case 'tuesday':
        return Icons.looks_two_rounded;
      case 'wednesday':
        return Icons.looks_3_rounded;
      case 'thursday':
        return Icons.looks_4_rounded;
      case 'friday':
        return Icons.looks_5_rounded;
      case 'saturday':
        return Icons.looks_6_rounded;
      case 'sunday':
        return Icons.calendar_today_rounded;
      default:
        return Icons.calendar_month_rounded;
    }
  }
}

class _ScheduleForm extends StatefulWidget {
  const _ScheduleForm();

  @override
  State<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<_ScheduleForm> {
  bool _isActive = true;
  String _selectedDay = 'Monday';
  String _selectedTimeSlot = 'Morning (6AM - 10AM)';

  final _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final _timeSlots = [
    'Morning (6AM - 10AM)',
    'Midday (10AM - 2PM)',
    'Afternoon (2PM - 6PM)',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Update Pickup Schedule',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 24),

          // Active toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Enable Routine Pickups',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeThumbColor: AppColors.primaryGreen,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Day selection
          const Text(
            'Preferred Day',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _days.map((day) {
              final isSelected = _selectedDay == day;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = day),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    day.substring(0, 3),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.darkGray,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Time slot selection
          const Text(
            'Preferred Time',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          ..._timeSlots.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            return RadioListTile<String>(
              value: slot,
              groupValue: _selectedTimeSlot,
              onChanged: (value) => setState(() => _selectedTimeSlot = value!),
              title: Text(slot, style: const TextStyle(fontSize: 14)),
              activeColor: AppColors.primaryGreen,
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.read<FarmerBloc>().add(
                      UpdateRoutineSchedule(
                        isActive: _isActive,
                        preferredDay: _selectedDay,
                        preferredTimeSlot: _selectedTimeSlot,
                      ),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Schedule updated successfully!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save Schedule',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
