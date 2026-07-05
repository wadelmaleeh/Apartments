# 📦 Releases

## Latest Release - v1.1.0 🚀

### 🆕 What's New in v1.1.0
- ✨ Connected to production Vercel deployment
- 🌐 No need to run local backend server
- 🔄 Automatic cloud sync
- 📱 Production-ready build

### Android APK
**File:** `apartment-rental-v1.1.0.apk`  
**Size:** 57.9 MB  
**Min SDK:** Android 6.0 (API 24) or higher  
**Backend:** https://apartments-sd.vercel.app

### Windows Desktop
**File:** `apartment-rental-windows-v1.1.0.zip`  
**Size:** ~40 MB (uncompressed)  
**OS:** Windows 10/11 (64-bit)  
**Backend:** https://apartments-sd.vercel.app

---

## Download & Install

### 📱 Android

1. **Download the APK:**
   - Click on `apartment-rental-v1.1.0.apk` above
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
   - Click on `apartment-rental-windows-v1.1.0.zip`
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

1. **Configure for localhost:**
   - The app automatically uses `http://localhost:3000` in debug mode
   - No code changes needed!

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

The app intelligently switches between:
- **Debug/Development:** `http://localhost:3000`
- **Release builds:** `https://apartments-sd.vercel.app`

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

### v1.0.0 (Localhost)
- Initial release with local backend support
- **File:** `apartment-rental-v1.0.0.apk`
- **Backend:** Required local server at `http://localhost:3000`

---

## Support

For issues or questions, please open an issue on GitHub:  
https://github.com/wadelmaleeh/Apartments/issues

---

**Built with Flutter** ❤️ | **Deployed on Vercel** ☁️
