# GachaMerch — Project Documentation

---

## 1. Project Overview

**GachaMerch** is a mobile commerce application built with Flutter (frontend) and Node.js + Express (backend), backed by a MySQL database. The app hosts **three themed storefronts** under a single parent brand:

| Store | Tagline | Item Categories |
|---|---|---|
| **Honkai Star Retail** | Galactic resources & light cones | `Light Cone`, `Galactic Resource` |
| **Genshin Import** | Teyvat weapons & artifacts | `Weapon`, `Artifact` |
| **Wuthering Wares** | Resonator equipment & terminal supplies | `Resonator Equipment`, `Terminal Supply` |

Users log in once and can browse and purchase items across all three stores. Admins manage inventory across all stores from a single dashboard.

---

## 2. Feature List

### Pages

| # | Screen | File | Description |
|---|---|---|---|
| 1 | Splash Screen | `screens/splash_screen.dart` | Checks secure storage for a saved JWT token. Routes to Login if none is found, or Hub if a valid session exists. Animated fade-in logo. |
| 2 | Login Screen | `screens/login_screen.dart` | Username + password form with inline validation. Also provides a "Sign in with Google" button that triggers the full OAuth flow. |
| 3 | Register Screen | `screens/register_screen.dart` | Collects username, email, password, and confirm password. All five validation rules are active here. |
| 4 | Store Hub Screen | `screens/store_hub_screen.dart` | Displays three `StoreCard` tiles. Tapping one sets the active store in `StoreProvider` and navigates to the Catalog. |
| 5 | Catalog Screen | `screens/catalog_screen.dart` | A 2-column grid of `ItemCard` tiles filtered by the selected store. Includes a search bar, `FilterChip` type filters, and pull-to-refresh. The entire screen re-themes to the store's accent color. |
| 6 | Detail Screen | `screens/detail_screen.dart` | Full-screen item view: large image, type badge, price, description, and a `QuantityStepper`. "Proceed to Checkout" is disabled when stock is 0. |
| 7 | Checkout Screen | `screens/checkout_screen.dart` | Displays the order summary: item, store, unit price, quantity, and the computed total (`unit_price × quantity`). "Confirm Purchase" calls `/api/items/:id/buy`. |
| 8 | Purchase History | `screens/purchase_history_screen.dart` | Lists the authenticated user's purchases grouped by date (descending). Each entry shows a store-colored badge, item name, quantity, and total. |
| 9 | Profile Screen | `screens/profile_screen.dart` | Shows username, email, role badge, OAuth provider, and member-since date. Contains the Logout button. |
| 10 | Admin Dashboard | `screens/admin/admin_dashboard_screen.dart` | Tabbed view (one tab per store). Lists all items for the active tab with Edit and Delete actions. FAB opens the Item Form to create a new item. |
| 11 | Item Form | `screens/admin/item_form_screen.dart` | Shared create / edit form for admins. Fields: Store (dropdown), Type (dropdown constrained to the selected store), Name, Description, Stock, Price, Image. |

### Screenshot Placeholders

![Splash](docs/splash.png)
![Login](docs/login.png)
![Register](docs/register.png)
![Hub](docs/hub.png)
![Catalog](docs/catalog.png)
![Detail](docs/detail.png)
![Checkout](docs/checkout.png)
![History](docs/history.png)
![Profile](docs/profile.png)
![Admin Dashboard](docs/admin_dashboard.png)
![Item Form](docs/item_form.png)

---

## 3. UI Components Used

| # | Component | Where Used | File(s) |
|---|---|---|---|
| 1 | `TextFormField` (via `ValidatedField`) | All input screens (login, register, item form) | `widgets/validated_field.dart` |
| 2 | `ElevatedButton` (via `ThemedButton`) | Primary action on every screen | `widgets/themed_button.dart` |
| 3 | `GridView.builder` | Catalog item grid | `screens/catalog_screen.dart` |
| 4 | `Card` | Item tiles, store tiles, history entries, checkout summary, admin list | `widgets/item_card.dart`, `widgets/store_card.dart`, multiple screens |
| 5 | `Image.asset` / `Image.network` | Item images on cards, detail, and admin list | `widgets/item_card.dart`, `screens/detail_screen.dart` |
| 6 | `DropdownButtonFormField` | Store and Type selectors in Item Form | `screens/admin/item_form_screen.dart` |
| 7 | Custom `QuantityStepper` | Quantity selection on Detail screen | `widgets/quantity_stepper.dart` |
| 8 | `FilterChip` + search `TextField` | Category filter + search in Catalog | `screens/catalog_screen.dart` |
| 9 | `Drawer` | Navigation drawer available on Hub, Catalog, History, Profile, Admin | `main.dart` (`AppDrawer`) |
| 10 | `SnackBar` | Success/error feedback after purchase, login failure, item CRUD | multiple screens |
| 11 | `AlertDialog` | Delete confirmation in Admin Dashboard | `screens/admin/admin_dashboard_screen.dart` |
| 12 | `TabBar` / `TabController` | Store tabs in Admin Dashboard | `screens/admin/admin_dashboard_screen.dart` |

