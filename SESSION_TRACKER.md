# 🌿 Agri-Waste Connect — Session Tracker

> **HOW TO USE:** At the end of every session, attach this file with the message:
> *"Here is my session tracker. Continue from where we left off."*
> Claude will pick up exactly where we stopped.

---

## 📍 CURRENT STATUS: Session 1 Complete

**What exists right now:** Empty folder structure + pubspec.yaml + this tracker.
**Next session goal:** Fill the BLoC layer (events, states, blocs, cubits) for all 4 features.

---

## ✅ SESSION LOG

### Session 1 — Folder & File Scaffold
**Completed:**
- Created full Flutter project folder structure
- Created all 57 empty `.dart` files in correct locations
- Created `pubspec.yaml` with all 15+ dependencies
- Created this session tracker

**Nothing is implemented yet** — all `.dart` files are empty placeholders.

---

## 🗺️ MASTER BUILD PLAN

### PHASE 1 — Logic Layer (BLoC + Repositories) [NEXT]
Build order (no UI yet — just the brains):

| Step | File | Status |
|------|------|--------|
| 1.1 | `core/constants/app_colors.dart` | ⬜ TODO |
| 1.2 | `core/constants/app_strings.dart` | ⬜ TODO |
| 1.3 | `shared/models/user_model.dart` | ⬜ TODO |
| 1.4 | `shared/models/waste_listing_model.dart` | ⬜ TODO |
| 1.5 | `core/network/api_client.dart` | ⬜ TODO |
| 1.6 | `shared/services/offline_sync_repository.dart` | ⬜ TODO |
| 1.7 | `core/services/connectivity_service.dart` | ⬜ TODO |
| 1.8 | `features/auth/data/repositories/auth_repository.dart` | ⬜ TODO |
| 1.9 | `features/auth/presentation/bloc/auth_event.dart` | ⬜ TODO |
| 1.10 | `features/auth/presentation/bloc/auth_state.dart` | ⬜ TODO |
| 1.11 | `features/auth/presentation/bloc/auth_bloc.dart` | ⬜ TODO |
| 1.12 | `features/farmer/data/repositories/farmer_repository.dart` | ⬜ TODO |
| 1.13 | `features/farmer/data/repositories/listing_repository.dart` | ⬜ TODO |
| 1.14 | `features/farmer/data/repositories/wallet_repository.dart` | ⬜ TODO |
| 1.15 | `features/farmer/presentation/bloc/farmer_event.dart` | ⬜ TODO |
| 1.16 | `features/farmer/presentation/bloc/farmer_state.dart` | ⬜ TODO |
| 1.17 | `features/farmer/presentation/bloc/farmer_bloc.dart` | ⬜ TODO |
| 1.18 | `features/farmer/presentation/bloc/sell_wizard_cubit.dart` | ⬜ TODO |
| 1.19 | `features/driver/data/repositories/collection_repository.dart` | ⬜ TODO |
| 1.20 | `features/driver/presentation/bloc/driver_event.dart` | ⬜ TODO |
| 1.21 | `features/driver/presentation/bloc/driver_state.dart` | ⬜ TODO |
| 1.22 | `features/driver/presentation/bloc/driver_bloc.dart` | ⬜ TODO |
| 1.23 | `features/admin/data/repositories/admin_repositories.dart` | ⬜ TODO |
| 1.24 | `features/admin/presentation/bloc/admin_event.dart` | ⬜ TODO |
| 1.25 | `features/admin/presentation/bloc/admin_state.dart` | ⬜ TODO |
| 1.26 | `features/admin/presentation/bloc/admin_bloc.dart` | ⬜ TODO |
| 1.27 | `core/di/injection.dart` | ⬜ TODO |
| 1.28 | `core/router/app_router.dart` | ⬜ TODO |
| 1.29 | `core/theme/app_theme.dart` | ⬜ TODO |
| 1.30 | `main.dart` | ⬜ TODO |

### PHASE 2 — Auth UI Screens
| Step | File | Priority | Status |
|------|------|----------|--------|
| 2.1 | `auth/screens/splash_screen.dart` | P0 | ⬜ TODO |
| 2.2 | `auth/screens/login_screen.dart` | P0 | ⬜ TODO |
| 2.3 | `auth/screens/register_screen.dart` | P0 | ⬜ TODO |
| 2.4 | `auth/screens/farm_location_screen.dart` | P0 | ⬜ TODO |
| 2.5 | `auth/screens/waste_profile_screen.dart` | P0 | ⬜ TODO |

### PHASE 3 — Farmer UI Screens
| Step | File | Priority | Status |
|------|------|----------|--------|
| 3.1 | `farmer/screens/farmer_home_screen.dart` | P1 | ⬜ TODO |
| 3.2 | `farmer/screens/sell_waste/waste_type_screen.dart` | P2 | ⬜ TODO |
| 3.3 | `farmer/screens/sell_waste/quantity_screen.dart` | P3 | ⬜ TODO |
| 3.4 | `farmer/screens/sell_waste/photo_screen.dart` | P4 | ⬜ TODO |
| 3.5 | `farmer/screens/sell_waste/confirm_location_screen.dart` | P5 | ⬜ TODO |
| 3.6 | `farmer/screens/sell_waste/success_screen.dart` | P5 | ⬜ TODO |
| 3.7 | `farmer/screens/earnings_history_screen.dart` | P6 | ⬜ TODO |
| 3.8 | `farmer/screens/schedule_screen.dart` | P6 | ⬜ TODO |

