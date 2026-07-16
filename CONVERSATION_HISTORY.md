# Yarpay POS - Conversation History

## Project Overview
- **Project**: Yarpay Restaurant POS
- **Location**: `C:\Users\raiya\resto_bill`
- **Supabase**: `qhboqxkljipnicwwvqdm.supabase.co`
- **Stack**: Flutter + Supabase + fl_chart + pdf/printing

---

## Architecture Decisions

### Supabase Quirk
`auth.uid()` returns NULL in RLS context on web. All DB operations must use `security definer` RPC functions, NOT direct table queries with RLS policies.

### Auth Config
- Email confirmation toggled OFF in Supabase Dashboard (was ON by default)
- "Allow new users to sign up" also had to be enabled separately
- Old test users created before config changes remain broken (unconfirmed email) — must delete and use fresh emails

### Role System
- Owner: full access
- Manager: menu + orders + analytics
- Cashier: POS only

---

## Key Technical Fixes

### 1. PDF Receipt Symbol Compatibility
Default Helvetica font doesn't support `₹` or `•`. Use `Rs.` and `-` instead.

### 2. Web File Sharing
`share_plus` file-based sharing doesn't work on web. Use `Printing.sharePdf(bytes:)` for web-compatible sharing.

### 3. PostgreSQL Function Signatures
Params with defaults must come after all required params in function signatures.

### 4. Missing `get_my_restaurant_id()` Function
Was never created — only `get_user_restaurant_id()` existed in 001. This caused ALL analytics RPCs in 002 and 003 to silently fail. Fixed by adding the alias function to `001_initial_schema.sql`.

### 5. `Future.wait` in Analytics Provider
Caused all RPCs to fail if any single one threw (e.g., missing functions in 003). Fixed by making each RPC call independent via `_safeRpc`/`_safeRpcList` with 10s timeout.

### 6. UTC Timestamps from Supabase
Need `.toLocal()` in Dart to display correct local time. Fixed in `Order.fromJson` and `Customer.fromJson`.

### 7. Analytics Invalidation
`ref.invalidate(analyticsProvider)` added to `addOrder` and `voidOrder` in `order_provider.dart` so analytics refresh after orders.

### 8. `copyWith` on AnalyticsState
Added method to support loading state transitions without circular dependency.

---

## Bug Fixes (Latest Session)

### Crash 1: Circular Dependency in AnalyticsProvider
**Problem**: `state = state.copyWith(isLoading: true)` called in `_loadAll()` before the notifier was fully initialized, causing "Bad state: Tried to read the state of an uninitialized provider".
**Fix**: Removed the redundant `state.copyWith(isLoading: true)` line from `_loadAll()` in `analytics_provider.dart:271`. The `build()` method already returns `AnalyticsState(isLoading: true)`.

### Crash 2: `Expanded` Inside `ListView` (Layout Overflow)
**Problem**: `_DailyRevenueChart`, `_HourlyHeatmap`, `_DayOfWeekChart`, `_MonthlyComparisonChart` all used `Expanded` inside a `Column` that was a child of `ListView`. `ListView` provides unbounded height, so `Expanded` crashes with "Unexpected null value".
**Fix**: Replaced all 4 `Expanded` widgets with `SizedBox(height: 200)` in `analytics_screen.dart`. Note: `Expanded` inside `Row` widgets (e.g., `_CategoryPieChart`, `_PaymentPieChart`) is fine and left unchanged.

---

## Completed Phases

### Phase 1-11: Core POS
- Supabase integration, auth, restaurant setup
- Cloud products/categories, cart, checkout, orders
- Search/filtering, responsive design, menu management UI

### RPC Functions (12 original)
`get_my_profile`, `get_my_restaurant_id`, `get_user_restaurant_id`, `get_categories`, `get_products`, `add_category`, `delete_category`, `add_product`, `update_product`, `delete_product`, `create_order`, `get_orders`, `delete_order`

### PDF Receipts & Sharing
- `receipt_service.dart` (80mm thermal-width PDF)
- Print via `Printing.layoutPdf`
- Share via `Printing.sharePdf`

### 3-Button Checkout
Cancel, Place Order, Print & Place

### Tax Rate
Settings → Billing → slider + tap `%` badge to type exact rate

