# 📦 Releases

## Latest Release - v2.0.0 🚀

### 🆕 What's New in v2.0.0
- ✨ **Always connected** to production Vercel deployment
- 🌐 Works with `flutter run` and production builds
- 🔄 No localhost required - everything on cloud
- 📱 Unified configuration for all environments
- ☁️ 100% cloud-based backend

### Android APK
**File:** `apartment-rental-v2.0.0.apk`  
**Size:** 57.9 MB  
**Min SDK:** Android 6.0 (API 24) or higher  
**Backend:** https://apartments-sd.vercel.app ☁️

### Windows Desktop
**File:** `apartment-rental-windows-v2.0.0.zip`  
**Size:** ~17 MB (compressed)  
**OS:** Windows 10/11 (64-bit)  
**Backend:** https://apartments-sd.vercel.app ☁️

---

## Download & Install

### 📱 Android

1. **Download the APK:**
   - Click on `apartment-rental-v2.0.0.apk` above
   - Click the "Download" button

2. **Enable Unknown Sources:**
   - Go to Settings > Security
   - Enable "Install from Unknown Sources" or "Allow from this source"

3. **Install:**
   - Open the downloaded APK file
   - Tap "Install"
   - Wait for installation to complete

### 💻 Windows

1. **Download the ZIP:**
   - Click on `apartment-rental-windows-v2.0.0.zip`
   - Extract the ZIP file to a folder

2. **Run:**
   - Open the extracted folder
   - Double-click `apartment_rental.exe`
   - Windows Defender may ask for confirmation - click "Run anyway"

---

## Features

✅ Apartment management (Add, Edit, Delete)  
✅ Income tracking (Daily/Monthly rentals)  
✅ Expense management with categories  
✅ Offline-first functionality  
✅ Auto-sync every 5 minutes  
✅ Monthly PDF reports (Arabic)  
✅ Dashboard with analytics & charts  
✅ Multi-device support  
✅ Cairo font for Arabic text  
✅ Sudanese Pound (جنيه) currency  
✅ **Cloud backend on Vercel** ☁️

---

## System Requirements

### Android
- **OS:** Android 6.0 or higher
- **Storage:** ~100 MB free space
- **Internet:** Required for sync (works offline, syncs when online)

### Windows
- **OS:** Windows 10/11 (64-bit)
- **Storage:** ~100 MB free space
- **Internet:** Required for sync

---

## Backend Information

🌐 **Production Server:** https://apartments-sd.vercel.app  
🔧 **Status:** Deployed and running on Vercel  
🗄️ **Database:** PostgreSQL (Neon)

### Default Credentials

**Username:** admin  
**Password:** admin

---

## Development Setup

For local development with `flutter run`:

**v2.0.0 uses Vercel by default!** No local backend needed.

If you want to use a local backend for testing:

1. **Update API config:**
   - Open `apartment_rental/lib/services/api_config.dart`
   - Uncomment `developmentUrl`
   - Change `baseUrl` to `developmentUrl`

2. **Start local backend:**
   ```bash
   cd backend
   npm install
   npm run dev
   ```

3. **Run Flutter app:**
   ```bash
   cd apartment_rental
   flutter run
   ```

**Current Configuration:**
- All builds use: `https://apartments-sd.vercel.app`
- No localhost setup required
- Works immediately after `flutter run`

---

## Troubleshooting

**Problem:** App won't install (Android)  
**Solution:** Make sure "Install from Unknown Sources" is enabled

**Problem:** Windows Defender blocks the app  
**Solution:** Click "More info" then "Run anyway" - the app is safe

**Problem:** Can't connect to server  
**Solution:** Check your internet connection. The app works offline and syncs when connected.

**Problem:** Sync not working  
**Solution:** Check the sync icon in the app bar - it shows connection status

---

## Previous Versions

### v1.1.0 (Conditional Vercel)
- Release builds used Vercel
- Debug builds used localhost
- Required local backend for development

### v1.0.0 (Localhost only)
- Initial release with local backend support
- Required local server at `http://localhost:3000`

---

## Support

For issues or questions, please open an issue on GitHub:  
https://github.com/wadelmaleeh/Apartments/issues

---

**Built with Flutter** ❤️ | **Deployed on Vercel** ☁️
