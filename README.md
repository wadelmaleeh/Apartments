# 🏢 نظام إدارة إيجار الشقق | Apartment Rental Management System

A modern, offline-first Flutter application for managing apartment rentals, income, and expenses with automatic synchronization and multi-device support.

## ✨ Features

### 📱 Core Functionality
- **Apartment Management** - Add, edit, and delete apartment listings
- **Income Tracking** - Record rental payments (daily/monthly)
- **Expense Management** - Track maintenance, utilities, and other costs
- **Dashboard Analytics** - Visual insights with charts and statistics
- **Monthly PDF Reports** - Generate and share professional Arabic reports

### 🔄 Offline-First Architecture
- **Full Offline Support** - Works completely without internet connection
- **Smart Sync Queue** - Automatic synchronization when online
- **Conflict Resolution** - Intelligent merging of local and remote changes
- **Auto-Sync** - Fetches latest data every 5 minutes
- **Visual Sync Status** - Real-time sync indicators with animations

### 🌐 Multi-Device Ready
- **Fresh Data on Login** - Always pulls latest from server
- **Clean Logout** - Clears local data and pending operations
- **Session Isolation** - Each device maintains independent offline state
- **Server as Source of Truth** - Periodic synchronization keeps devices in sync

### 🇸🇩 Arabic-First Design
- **Full RTL Support** - Proper right-to-left layout throughout
- **Cairo Font** - Beautiful Arabic typography
- **Sudanese Pound (جنيه)** - Local currency with thousand separators
- **Arabic PDF Reports** - Professional reports with proper RTL formatting

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.11.5 or higher)
- Dart SDK
- Android Studio / VS Code
- Node.js (for backend server)

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd Apartments
```

2. **Install Flutter dependencies**
```bash
cd apartment_rental
flutter pub get
```

3. **Start the backend server**
```bash
# Option 1: Start Node.js backend (from apartment_rental/server)
cd apartment_rental/server
npm install
node index.js

# Option 2: Use batch file (Windows)
cd apartment_rental
start_server.bat
```

4. **Run the Flutter app**
```bash
cd apartment_rental
flutter run

# Or use the batch file (Windows)
run.bat
```

## 🏗️ Project Structure

```
Apartments/
├── apartment_rental/          # Flutter application
│   ├── lib/
│   │   ├── main.dart                 # App entry point
│   │   ├── localization/             # Arabic/English translations
│   │   ├── models/                   # Data models (Apartment, Rental, Expense)
│   │   ├── providers/                # State management (Provider pattern)
│   │   ├── repositories/             # Data layer abstraction
│   │   ├── screens/                  # UI screens
│   │   │   ├── dashboard/           # Analytics dashboard
│   │   │   ├── apartments/          # Apartment management
│   │   │   ├── income/              # Income tracking
│   │   │   ├── expenses/            # Expense management
│   │   │   └── login/               # Authentication
│   │   ├── services/                 # Business logic
│   │   │   ├── api_service.dart     # REST API client
│   │   │   ├── local_database.dart  # Local storage (SharedPreferences)
│   │   │   ├── sync_service.dart    # Synchronization engine
│   │   │   ├── sync_queue.dart      # Pending operations queue
│   │   │   ├── connectivity_service.dart # Network detection
│   │   │   └── pdf_report_service.dart   # PDF generation
│   │   ├── widgets/                  # Reusable UI components
│   │   └── utils/                    # Constants and helpers
│   ├── assets/
│   │   └── fonts/
│   │       └── NotoSansArabic.ttf   # Arabic font
│   ├── server/                       # Node.js backend (Express + SQLite)
│   └── pubspec.yaml                 # Flutter dependencies
└── backend/                   # Alternative Next.js backend (optional)
```

## 📦 Key Dependencies

### Flutter Packages
```yaml
dependencies:
  provider: ^6.1.2              # State management
  http: ^1.2.2                  # API calls
  shared_preferences: ^2.3.4    # Local storage
  connectivity_plus: ^6.1.0     # Network detection
  uuid: ^4.5.1                  # Unique IDs
  intl: ^0.20.2                 # Internationalization
  fl_chart: ^0.70.2             # Charts
  google_fonts: ^6.2.1          # Cairo font
  pdf: ^3.11.2                  # PDF generation
  printing: ^5.13.4             # PDF preview/share
  share_plus: ^10.1.4           # Share functionality
```

## 🔧 Configuration

### Backend API
Update the API endpoint in `apartment_rental/lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:3000';
```

### Database Schema
The backend uses SQLite with three main tables:
- **apartments** - Apartment listings (id, name, description, created_at, updated_at)
- **rentals** - Income records (id, apartment_id, rental_type, amount, days, date, created_at)
- **expenses** - Expense records (id, apartment_id, expense_type, amount, date, created_at)

## 💾 Data Flow

### Offline-First Flow
```
User Action → Local DB → Sync Queue → (When Online) → Server API
     ↓
  Update UI
