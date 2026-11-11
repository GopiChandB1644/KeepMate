# KeepMate

> **"Everything important. One place. Never forgotten."**

KeepMate is a personal organization, document vault, and expiry-tracking Flutter application designed to help users track bills, product warranties, vehicle & personal documents, subscriptions, and grocery expiry dates in one place with automatic reminders and local-first privacy.

The application has been designed so that anyone can use it intuitively without any training or technical jargon: big clear buttons, familiar color-coded status badges, 1-tap quick actions, and effortless wizards.

---

## 🏗️ Architecture & Technology Stack

The project follows the **Feature-First Clean Architecture** with **BLoC/Cubit** pattern established in `movonride_driver`:

- **Platform**: Flutter (Android & iOS)
- **State Management**: `flutter_bloc` (Cubit with immutable states, enum statuses, and copyWith)
- **Routing**: `go_router` with `StatefulShellRoute` (persistent bottom navigation tabs)
- **Database**: SQLite with **Drift** (`drift`, `drift_flutter`, `sqlite3_flutter_libs`)
- **Storage Strategy**: Local-first with sandboxed relative paths (`KeepMate/documents/...`)
- **Reminders**: Shared deterministic reminder engine (`flutter_local_notifications`, `timezone`)
- **Backup & Restore**: Password-protected authenticated `.kmb` container (AES + PBKDF2 + SHA-256 manifest + ZIP archive)
- **Document Scanner & OCR**: Text recognition & pattern parser for bills, policies, expiry dates with user verification

---

## 📁 Project Structure

```
keepmate/
├── docs/
│   ├── IMPLEMENTATION_STATUS.md        # Sprint tracker & phase deliverables
│   └── DATABASE_SCHEMA.md              # Drift tables, schemas, relations & migrations
├── lib/
│   ├── app/
│   │   ├── router/
│   │   │   ├── app_router.dart         # GoRouter with indexed stack shell
│   │   │   └── app_routes.dart         # Canonical route paths
│   │   ├── shell/
│   │   │   └── main_shell.dart         # Bottom navigation bar with Home, Categories, Vault, Settings
│   │   └── keepmate_app.dart           # Root MaterialApp with reactive theme switcher
│   ├── core/
│   │   ├── constants/                  # App constants & channel IDs
│   │   ├── enums/                      # ItemCategory, ItemSubcategory, ItemStatus, StorageLocation
│   │   ├── errors/                     # AppException hierarchy
│   │   ├── design_system/              # AppColors (Light & Dark), AppText, AppTheme
│   │   ├── database/                   # Drift AppDatabase, Tables, DAOs & Migrations
│   │   ├── storage/                    # LocalFileStorage, FilePathResolver, DocumentIntegrityService
│   │   ├── notifications/              # NotificationService, ReminderScheduler, RecoveryService
│   │   ├── backup/                     # KMB encryption, archive, manifest, export & import services
│   │   └── utils/                      # AppDateUtils (relative labels, dynamic status derivation)
│   ├── shared/
│   │   └── widgets/                    # ItemSummaryCard, StatusChip, EmptyStateView
│   ├── features/
│   │   ├── home/                       # Dashboard, urgent action banners, status counters, recent items
│   │   ├── categories/                 # Category hub with visual navigation tiles
│   │   ├── life_pocket/                # Bills, warranties, insurance, subscriptions, purchases
│   │   ├── fresh_check/                # Groceries, batch tracking, storage locations, consumed/discarded
│   │   ├── doc_alert/                  # Driving licence, vehicle insurance, PUC, passport, renewals
│   │   ├── document_vault/             # Central document library, previewer, multi-format attachments
│   │   ├── document_scanner/           # OCR parser service & review flow
│   │   ├── tracked_items/              # Unified CRUD engine, Add/Edit wizard, Renewal flow, Item details
│   │   ├── backup_restore/             # .kmb export, import, password verification, share sheet
│   │   └── settings/                   # Storage breakdown, theme mode, notification preferences
│   ├── state_injector.dart             # Central AppStateInjector (RepositoryProvider & BlocProvider)
│   └── main.dart                       # Main entrypoint, notification init, recovery startup
└── test/
    ├── unit/
    │   ├── item_status_test.dart       # Lifecycle status & relative time calculation tests
    │   ├── ocr_parser_test.dart        # Insurance & bill text recognition parser tests
    │   └── backup_encryption_test.dart # Authenticated PBKDF2/AES encryption, password & tampering tests
    └── widget/
        └── home_page_test.dart         # Card rendering and interaction widget tests
```

---

## 🚀 Key Modules & Product Flow

### 1. Unified Home Dashboard
- **Urgency Banner**: Highlights items expiring today or in the next 7 days in color-coded cards (Red = Due Today / Overdue, Orange = Due Soon, Green = Safe).
- **Status Badges**: Real-time counter of Due Today, Due Soon, and Total Active items.
- **1-Tap Quick Actions**: "Mark as Paid" for bills, "Used Up" for groceries, and "Renew" for vehicle insurance/licence.
- **Floating "+ Add Item" Button**: Accessible instantly from anywhere in the app.

### 2. LifePocket (Personal & Financial Items)
- Manages utility bills, warranties, insurances, subscriptions, and purchases.
- Stores provider name, account/consumer number, amount, and payment status.
- One-tap "Mark Paid" lifecycle transition.

### 3. FreshCheck (Groceries & Food Expiries)
- Supports **separate purchase batches** (e.g. Milk bought Monday vs Wednesday).
- Filter by storage locations: **Fridge ❄️, Freezer 🧊, Pantry 🥫, Medicine Box 💊**.
- One-tap "Used Up / Consumed" and "Discarded" actions.

### 4. DocAlert (Vehicle & Official Documents)
- Tracks driving licences, vehicle insurances, PUC, and passports.
- **Renewal Workflow**: When renewed, the original expired record is preserved in history and linked to the new record with the new expiry date and policy document without losing historical data.

### 5. Document Vault & Scanner
- Central repository for PDF, PNG, and JPG files.
- Attached to tracked items or stored independently.
- OCR text recognition extracts dates, policy numbers, amounts, and vehicle numbers for user review.

### 6. Encrypted Backup & Restore (.kmb)
- Standalone `.kmb` container format with PBKDF2-HMAC-SHA256 key derivation and AES authenticated encryption.
- Validates SHA-256 checksums of all documents and rolls back safely if corrupted or wrong password entered.
- One-click share via email, Google Drive, WhatsApp, or local file manager.
- Rebuilds all scheduled notifications after restore from SQLite.

---

## 🧪 Verification & Quality

- **Static Analysis**: `flutter analyze` completed with **0 issues**.
- **Test Suite**: `flutter test` passed **100% of unit and widget tests**.
