\# RoastMaster ID - Flutter Mobile Application

## Project Overview
A comprehensive e-commerce mobile application for coffee roasting equipment built with Flutter and GetX for state management.

## Architecture & Technologies
- **Framework**: Flutter
- **State Management**: GetX
- **Architecture Pattern**: MVVM (Model-View-Controller with GetX)
- **API**: Both http and Dio support with toggleable implementation
- **Data Persistence**: SharedPreferences for local data storage

## GetX Implementation

### Controllers
The application uses GetX controllers for state management instead of Provider:

- **AuthController**: Handles user authentication logic
- **CartController**: Manages shopping cart functionality
- **WishlistController**: Handles wishlist operations
- **OrderController**: Manages order data and operations
- **APIController**: Controls API implementation toggle and runtime measurement

### GetX Features Used
- **Get.put()**: For dependency injection in main.dart
- **Get.find()**: To access controllers throughout the application
- **GetMaterialApp**: For navigation and dependencies
- **Get.to()/Get.toNamed()**: For navigation
- **Obx()**: For reactive UI updates
- **Get.defaultDialog()**: For dialog management
- **Get.snackbar()**: For snackbar messages

### Navigation
- Routes are defined using GetPages in AppRoutes class
- GetX navigation is used throughout the application
- Eliminates the need for context when navigating

### State Management
- Controllers extend GetxController
- update() method is used to notify listeners instead of notifyListeners()
- Reactive programming with observables where needed
- Automatic memory management with GetX dependencies

## SharedPreferences Implementation

### Data Layer Structure
- **data/**: Contains all persistence-related code
  - **shared_preferences_helper.dart**: Core SharedPreferences operations with typed methods
  - **local_data_service.dart**: GetX service that manages SharedPreferences instance

### Persistence Features
The application uses SharedPreferences to persist the following data across app sessions:

#### User Authentication
- User login state (persisted across app restarts)
- User profile details (ID, name, email, phone, photo URL)
- Auto-login functionality using stored credentials

#### API Settings
- API implementation choice (Dio vs http)
- Fallback mode preference
- Runtime performance measurements

#### Onboarding State
- Onboarding completion status to prevent showing tutorials repeatedly

### Usage in Controllers
- **AuthController**: Loads user from storage on app start, saves on login, removes on logout
- **APIController**: Persists and restores API preferences between sessions
- Other controllers can access storage via `Get.find<LocalDataService>().prefsHelper`

### Method Examples
```dart
// Save user to storage
await Get.find<LocalDataService>().prefsHelper.saveUser(user);

// Load user from storage  
User? user = Get.find<LocalDataService>().prefsHelper.getUser();

// Update API settings
await Get.find<LocalDataService>().prefsHelper.setUseDio(true);

// Check if user is logged in
bool isLoggedIn = Get.find<LocalDataService>().prefsHelper.isUserLoggedIn();
```

## Perubahan yang Telah Dilakukan
- **Penambahan folder data**: Membuat struktur direktori baru untuk layer persistensi
- **Integrasi SharedPreferences**: Menambahkan dependency 'shared_preferences' dan mengimplementasikan helper
- **Perubahan struktur folder**: Mengganti struktur folder dari screens/models/providers ke views/controllers/data
- **Penambahan LocalDataService**: Layanan GetX untuk mengelola instance SharedPreferences
- **Implementasi pada AuthController**: Untuk menyimpan status login dan detail pengguna
- **Implementasi pada APIController**: Untuk menyimpan preferensi API (Dio vs http)
- **Pembaruan main.dart**: Menambahkan inisialisasi async untuk LocalDataService
- **Perbaikan keamanan kode**: Menambahkan penanganan kesalahan untuk menghindari LateInitializationError
- **Dokumentasi**: Memperbarui README.md dan rancangan.md untuk mencerminkan struktur dan fungsionalitas baru

## Fitur
- Otentikasi pengguna (Login/Register)
- Pencarian dan penjelajahan produk
- Fungsionalitas keranjang belanja
- Manajemen wishlist
- Manajemen pesanan
- Proses checkout dengan berbagai opsi pembayaran
- Toggle API (Dio vs http)
- Preferensi pengguna persisten dan pengaturan

## File Structure
```
lib/
├── config/           # App configuration (theme, routes)
├── controllers/      # GetX Controllers
├── data/             # Data persistence layer (SharedPreferences)
├── models/           # Data models (Product, Order, User, CartItem)
├── services/         # API services
├── views/            # UI screens (formerly screens/)
├── widgets/          # Reusable UI components
└── main.dart         # App entry point with GetX service initialization
```

## Key Components
- Splash Screen with animation
- Custom app bar
- Bottom navigation bar with badge support
- Product cards with image caching
- Category filtering
- Hero banner carousel
- Custom theme with coffee brand colors

## API Integration
- Toggleable between Dio and http packages
- Performance measurement for API calls
- Fallback data support for offline mode

## UI/UX Features
- Responsive grid layout
- Pull-to-refresh functionality
- Interactive product cards
- Smooth animations and transitions
- Clean, coffee-themed UI design