```

### Sync Flow
```
1. User goes online
2. Sync service detects connectivity
3. Process sync queue (CREATE → UPDATE → DELETE)
4. Fetch latest data from server
5. Update local database
6. Refresh UI
```

### Auto-Sync
```
Every 5 minutes (when online):
  - Fetch latest apartments
  - Fetch latest rentals
  - Fetch latest expenses
  - Update local database
  - Notify UI
```

## 📊 Features Deep Dive

### Income Management
- **Rental Types**: Monthly (شهري) or Daily (يومي)
- **Days Calculation**: Automatic for daily rentals
- **Per-Apartment Tracking**: Link income to specific apartments

### Expense Management
- **Categories**: Maintenance (صيانة), Electricity (كهرباء), Water (مياه), Internet (إنترنت), Cleaning (تنظيف), Repair (إصلاح), Insurance (تأمين), Tax (ضريبة), Other (أخرى)
- **Arabic Translation**: All expense types shown in Arabic
- **Date Tracking**: Record when expenses occurred

### PDF Reports
- **Monthly Reports**: Generate for any month
- **RTL Layout**: Proper Arabic right-to-left formatting
- **Sections**: Header, Summary Cards, Income Table, Expenses Table
- **Smart Formatting**: 
  - Days column shows "-" for monthly rentals
  - Currency: "1,000,000 جنيه" format
  - Arabic expense type translations
- **Share & Print**: Direct sharing or printing from preview

### Sync Status Indicators
- 🟠 **Pending** - Operations waiting to sync (shows count)
- 🔵 **Syncing** - Currently syncing (rotating animation)
- 🟢 **Synced** - All data synchronized (scale animation)
- 🔴 **Error** - Sync failed (shake animation)
- ⚪ **Offline** - No internet connection

## 🔐 Authentication

### Login Flow
1. Enter credentials (username: admin, password: admin)
2. Authenticate with server
3. Clear old local data
4. Fetch fresh data from server
5. Navigate to dashboard

### Logout Flow
1. Confirm logout
2. Clear authentication state
3. Clear local database
4. Clear sync queue
5. Return to login screen

## 🎨 UI/UX Design

### Color Scheme
- **Primary**: Blue tones (#0A2647, #2C74B3)
- **Success**: Green (#10B981)
- **Danger**: Red (#EF4444)
- **Warning**: Orange (#F59E0B)
- **Background**: Light blue (#F0F7FF)

### Typography
- **Font Family**: Cairo (Google Fonts)
- **RTL Support**: Full right-to-left layout
- **Responsive**: Adapts to different screen sizes

## 🧪 Testing

Run tests:
```bash
cd apartment_rental
flutter test
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🐛 Troubleshooting

### Common Issues

**Problem**: Sync not working
- **Solution**: Check connectivity indicator, ensure backend server is running on port 3000

**Problem**: PDF not generating
- **Solution**: Ensure Arabic font is included in `apartment_rental/assets/fonts/`

**Problem**: Data not persisting
- **Solution**: Clear app data and login again to fetch fresh data

**Problem**: Backend connection refused
- **Solution**: Update API URL in `api_service.dart` to match server address (e.g., `http://192.168.1.x:3000` for local network)

**Problem**: "dart" command not found
- **Solution**: Add Flutter bin directory to PATH environment variable

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Development

### Backend Server (Node.js + Express)
```bash
cd apartment_rental/server
npm install
node index.js
```

Server runs on `http://localhost:3000` by default.

**Endpoints:**
- `POST /api/login` - Authentication
- `GET /api/apartments` - List all apartments
- `POST /api/apartments` - Create apartment
- `PUT /api/apartments/:id` - Update apartment
- `DELETE /api/apartments/:id` - Delete apartment
- `GET /api/rentals` - List all rentals
- `POST /api/rentals` - Create rental
- `PUT /api/rentals/:id` - Update rental
- `DELETE /api/rentals/:id` - Delete rental
- `GET /api/expenses` - List all expenses
- `POST /api/expenses` - Create expense
- `PUT /api/expenses/:id` - Update expense
- `DELETE /api/expenses/:id` - Delete expense

### Hot Reload
Flutter supports hot reload for rapid development:
- Press `r` in terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Debug Mode
```bash
flutter run --debug
```

### Release Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release
```

## 🔮 Future Enhancements

- [ ] Advanced filtering and search
- [ ] Custom date range reports
- [ ] Email integration for reports
- [ ] Tenant management system
- [ ] Payment reminders/notifications
- [ ] Multi-currency support
- [ ] Cloud backup integration
- [ ] Role-based access control
- [ ] Biometric authentication
- [ ] Dark mode support
- [ ] Export to Excel
- [ ] Recurring expenses tracking

## 📞 Support

For issues or questions, please open an issue on GitHub.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Cairo font by Google Fonts
- All open-source contributors

---

**Built with ❤️ using Flutter**