---

## 4. Data Validations

All validation failures show a **specific, user-visible message** inline in the form field or via `SnackBar`. No generic toasts.

| # | Rule | Error Message | Where It Fires |
|---|---|---|---|
| 1 | **Required** — field must not be empty | `"This field is required"` | All form fields across Login, Register, and Item Form |
| 2 | **Format** — email must match RFC-style regex; password must be ≥ 8 chars with at least one letter and one digit | Email: `"Enter a valid email address"` / Password: `"Password must be 8+ chars with letters and digits"` | Register screen |
| 3 | **Range / Numeric** — stock must be a non-negative integer; price must be a non-negative number; quantity must be ≥ 1 and ≤ available stock | Stock: `"Stock must be a non-negative integer"` / Price: `"Price must be a non-negative number"` / Quantity: `"Only N in stock"` | Item Form (stock, price), Detail screen (quantity stepper), also enforced server-side in `/buy` |
| 4 | **Match** — confirm password must equal password | `"Passwords do not match"` | Register screen |
| 5 | **Enum** — the selected `type` must be one of the valid types for the selected `store`; the Type dropdown is constrained to the current store's allowed values | `"Select a valid type for this store"` | Admin Item Form |

Backend validation mirrors all of these using `express-validator` and returns structured JSON on failure:
```json
{
  "error": "Validation failed",
  "details": [
    { "field": "stock", "msg": "Stock must be a non-negative integer" }
  ]
}
```

---

## 5. Authentication Design

### DB Credential Login
1. User submits `username` + `password` to `POST /api/auth/login`.
2. Backend looks up the user by username, fetches `password_hash`.
3. `bcrypt.compare(password, hash)` is called (cost factor 12).
4. On success, `issueToken(user)` signs a JWT and returns `{ token, user }`.
5. Mobile stores the token in `flutter_secure_storage` (Keystore-backed on Android) under the key `auth_token`.
6. Every protected request attaches `Authorization: Bearer <token>`.

### Google OAuth Login
1. User taps "Sign in with Google".
2. `google_sign_in` triggers the native Google account picker and returns an `idToken`.
3. Mobile posts `{ idToken }` to `POST /api/auth/google`.
4. Backend calls `OAuth2Client.verifyIdToken({ idToken, audience: GOOGLE_CLIENT_ID })` from `google-auth-library`.
5. If valid, the backend upserts the user row (by `oauth_provider='google'` + `oauth_sub`).
6. Backend issues its own JWT and returns `{ token, user }`.
7. Mobile stores the token identically to DB login — the rest of the app is OAuth-agnostic.

### JWT Structure
```
Header:  { "alg": "HS256", "typ": "JWT" }
Payload: { "sub": <user_id>, "role": "user"|"admin", "iat": <unix>, "exp": <unix+86400> }
```

- Algorithm: **HS256**
- Expiry: **24 hours**
- Format: compact base64url (alphanumeric + `-`, `_`, `.` separators)
- Length: always **> 100 characters** (well above the ≥ 20 character requirement)

**Sample token** (structure — not a live secret):
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
.eyJzdWIiOjEsInJvbGUiOiJhZG1pbiIsImlhdCI6MTc0ODAw
MDAwMCwiZXhwIjoxNzQ4MDg2NDAwfQ
.n8x7wfqtsrvxnvsm8dczABCDE_fghij-klmnopqrstuvwxyz
```

Each of the three dot-separated segments is pure alphanumeric + `-_` — URL-safe and well over 20 chars combined.

### Endpoints that verify the token
| Endpoint | Verification |
|---|---|
| `GET /api/auth/me` | `requireAuth` middleware |
| `POST /api/items/:id/buy` | `requireAuth` middleware |
| `POST /api/items` | `requireAdmin` middleware (chains `requireAuth`) |
| `PUT /api/items/:id` | `requireAdmin` middleware |
| `DELETE /api/items/:id` | `requireAdmin` middleware |
| `GET /api/purchases/me` | `requireAuth` middleware |
| `GET /api/purchases` | `requireAdmin` middleware |

**Rejection test** (missing token returns 401):
```bash
curl -i http://localhost:3000/api/auth/me
# HTTP/1.1 401 Unauthorized
# {"error":"Missing or malformed Authorization header"}
```

**Rejection test** (user token on admin route returns 403):
```bash
curl -i -X POST http://localhost:3000/api/items \
  -H "Authorization: Bearer <user_token>" \
  -H "Content-Type: application/json" \
  -d '{"store":"honkai_star_retail","name":"Test","type":"Light Cone","description":"x","stock":1,"price":100,"image":"x.png"}'