### Discount Support
`CartState` with `DiscountType`, discount row in checkout, cart summary, receipt, order details dialog

### Customer Management
`Customer` model, `customer_provider.dart`, `customers_screen.dart` (CRUD)

### Analytics Dashboard
5-tab Zomato/Swiggy-level dashboard (Overview, Sales, Menu, Customers, Payments) with:
- Bar charts, pie charts, hourly heatmap, day-of-week charts
- Monthly comparison, PDF report export via `fl_chart`

### Analytics SQL RPCs (003 migration)
9 new functions: `get_daily_sales`, `get_hourly_heatmap`, `get_day_of_week_sales`, `get_category_sales`, `get_product_sales`, `get_payment_analytics`, `get_customer_analytics`, `get_monthly_comparison`, `get_discount_analytics`

### Void Orders
`void_order` RPC, void button, voided badge (red styling + strikethrough price)

### Search in POS
`SearchSection` + `searchProvider` + `filteredProductsProvider`

### Multiple Payment Split
Checkout toggle for split mode

### Receipt Customization
Settings → Receipt card (footer text, show/hide address/phone, persisted via SharedPreferences)

### Offline Support
Products/categories cached to SharedPreferences, orange banner

### Login UX
Enter key triggers login, error messages use `SelectableText`

---

## Active / Blocked

### Needs User Action
1. Run `get_my_restaurant_id()` function creation SQL in Supabase SQL Editor
2. Run `supabase/migrations/003_analytics_rpc.sql` in Supabase SQL Editor

### Blocked
Analytics SQL functions not yet applied — all 9 new RPCs return 404 until user runs the 003 migration.

---

## Next Steps
1. User runs `get_my_restaurant_id()` function creation SQL + full `003_analytics_rpc.sql` in Supabase SQL Editor
2. Verify analytics dashboard loads with real data (no more 404s)
3. Test full checkout → analytics flow end-to-end
4. Fix any remaining rendering errors

---

## Key Files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Dependencies (supabase_flutter, fl_chart, flutter_dotenv, pdf, printing, share_plus, path_provider, shared_preferences) |
| `.env` | Supabase URL + anon key (gitignored) |
| `lib/main.dart` | App entry point with dotenv + Supabase init |
| `lib/core/config/env.dart` | Typed env access |
| `lib/core/router/app_router.dart` | Auth-aware GoRouter with redirects |
| `lib/data/services/supabase_service.dart` | Supabase singleton |
| `lib/features/auth/application/auth_provider.dart` | AuthState + AuthNotifier |
| `lib/features/restaurant/application/restaurant_provider.dart` | RestaurantState (provides `restaurantIdProvider`) |
| `lib/features/pos/application/product_provider.dart` | ProductsState with offline caching |
| `lib/features/pos/application/cart_state.dart` | CartState with discount methods |
| `lib/features/pos/presentation/dialogs/checkout_dialog.dart` | Checkout with discount + split payment |
| `lib/features/orders/application/order_provider.dart` | Order CRUD (addOrder, voidOrder, invalidates analytics) |
| `lib/features/orders/domain/order.dart` | Order model (discount, discountType, status; `.toLocal()` in fromJson) |
| `lib/features/orders/data/receipt_service.dart` | PDF receipt generation |
| `lib/features/customers/domain/customer.dart` | Customer model (`.toLocal()` in fromJson) |
| `lib/features/customers/application/customer_provider.dart` | CustomerNotifier |
| `lib/features/analytics/application/analytics_provider.dart` | AnalyticsState with independent RPC loading, `_safeRpc`/`_safeRpcList` with 10s timeout |
| `lib/features/analytics/presentation/screens/analytics_screen.dart` | 5-tab analytics dashboard with `fl_chart` |
| `lib/features/analytics/presentation/widgets/analytics_pdf_report.dart` | PDF report generation |
| `supabase/migrations/001_initial_schema.sql` | Original schema + `get_my_restaurant_id()` alias |
| `supabase/migrations/002_discount_customers_analytics.sql` | Customers table, discount/status columns, analytics RPC, void RPC |
| `supabase/migrations/003_analytics_rpc.sql` | 9 new analytics SQL RPCs |
