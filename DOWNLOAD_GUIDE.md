# 📥 How to Download Releases from GitHub

## Method 1: GitHub Releases Page (Best for Users) ⭐

### Creating a Release (For Repository Owner)

1. **Go to your repository:**
   - Visit: https://github.com/wadelmaleeh/Apartments

2. **Navigate to Releases:**
   - Click on "Releases" in the right sidebar
   - Or go to: https://github.com/wadelmaleeh/Apartments/releases

3. **Create a new release:**
   - Click "Create a new release" or "Draft a new release"
   
4. **Fill in the details:**
   ```
   Tag version: v1.1.0
   Release title: Version 1.1.0 - Vercel Production Release
   
   Description:
   ## 🚀 What's New
   - ✨ Connected to production Vercel deployment
   - 🌐 No need to run local backend server
   - 🔄 Automatic cloud sync
   - 📱 Production-ready build
   
   ## 📱 Downloads
   - **Android APK:** For Android 6.0+
   - **Windows Desktop:** For Windows 10/11 (64-bit)
   
   ## 🔐 Default Login
   - Username: admin
   - Password: admin
   
   ## 🌐 Backend
   Production server running at: https://apartments-sd.vercel.app
   ```

5. **Attach files:**
   - Click "Attach binaries by dropping them here or selecting them"
   - Upload: `releases/apartment-rental-v1.1.0.apk`
   - Upload: `releases/apartment-rental-windows-v1.1.0.zip`

6. **Publish:**
   - Click "Publish release"

### Downloading (For Users)

Once published, users can:

1. Go to: https://github.com/wadelmaleeh/Apartments/releases
2. Click on the latest release (v1.1.0)
3. Under "Assets", click to download:
   - `apartment-rental-v1.1.0.apk` (Android)
   - `apartment-rental-windows-v1.1.0.zip` (Windows)

**Direct Link Format:**
```
https://github.com/wadelmaleeh/Apartments/releases/download/v1.1.0/apartment-rental-v1.1.0.apk
https://github.com/wadelmaleeh/Apartments/releases/download/v1.1.0/apartment-rental-windows-v1.1.0.zip
```

---

## Method 2: Direct Download from Repository (Alternative)

### Current Method (Works Now)

Users can download directly from the `releases/` folder:

1. **Go to the releases folder:**
   - https://github.com/wadelmaleeh/Apartments/tree/master/releases

2. **Download APK:**
   - Click on `apartment-rental-v1.1.0.apk`
   - Click the "Download" button (top right)
   - Or use raw URL:
     ```
     https://github.com/wadelmaleeh/Apartments/raw/master/releases/apartment-rental-v1.1.0.apk
     ```

3. **Download Windows ZIP:**
   - Click on `apartment-rental-windows-v1.1.0.zip`
   - Click the "Download" button
   - Or use raw URL:
     ```
     https://github.com/wadelmaleeh/Apartments/raw/master/releases/apartment-rental-windows-v1.1.0.zip
     ```

### Direct Download Links (Copy & Share)

**Android APK:**
```
https://github.com/wadelmaleeh/Apartments/raw/master/releases/apartment-rental-v1.1.0.apk
```

**Windows Desktop:**
```
https://github.com/wadelmaleeh/Apartments/raw/master/releases/apartment-rental-windows-v1.1.0.zip
```

---

## Method 3: Using Git Clone

For developers who want everything:

```bash
# Clone the repository
git clone https://github.com/wadelmaleeh/Apartments.git

# Navigate to releases folder
cd Apartments/releases

# Files are now available locally
ls
```

---

## Method 4: Using wget or curl (Command Line)

### Android APK:
```bash
wget https://github.com/wadelmaleeh/Apartments/raw/master/releases/apartment-rental-v1.1.0.apk

# Or with curl
curl -L -O https://github.com/wadelmaleeh/Apartments/raw/master/releases/apartment-rental-v1.1.0.apk
```

### Windows ZIP:
```bash
wget https://github.com/wadelmaleeh/Apartments/raw/master/releases/apartment-rental-windows-v1.1.0.zip

# Or with curl
curl -L -O https://github.com/wadelmaleeh/Apartments/raw/master/releases/apartment-rental-windows-v1.1.0.zip
```

---

## 📱 QR Codes for Easy Mobile Download

You can generate QR codes for these URLs:

**Android APK QR Code:**
- URL: `https://github.com/wadelmaleeh/Apartments/raw/master/releases/apartment-rental-v1.1.0.apk`
- Use a QR code generator like: https://www.qr-code-generator.com/

Users can scan with their phone and download directly!

---

## 🎯 Recommended Approach

**For Professional Distribution:**
1. ✅ Create a GitHub Release (Method 1)
2. ✅ Use semantic versioning (v1.1.0, v1.2.0, etc.)
3. ✅ Write clear release notes
4. ✅ Attach compiled binaries to the release

**For Quick Sharing:**
1. Share direct download links (Method 2)
2. Create QR codes for mobile downloads
3. Update your README with download badges

---

## 📝 Adding Download Badges to README

Add these badges to your README.md:

```markdown
[![Download APK](https://img.shields.io/badge/Download-APK%20v1.1.0-green?style=for-the-badge&logo=android)](https://github.com/wadelmaleeh/Apartments/raw/master/releases/apartment-rental-v1.1.0.apk)

[![Download Windows](https://img.shields.io/badge/Download-Windows%20v1.1.0-blue?style=for-the-badge&logo=windows)](https://github.com/wadelmaleeh/Apartments/raw/master/releases/apartment-rental-windows-v1.1.0.zip)
```

Result:
- Big, colorful download buttons in your README
- Users can download with one click

---

## ⚠️ Important Notes

1. **Large File Warning:**
   - GitHub warns about files over 50MB
   - Your APK is ~58MB
   - Consider using Git LFS or external hosting for very large files

2. **File Size Limits:**
   - GitHub allows files up to 100MB in repository
   - GitHub Releases allows files up to 2GB
   - **Releases page is better for large binaries**

3. **Download Speed:**
   - Direct downloads from repository might be slower
   - GitHub Releases are optimized for downloads
   - Consider using CDN for production apps

4. **Alternative Hosting:**
   - For faster downloads, consider:
     - Google Drive + direct link
     - Dropbox + direct link
     - AWS S3 + CloudFront
     - Firebase App Distribution
     - Microsoft App Center

---

## 🔗 Quick Reference Links

**Your Repository:**
https://github.com/wadelmaleeh/Apartments

**Releases Folder:**
https://github.com/wadelmaleeh/Apartments/tree/master/releases

**Create GitHub Release:**
https://github.com/wadelmaleeh/Apartments/releases/new

**Android Direct Download:**
https://github.com/wadelmaleeh/Apartments/raw/master/releases/apartment-rental-v1.1.0.apk

**Windows Direct Download:**
https://github.com/wadelmaleeh/Apartments/raw/master/releases/apartment-rental-windows-v1.1.0.zip

---

**Need help?** Open an issue on GitHub!
