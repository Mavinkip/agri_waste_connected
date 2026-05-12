#!/bin/bash
# ─────────────────────────────────────────────
# patch_main.sh — surgical edits to existing files
# Run from project root: bash patch_main.sh
# ─────────────────────────────────────────────
set -e

# ══════════════════════════════════════════════
# 1. Add /farmer/communities route to main.dart
#    Inserts after the /farmer/schedule line
# ══════════════════════════════════════════════
MAIN="lib/main.dart"

# Check if already patched
if grep -q "farmer/communities" "$MAIN"; then
  echo "SKIP: /farmer/communities already in main.dart"
else
  # Add import for JoinCommunityScreen after the schedule import
  sed -i "s|import 'features/farmer/presentation/screens/schedule_screen.dart';|import 'features/farmer/presentation/screens/schedule_screen.dart';\nimport 'features/farmer/presentation/screens/join_community_screen.dart';|" "$MAIN"

  # Add route after /farmer/schedule route
  sed -i "s|'/farmer/schedule': (context) => const ScheduleScreen(),|'/farmer/schedule': (context) => const ScheduleScreen(),\n          '/farmer/communities': (context) => const JoinCommunityScreen(),|" "$MAIN"

  echo "OK: added /farmer/communities to main.dart"
fi

# ══════════════════════════════════════════════
# 2. Wrap AdminDashboardScreen Scaffold with AdminShell
# ══════════════════════════════════════════════
ADMIN="lib/features/admin/presentation/screens/admin_dashboard_screen.dart"

if grep -q "AdminShell" "$ADMIN"; then
  echo "SKIP: AdminShell already in admin_dashboard_screen.dart"
else
  # Add import at top
  sed -i "1s|^|import 'admin_shell.dart';\n|" "$ADMIN"

  # Wrap: change "return Scaffold(" to "return AdminShell(child: Scaffold("
  sed -i "s|return Scaffold(|return AdminShell(child: Scaffold(|" "$ADMIN"

  # Close the AdminShell — find the last closing ); of build method
  # We do this by appending ); after the Scaffold's closing );
  # Strategy: replace the specific pattern at end of build method
  python3 - << 'PYEOF'
import re

with open('lib/features/admin/presentation/screens/admin_dashboard_screen.dart', 'r') as f:
    content = f.read()

# Find the build method and wrap Scaffold properly
# The build method ends with "    );\n  }\n}" pattern
# We need to add extra ); before the last }
old = '      ),\n    );\n  }\n\n  Widget _buildWelcomeCard'
new = '      ),\n    ),\n    );\n  }\n\n  Widget _buildWelcomeCard'

if old in content:
    content = content.replace(old, new, 1)
    with open('lib/features/admin/presentation/screens/admin_dashboard_screen.dart', 'w') as f:
        f.write(content)
    print("OK: AdminShell closing bracket added")
else:
    print("WARN: Could not auto-add AdminShell closing bracket - do it manually")
    print("  Find:    );  // end of SingleChildScrollView")
    print("  Change to:  );  // end of AdminShell")
PYEOF

  echo "OK: wrapped AdminDashboardScreen with AdminShell"
fi

# ══════════════════════════════════════════════
# 3. Verify farmer_home_screen.dart has the
#    correct import path for UserModel
# ══════════════════════════════════════════════
FHOME="lib/features/farmer/presentation/screens/farmer_home_screen.dart"
if grep -q "shared/models/user_model.dart" "$FHOME"; then
  echo "OK: farmer_home_screen.dart import path correct"
else
  echo "WARN: Check import in farmer_home_screen.dart"
fi

echo ""
echo "======================================"
echo "PATCH COMPLETE"
echo "======================================"
echo ""
echo "Run: flutter pub get && flutter run"
echo ""
echo "If you see any compile errors paste them here."
