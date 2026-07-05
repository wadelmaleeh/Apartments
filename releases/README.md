# 📦 Releases

## Latest Release - v1.0.0

### Android APK
**File:** `apartment-rental-v1.0.0.apk`  
**Size:** 57.92 MB  
**Min SDK:** Android 6.0 (API 24) or higher

### Download & Install

1. **Download the APK:**
   - Click on `apartment-rental-v1.0.0.apk` above
   - Click the "Download" button

2. **Enable Unknown Sources:**
   - Go to Settings > Security
   - Enable "Install from Unknown Sources" or "Allow from this source"

3. **Install:**
   - Open the downloaded APK file
   - Tap "Install"
   - Wait for installation to complete

### Features in v1.0.0

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

### System Requirements

- **OS:** Android 6.0 or higher
- **Storage:** ~100 MB free space
- **Internet:** Optional (works offline, syncs when online)

### Backend Setup

The app requires a backend server. You can either:

1. **Use your own server:**
   - Clone this repository
   - Navigate to `backend/` folder
   - Copy `.env.example` to `.env` and add your Neon database URL
   - Run `npm install`
   - Run `npm run dev`
   - Update the API URL in the app settings

2. **Use our demo server:**
   - The app comes pre-configured with a demo server
   - Login with: `admin / admin`

### Default Credentials

**Username:** admin  
**Password:** admin

### Troubleshooting

**Problem:** App won't install  
**Solution:** Make sure "Install from Unknown Sources" is enabled

**Problem:** Can't connect to server  
**Solution:** Check your internet connection and ensure the backend server is running

**Problem:** Sync not working  
**Solution:** Check the sync icon in the app bar - it shows the connection status

### Support

For issues or questions, please open an issue on GitHub.

---

**Built with Flutter** ❤️