### PHASE 4 — Driver UI Screens
| Step | File | Priority | Status |
|------|------|----------|--------|
| 4.1 | `driver/screens/driver_home_screen.dart` | P7 | ⬜ TODO |
| 4.2 | `driver/screens/arrival_screen.dart` | P8 | ⬜ TODO |
| 4.3 | `driver/screens/routine_evaluation_screen.dart` | P9 | ⬜ TODO |
| 4.4 | `driver/screens/weigh_in_screen.dart` | P10 | ⬜ TODO |
| 4.5 | `driver/screens/quality_check_screen.dart` | P11 | ⬜ TODO |
| 4.6 | `driver/screens/payment_confirm_screen.dart` | P12 | ⬜ TODO |

### PHASE 5 — Admin UI Screens
| Step | File | Priority | Status |
|------|------|----------|--------|
| 5.1 | `admin/screens/admin_dashboard_screen.dart` | P13 | ⬜ TODO |
| 5.2 | `admin/screens/fleet_screen.dart` | P14 | ⬜ TODO |
| 5.3 | `admin/screens/pricing_screen.dart` | P15 | ⬜ TODO |
| 5.4 | `admin/screens/inventory_screen.dart` | P16 | ⬜ TODO |
| 5.5 | `admin/screens/routine_management_screen.dart` | P17 | ⬜ TODO |
| 5.6 | `admin/screens/farmer_profile_screen.dart` | P18 | ⬜ TODO |

---

## 🧠 KEY DECISIONS & ARCHITECTURE NOTES
(So Claude never needs to re-read the full docs)

- **3 roles:** Farmer (mobile), Driver (mobile offline-first), Admin/Recycler (mobile + web)
- **Single login screen** — server detects role from phone number, returns JWT with role
- **Two pickup modes:** Routine (weekly auto-schedule) or Manual (on-demand)
- **Two-tier pricing:** Base Price (manual) vs Premium Price (routine farmers with high consistency score)
- **Driver evaluation:** After each routine pickup, driver rates quality (1–5 stars) + Continue/Remove
- **Offline-first driver app:** SQLite queue, syncs via ConnectivityService on reconnect
- **Weight is FINAL:** Driver-recorded weight = payout. Farmer estimate = logistics only
- **Photo required:** Driver photos waste before weighing. Farmer can opt out at listing step
- **Payment:** M-Pesa mobile money, triggered automatically after driver confirms quality + signature
- **Minimum threshold:** 2 tonnes nearby before truck dispatched
- **USSD parity:** Every key farmer action also works via USSD *384*50# (no smartphone needed)
- **Brand green:** #1A7A4A | Blue: #1C4E80 | Orange: #D46B08 | Font: Poppins/Arial

## 📁 COMPLETE FILE TREE
```
lib/
├── main.dart
├── core/
│   ├── constants/app_colors.dart
│   ├── constants/app_strings.dart
│   ├── di/injection.dart
│   ├── network/api_client.dart
│   ├── router/app_router.dart
│   ├── services/connectivity_service.dart
│   └── theme/app_theme.dart
├── shared/
│   ├── models/user_model.dart
│   ├── models/waste_listing_model.dart
│   └── services/offline_sync_repository.dart
└── features/
    ├── auth/
    │   ├── data/repositories/auth_repository.dart
    │   └── presentation/
    │       ├── bloc/auth_bloc.dart + auth_event.dart + auth_state.dart
    │       └── screens/
    │           ├── splash_screen.dart
    │           ├── login_screen.dart
    │           ├── register_screen.dart
    │           ├── farm_location_screen.dart
    │           └── waste_profile_screen.dart
    ├── farmer/
    │   ├── data/repositories/
    │   │   ├── farmer_repository.dart
    │   │   ├── listing_repository.dart
    │   │   └── wallet_repository.dart
    │   └── presentation/
    │       ├── bloc/farmer_bloc.dart + farmer_event.dart + farmer_state.dart + sell_wizard_cubit.dart
    │       └── screens/
    │           ├── farmer_home_screen.dart
    │           ├── earnings_history_screen.dart
    │           ├── schedule_screen.dart
    │           └── sell_waste/
    │               ├── waste_type_screen.dart
    │               ├── quantity_screen.dart
    │               ├── photo_screen.dart
    │               ├── confirm_location_screen.dart
    │               └── success_screen.dart
    ├── driver/
    │   ├── data/repositories/collection_repository.dart
    │   └── presentation/
    │       ├── bloc/driver_bloc.dart + driver_event.dart + driver_state.dart
    │       └── screens/
    │           ├── driver_home_screen.dart
    │           ├── arrival_screen.dart
    │           ├── routine_evaluation_screen.dart
    │           ├── weigh_in_screen.dart
    │           ├── quality_check_screen.dart
    │           └── payment_confirm_screen.dart
    └── admin/
        ├── data/repositories/admin_repositories.dart
        └── presentation/
            ├── bloc/admin_bloc.dart + admin_event.dart + admin_state.dart
            └── screens/
                ├── admin_dashboard_screen.dart
                ├── fleet_screen.dart
                ├── pricing_screen.dart
                ├── inventory_screen.dart
                ├── routine_management_screen.dart
                └── farmer_profile_screen.dart
```

---

## ▶️ NEXT SESSION INSTRUCTION
Paste this at the start of next session (attach this file):

> "Here is my session tracker for Agri-Waste Connect. We completed Session 1 (folder scaffold).
> Please now start Phase 1 — fill in the BLoC layer starting from Step 1.1 (app_colors.dart).
> Work through as many steps as tokens allow, then update this tracker before we stop."
