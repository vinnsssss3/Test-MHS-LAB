# GachaMerch

A Flutter + Node.js + MySQL app that hosts three themed storefronts — **Honkai Star Retail**, **Genshin Import**, and **Wuthering Wares** — under one parent company. Users log in once and shop across all three stores. Admins manage inventory from a single dashboard.

---

## Prerequisites

Install **exactly** these versions before proceeding:

| Tool | Version | Download |
|---|---|---|
| Flutter SDK | **3.32.2** | https://docs.flutter.dev/release/archive |
| Dart | **3.8.1** (bundled with Flutter) | — |
| Node.js | **22.16.0** | https://nodejs.org |
| XAMPP | **8.2.12** (MySQL/MariaDB) | https://www.apachefriends.org |
| Android Studio | Meerkat 2024.3.2 P1 | https://developer.android.com/studio |
| Android SDK | **API 35** | via Android Studio SDK Manager |

Verify your Flutter install:
```bash
flutter --version
# Flutter 3.32.2 • Dart 3.8.1
```

---

## 1. Database Setup

### Start XAMPP MySQL
Open the XAMPP Control Panel and click **Start** next to **MySQL**.

### Create the schema
```bash
mysql -u root < database/schema.sql
```

### Generate bcrypt-hashed seed data
The seed script hashes the two default passwords and writes `database/seed.sql`:
```bash
cd backend
npm install
node scripts/hash-seed-passwords.js
cd ..
```
You should see output like:
```
Admin hash : $2a$12$...
User hash  : $2a$12$...
✓ seed.sql written to: .../database/seed.sql
```

### Load the seed
```bash
mysql -u root gachamerch < database/seed.sql
```

### Verify
```bash
mysql -u root gachamerch -e "SELECT id, username, role FROM users;"
```
Expected output:
```
+----+-------------+-------+
| id | username    | role  |
+----+-------------+-------+
|  1 | admin       | admin |
|  2 | trailblazer | user  |
+----+-------------+-------+
```

---

## 2. Backend Setup

```bash
cd backend
npm install
cp .env.example .env
```

Edit `.env` and fill in your values:
```
PORT=3000
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=        # leave blank if XAMPP has no root password
DB_NAME=gachamerch
JWT_SECRET=some-long-random-string-at-least-32-chars
GOOGLE_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

Start the server:
```bash
node server.js
```

Confirm it is running:
```bash
curl http://localhost:3000/api/health
# {"status":"ok","timestamp":"..."}
```

---

## 3. Google OAuth Setup (optional for DB login, required for Google button)

1. Go to [Google Cloud Console](https://console.cloud.google.com) → **APIs & Services** → **Credentials**.
2. Click **Create Credentials** → **OAuth 2.0 Client ID**.
3. Create a **Web application** client (used by the backend to verify `idToken`).
   - Copy the **Client ID** into `.env` → `GOOGLE_CLIENT_ID`.
   - Copy the same **Client ID** into `mobile/gachamerch/lib/config/api.dart` → `googleClientId`.
4. Create an **Android** client (used by `google_sign_in` on the device):
   - Package name: `com.gachamerch.gachamerch`
   - SHA-1 fingerprint: run `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android` and copy the SHA-1.
5. Download `google-services.json` from the Android client and place it at:
   ```
   mobile/gachamerch/android/app/google-services.json
   ```
6. Add the Google Services plugin to `android/app/build.gradle.kts`:
   ```kotlin
   plugins {
     ...
     id("com.google.gms.google-services")
   }
   ```
   And to `android/build.gradle.kts` (project level):
   ```kotlin
   plugins {
     ...
     id("com.google.gms.google-services") version "4.4.2" apply false
   }
   ```

> **Note:** If you skip Google OAuth setup, the "Sign in with Google" button will show an error but all username/password flows continue to work normally.

---

## 4. Mobile Setup

### Emulator (recommended)
```bash
cd mobile/gachamerch
flutter pub get
flutter run
```

The Android emulator reaches the host machine at `http://10.0.2.2:3000`, which is already set as the default in `lib/config/api.dart`.

