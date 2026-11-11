# KeepMate – Database Schema & Migration Documentation

**File**: `docs/DATABASE_SCHEMA.md`  
**Database**: SQLite  
**Database Abstraction**: Drift  
**Schema Version**: 1  
**Status**: Implemented  

---

## 1. Overview & Architectural Rules
1. **SQLite is the primary source of truth**; local file storage is private and accessed using relative paths.
2. All access goes through **Repositories** and **DAOs** (`ItemsDao`, `DocumentsDao`, `RemindersDao`, `SettingsDao`). Widgets and Cubits must never execute raw SQL.
3. Every tracked item belongs to one of three product modules:
   - `life_pocket`: Personal items, bills, warranties, insurance, subscriptions, purchases.
   - `fresh_check`: Groceries and consumable products with batch management.
   - `doc_alert`: Official documents, vehicle insurance, driving licence, PUC, passport.
4. **Shared Item Engine**: All items reside in the unified `tracked_items` table with category-specific relational tables (`bill_details`, `warranty_details`, `insurance_details`, `subscription_details`, `purchase_details`, `grocery_details`, `document_details`).
5. **UUIDs** are used for primary keys (`TEXT`).
6. All dates and timestamps are stored in **ISO-8601 UTC** format (`YYYY-MM-DD` or `YYYY-MM-DDTHH:mm:ss.sssZ`).

---

## 2. Table Definitions

### 2.1 `tracked_items` (Parent Table)
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | TEXT | PRIMARY KEY | Unique UUID identifier |
| `category` | TEXT | NOT NULL | `life_pocket`, `fresh_check`, `doc_alert` |
| `subcategory` | TEXT | NOT NULL | `bill`, `warranty`, `grocery`, `insurance`, `subscription`, `purchase`, `document` |
| `title` | TEXT | NOT NULL | Item name or title |
| `description` | TEXT | NULLABLE | Detailed description or user notes |
| `purchase_date` | TEXT | NULLABLE | Purchase date (YYYY-MM-DD) |
| `issue_date` | TEXT | NULLABLE | Issue date (YYYY-MM-DD) |
| `start_date` | TEXT | NULLABLE | Start or validity date (YYYY-MM-DD) |
| `due_date` | TEXT | NULLABLE | Payment or task due date (YYYY-MM-DD) |
| `expiry_date` | TEXT | NULLABLE | Expiry date (YYYY-MM-DD) |
| `status` | TEXT | NOT NULL | `active`, `upcoming`, `due_today`, `expired`, `completed`, `consumed`, `discarded`, `archived` |
| `metadata_json` | TEXT | NOT NULL DEFAULT '{}' | Additional flexible metadata |
| `previous_item_id` | TEXT | NULLABLE | Pointer to prior version in a renewal chain |
| `created_at` | TEXT | NOT NULL | Creation timestamp |
| `updated_at` | TEXT | NOT NULL | Last modification timestamp |
| `deleted_at` | TEXT | NULLABLE | Soft deletion timestamp |

### 2.2 Category-Specific Detail Tables
- **`bill_details`**: `item_id` (PK, FK -> `tracked_items.id`), `provider_name`, `account_number`, `amount` (REAL), `currency_code`, `billing_period`, `payment_status`.
- **`warranty_details`**: `item_id` (PK, FK), `product_name`, `seller`, `purchase_amount` (REAL), `warranty_duration_months` (INT), `warranty_provider`.
- **`insurance_details`**: `item_id` (PK, FK), `provider`, `policy_number`, `vehicle_number`, `coverage_type`, `premium_amount` (REAL).
- **`subscription_details`**: `item_id` (PK, FK), `service_name`, `billing_cycle`, `amount` (REAL), `auto_renew` (BOOLEAN).
- **`purchase_details`**: `item_id` (PK, FK), `product_name`, `seller`, `purchase_amount` (REAL), `return_deadline`.
- **`grocery_details`**: `item_id` (PK, FK), `product_name`, `batch_number`, `storage_location` (e.g. Fridge, Pantry, Freezer), `quantity_remaining` (REAL), `quantity_unit` (kg, L, pack, pcs).
- **`document_details`**: `item_id` (PK, FK), `document_number`, `issuing_authority`, `document_type`.

### 2.3 Supporting Tables
- **`item_documents`**: `id` (PK), `item_id` (FK NULLABLE), `file_name`, `relative_path`, `mime_type`, `file_size` (INT), `checksum_sha256`, `source`, `created_at`, `deleted_at`.
- **`reminder_rules`**: `id` (PK), `item_id` (FK), `offset_days` (INT), `reminder_time` (e.g. "09:00"), `is_enabled` (BOOLEAN), `created_at`.
- **`scheduled_reminders`**: `id` (PK), `item_id` (FK), `reminder_rule_id` (FK), `notification_id` (INT), `scheduled_at`, `status` (`pending`, `delivered`, `cancelled`), `created_at`.
- **`item_history`**: `id` (PK), `item_id` (FK), `event_type` (`created`, `edited`, `renewed`, `paid`, `consumed`, `discarded`, `archived`), `event_data_json`, `event_at`.
- **`app_settings`**: `id` (PK), `setting_key` (UNIQUE), `setting_value`, `updated_at`.
- **`backup_history`**: `id` (PK), `backup_id`, `backup_type`, `format_version`, `schema_version`, `created_at`, `file_size`, `checksum`, `destination_type`, `status`, `completed_at`.