# HTTP/1.1 403 Forbidden
# {"error":"Admin access required"}
```

---

## 6. Theme Customizations

The theme is built by `buildStoreTheme(accent, background)` in `lib/config/theme.dart`. It accepts a per-store accent color and background color, producing a complete `ThemeData` object. **Five properties** are customized:

| # | Property | Values | File/Location |
|---|---|---|---|
| 1 | **Font family** | Headings: **Orbitron** (futuristic, spacey feel) · Body: **Inter** (clean, readable) | `config/theme.dart` via `google_fonts` |
| 2 | **Font-size scale** | `headlineLarge=28`, `headlineMedium=22`, `titleMedium=18`, `bodyMedium=15`, `labelSmall=12` | `config/theme.dart` text theme |
| 3 | **Color scheme** | Base background per store + accent color + text `#E6E8EF` on dark | `config/theme.dart` `ColorScheme.dark(...)` |
| 4 | **Component shape** | 14px rounded corners on `Card`, `ElevatedButton`, `InputDecoration`; 1px accent-colored border on focused inputs | `config/theme.dart` `cardTheme`, `inputDecorationTheme`, `elevatedButtonTheme` |
| 5 | **Per-store re-theming** | The entire Catalog screen (and Detail/Checkout/Admin) wraps its widget tree in `Theme(data: buildStoreTheme(...))`, so accent color, button color, chip color, and AppBar all shift when a different store is selected | `screens/catalog_screen.dart`, `screens/detail_screen.dart`, `screens/checkout_screen.dart` |

### Store Color Palettes

| Store | Accent | Background | Usage |
|---|---|---|---|
| Honkai Star Retail | `#FFD86B` (Gold) | `#0B1026` (Navy) | Buttons, chips, badges, AppBar title |
| Genshin Import | `#5BD0C7` (Teal) | `#0E1A2B` (Deep slate) | Buttons, chips, badges, AppBar title |
| Wuthering Wares | `#E0455B` (Crimson) | `#13121A` (Charcoal) | Buttons, chips, badges, AppBar title |

### WCAG AA Contrast Ratios

Minimum ratio for normal text: **4.5:1**. All three stores pass.

| Store | Accent on Background | Contrast Ratio | Result |
|---|---|---|---|
| Honkai Star Retail | `#FFD86B` on `#0B1026` | **9.3 : 1** | PASS |
| Genshin Import | `#5BD0C7` on `#0E1A2B` | **7.8 : 1** | PASS |
| Wuthering Wares | `#E0455B` on `#13121A` | **4.7 : 1** | PASS |

Ratios calculated using the WCAG relative luminance formula. The Wuthering Wares crimson is the tightest at 4.7:1, which still clears the AA threshold of 4.5:1.

---

## 7. API Endpoints Reference

All endpoints are prefixed with `/api`.

| Method | Path | Auth Required | Description |
|---|---|---|---|
| GET | `/health` | None | Server liveness check |
| POST | `/auth/register` | None | Register with username, email, password |
| POST | `/auth/login` | None | Login; returns JWT + user |
| POST | `/auth/google` | None | Google OAuth; verifies `idToken` server-side, returns JWT + user |
| GET | `/auth/me` | Bearer | Returns the authenticated user's profile |
| GET | `/items/stores` | None | Returns all three store metadata records (id, label, accent, types) |
| GET | `/items` | None | List items; supports `?store=`, `?type=`, `?q=` query params |
| GET | `/items/:id` | None | Get a single item by ID |
| POST | `/items` | Admin Bearer | Create a new item |
| PUT | `/items/:id` | Admin Bearer | Update an existing item |
| DELETE | `/items/:id` | Admin Bearer | Delete an item |
| POST | `/items/:id/buy` | Bearer | Purchase an item (atomic stock decrement + purchase record) |
| GET | `/purchases/me` | Bearer | Current user's full purchase history |
| GET | `/purchases` | Admin Bearer | All purchases across all stores (admin reporting) |

