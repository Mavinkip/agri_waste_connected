#!/bin/bash

# Function to create a basic screen file
create_screen() {
  local file=$1
  local classname=$2
  local has_param=$3
  local param_name=$4
  
  if [ "$has_param" = "true" ]; then
    cat > "$file" << 'SCREENEOF'
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class CLASSNAME extends StatelessWidget {
  const CLASSNAME({required this.PARAM_NAME, super.key});
  
  final String PARAM_NAME;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('CLASSNAME'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CLASSNAME - UI Coming Soon',
              style: const TextStyle(fontSize: 18),
            ),
            if (PARAM_NAME.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('ID: $PARAM_NAME'),
              ),
          ],
        ),
      ),
    );
  }
}
SCREENEOF
    # Replace placeholders
    sed -i "s/CLASSNAME/$classname/g" "$file"
    sed -i "s/PARAM_NAME/$param_name/g" "$file"
  else
    cat > "$file" << 'SCREENEOF'
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class CLASSNAME extends StatelessWidget {
  const CLASSNAME({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('CLASSNAME'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: const Center(
        child: Text('CLASSNAME - UI Coming Soon'),
      ),
    );
  }
}
SCREENEOF
    sed -i "s/CLASSNAME/$classname/g" "$file"
  fi
}

# Create all screens
create_screen "lib/features/auth/presentation/screens/register_screen.dart" "RegisterScreen" false ""
create_screen "lib/features/auth/presentation/screens/farm_location_screen.dart" "FarmLocationScreen" false ""
create_screen "lib/features/auth/presentation/screens/waste_profile_screen.dart" "WasteProfileScreen" false ""

create_screen "lib/features/farmer/presentation/screens/farmer_home_screen.dart" "FarmerHomeScreen" false ""
create_screen "lib/features/farmer/presentation/screens/earnings_history_screen.dart" "EarningsHistoryScreen" false ""
create_screen "lib/features/farmer/presentation/screens/schedule_screen.dart" "ScheduleScreen" false ""

create_screen "lib/features/farmer/presentation/screens/sell_waste/waste_type_screen.dart" "WasteTypeScreen" false ""
create_screen "lib/features/farmer/presentation/screens/sell_waste/quantity_screen.dart" "QuantityScreen" false ""
create_screen "lib/features/farmer/presentation/screens/sell_waste/photo_screen.dart" "PhotoScreen" false ""
create_screen "lib/features/farmer/presentation/screens/sell_waste/confirm_location_screen.dart" "ConfirmLocationScreen" false ""
create_screen "lib/features/farmer/presentation/screens/sell_waste/success_screen.dart" "SuccessScreen" false ""

create_screen "lib/features/driver/presentation/screens/driver_home_screen.dart" "DriverHomeScreen" false ""
create_screen "lib/features/driver/presentation/screens/arrival_screen.dart" "ArrivalScreen" true "collectionId"
create_screen "lib/features/driver/presentation/screens/routine_evaluation_screen.dart" "RoutineEvaluationScreen" true "collectionId"
create_screen "lib/features/driver/presentation/screens/weigh_in_screen.dart" "WeighInScreen" true "collectionId"
create_screen "lib/features/driver/presentation/screens/quality_check_screen.dart" "QualityCheckScreen" true "collectionId"
create_screen "lib/features/driver/presentation/screens/payment_confirm_screen.dart" "PaymentConfirmScreen" true "collectionId"

create_screen "lib/features/admin/presentation/screens/admin_dashboard_screen.dart" "AdminDashboardScreen" false ""
create_screen "lib/features/admin/presentation/screens/fleet_screen.dart" "FleetScreen" false ""
create_screen "lib/features/admin/presentation/screens/pricing_screen.dart" "PricingScreen" false ""
create_screen "lib/features/admin/presentation/screens/inventory_screen.dart" "InventoryScreen" false ""
create_screen "lib/features/admin/presentation/screens/routine_management_screen.dart" "RoutineManagementScreen" false ""
create_screen "lib/features/admin/presentation/screens/farmer_profile_screen.dart" "FarmerProfileScreen" true "farmerId"

echo "✅ All screens fixed!"