### Physical device
Replace the base URL in `lib/config/api.dart`:
```dart
static const String baseUrl = 'http://YOUR_LAN_IP:3000/api';
```
Find your LAN IP with `ipconfig` (Windows) or `ifconfig` (Mac/Linux). Make sure the device is on the same Wi-Fi network as the backend.

### Target SDK
The app targets **Android API 35** (`minSdk = 23`). Use an emulator running **Android 15 (API 35)** for best results.

---

## 5. Default Credentials

| Role | Username | Password | Email |
|---|---|---|---|
| Admin | `admin` | `Admin#123` | admin@gachamerch.local |
| User | `trailblazer` | `User#1234` | tb@gachamerch.local |

---

## 6. API Endpoint Reference

All routes are prefixed with `/api`.

### Auth
| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/auth/register` | Public | Register a new user account |
| POST | `/auth/login` | Public | Login with username + password; returns JWT |
| POST | `/auth/google` | Public | Verify Google `idToken`; returns JWT |
| GET | `/auth/me` | Bearer | Return the authenticated user's profile |

### Items & Stores
| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/items/stores` | Public | List all three store metadata records |
| GET | `/items` | Public | List items; filter with `?store=`, `?type=`, `?q=` |
| GET | `/items/:id` | Public | Get a single item by ID |
| POST | `/items` | Admin | Create a new item |
| PUT | `/items/:id` | Admin | Update an existing item |
| DELETE | `/items/:id` | Admin | Delete an item |
| POST | `/items/:id/buy` | Bearer | Purchase an item (atomic stock decrement) |

### Purchases
| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/purchases/me` | Bearer | Current user's purchase history |
| GET | `/purchases` | Admin | All purchases across all stores |

### Health
| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/health` | Public | Server liveness check |

---

## 7. Project Structure

```
gachamerch/
├── README.md
├── DOCUMENTATION.md
├── database/
│   ├── schema.sql              # CREATE TABLE statements
│   └── seed.sql                # Generated by hash-seed-passwords.js
├── backend/
│   ├── package.json
│   ├── .env.example
│   ├── server.js               # Express entry point
│   ├── config/db.js            # MySQL connection pool
│   ├── middleware/auth.js      # requireAuth / requireAdmin
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── itemController.js
│   │   └── purchaseController.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── items.js
│   │   └── purchases.js
│   ├── utils/token.js          # JWT issue / verify
│   └── scripts/
│       └── hash-seed-passwords.js
└── mobile/
    └── gachamerch/
        ├── pubspec.yaml
        ├── lib/
        │   ├── main.dart
        │   ├── config/         # api.dart, stores.dart, theme.dart
        │   ├── models/         # user, item, store, purchase
        │   ├── services/       # auth, item, purchase, storage
        │   ├── providers/      # auth_provider, store_provider
        │   ├── screens/        # 11 screens (+ admin/ subdirectory)
        │   └── widgets/        # 5 reusable widgets
        └── assets/images/      # placeholder PNGs for all seed items
```

---

## 8. Troubleshooting

| Problem | Fix |
|---|---|
| `mysql` command not found | Add XAMPP's MySQL to PATH: `C:\xampp\mysql\bin` |
| `ECONNREFUSED` from backend | XAMPP MySQL is not running; start it from the Control Panel |
| Emulator can't reach backend | Make sure backend is running on port 3000; emulator uses `10.0.2.2` |
| Physical device can't reach backend | Replace `10.0.2.2` with your LAN IP in `api.dart` |
| Google sign-in fails | Verify `GOOGLE_CLIENT_ID` in `.env` matches the Web OAuth client |
| `flutter pub get` fails | Run `flutter upgrade` then retry |