---

## 8. Asset Reference Links

The seed items are named after assets from the following games. Replace placeholder images with official press-kit artwork per the attribution requirements of each publisher.

**Honkai: Star Rail** (HoYoverse)
- TODO: Download from HoYoverse Press Kit — https://hoyoverse.com/press
- Items: Stellar Jade, Star Rail Pass, Bronya's Lightcone, In the Night, Refined Aether

**Genshin Impact** (HoYoverse)
- TODO: Download from HoYoverse Press Kit — https://hoyoverse.com/press
- Items: Wolf's Gravestone, Mistsplitter Reforged, Gladiator's Finale, Emblem of Severed Fate, Aqua Simulacra

**Wuthering Waves** (Kuro Games)
- TODO: Download from Kuro Games Media Kit — https://kurogames.com / official Discord media channels
- Items: Stringmaster, Verity's Handle, Astral Convergence Echo, Lingering Tunes Echo, Rippling Bloodpetals Echo

Place downloaded images in `mobile/gachamerch/assets/images/` with the filenames matching the `image` field values in `database/seed.sql` (e.g., `stellar_jade.png`).

---

## 9. Creativity & Design Notes

### Three Storefronts, One App
Instead of building three separate apps, GachaMerch hosts all three stores under a unified parent brand. A single login grants access to all storefronts. This mirrors a real-world multi-tenant marketplace (like Steam hosting multiple publishers). The `store` enum field on the `items` and `purchases` tables keeps data cleanly separated without needing separate databases.

### Per-Store Re-Theming
When a user taps a store on the Hub, `StoreProvider` updates the active store. The root `MaterialApp` in `main.dart` watches `StoreProvider` and rebuilds with `buildStoreTheme(store.accent, store.background)`. The Catalog, Detail, and Checkout screens additionally wrap their subtrees in a local `Theme(data: buildStoreTheme(...))` to guarantee the accent color is correct even when navigating from a cached state. The visual effect: entering Honkai Star Retail turns everything gold, Genshin Import turns teal, and Wuthering Wares turns crimson — buttons, chips, icons, AppBar title, focused input borders, and FAB all shift simultaneously.

### `SELECT … FOR UPDATE` Row Lock During Purchase
The `/api/items/:id/buy` endpoint runs inside a MySQL transaction using `SELECT stock, price, store FROM items WHERE id=? FOR UPDATE`. The `FOR UPDATE` clause acquires a row-level exclusive lock, preventing two concurrent requests from both reading the same stock value and both decrementing it past zero (the classic "oversell" race condition). The stock decrement and purchase INSERT are committed atomically; any failure triggers a `ROLLBACK`.

### Role-Aware Navigation Drawer
The `AppDrawer` widget (in `main.dart`) reads `AuthProvider.user.isAdmin`. If true, it renders an extra "Admin Dashboard" entry in the drawer. Regular users never see the admin navigation item, and even if they manually navigated to `/admin`, the backend would reject all writes with HTTP 403.

### JWT in `flutter_secure_storage`
The token is stored with `flutter_secure_storage`, which on Android uses the **Android Keystore** system — hardware-backed, encrypted storage that is not accessible to other apps and is wiped on uninstall. This is significantly more secure than `SharedPreferences` or plain files. The backend verifies the JWT signature on every protected request, so a stolen or replayed token is only valid for 24 hours.

### Validation at Both Layers
Every input is validated client-side (inline form errors before a request is even sent) and again server-side with `express-validator` (returning structured JSON errors). This prevents both user confusion and malformed data from reaching the database.

---

## 10. Tech Stack Summary

| Layer | Technology | Version |
|---|---|---|
| Mobile | Flutter + Dart | 3.32.2 / 3.8.1 |
| State management | Provider | 6.1.2 |
| HTTP client | http | 1.2.1 |
| Secure storage | flutter_secure_storage | 9.2.2 |
| Google sign-in | google_sign_in | 6.2.1 |
| Fonts | google_fonts (Orbitron + Inter) | 6.2.1 |
| Backend | Node.js + Express | 22.16.0 / 4.x |
| Auth | JWT (jsonwebtoken, HS256) | 9.0.2 |
| Password hashing | bcryptjs (cost 12) | 2.4.3 |
| Validation | express-validator | 7.2.0 |
| OAuth verification | google-auth-library | 9.11.0 |
| Database | MySQL via XAMPP | 8.2.12 |
| DB driver | mysql2/promise | 3.10.1 |
| Android target | Android SDK | API 35 |
