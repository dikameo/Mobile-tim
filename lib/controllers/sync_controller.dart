import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../services/sync_service.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../models/product.dart';

/// Controller untuk manage sinkronisasi dan network state
class SyncController extends GetxController {
  late final SyncService _syncService;
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Observable states
  final RxBool _isOnline = false.obs;
  final RxBool _isSyncing = false.obs;
  final Rx<DateTime?> _lastSyncTime = Rx<DateTime?>(null);
  final RxInt _localProductCount = 0.obs;
  final RxInt _unsyncedCount = 0.obs;
  final RxList<Product> _products = <Product>[].obs;
  final RxString _syncStatus = 'idle'.obs;

  // Getters
  bool get isOnline => _isOnline.value;
  bool get isSyncing => _isSyncing.value;
  DateTime? get lastSyncTime => _lastSyncTime.value;
  int get localProductCount => _localProductCount.value;
  int get unsyncedCount => _unsyncedCount.value;
  List<Product> get products => _products;
  String get syncStatus => _syncStatus.value;

  @override
  void onInit() {
    super.onInit();
    _initializeSyncService();
    _setupConnectivityListener();
    _checkInitialConnectivity();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  /// Initialize sync service
  void _initializeSyncService() {
    try {
      final hiveService = Get.find<HiveService>();
      final supabaseService = Get.find<SupabaseService>();

      _syncService = SyncService(
        hiveService: hiveService,
        supabaseService: supabaseService,
      );

      _updateSyncStats();
    } catch (e) {
      print('Error initializing sync service: $e');
    }
  }

  /// Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final wasOffline = !_isOnline.value;
      _isOnline.value =
          results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);

      if (_isOnline.value && wasOffline) {
        // Just came back online
        _handleReconnection();
      }
    });
  }

  /// Check initial connectivity
  Future<void> _checkInitialConnectivity() async {
    _isOnline.value = await _syncService.isOnline();

    // Perform initial sync if online
    if (_isOnline.value) {
      await performSync();
    }
  }

  /// Handle reconnection
  Future<void> _handleReconnection() async {
    print('Device reconnected - syncing...');
    _syncStatus.value = 'reconnecting';

    // Push any pending local changes
    await _syncService.pushLocalChanges();

    // Pull updates from server
    await performSync();

    _syncStatus.value = 'synced';
  }

  /// Perform sync
  Future<bool> performSync({bool forceRefresh = false}) async {
    if (_isSyncing.value) {
      print('Sync already in progress');
      return false;
    }

    try {
      _isSyncing.value = true;
      _syncStatus.value = 'syncing';

      bool success;
      if (forceRefresh) {
        success = await _syncService.fullSync();
      } else {
        success = await _syncService.incrementalSync();
      }

      if (success) {
        _lastSyncTime.value = DateTime.now();
        _syncStatus.value = 'synced';
        await loadProducts();
      } else {
        _syncStatus.value = 'failed';
      }

      _updateSyncStats();
      return success;
    } catch (e) {
      print('Error performing sync: $e');
      _syncStatus.value = 'error';
      return false;
    } finally {
      _isSyncing.value = false;
    }
  }

  /// Load products (offline-first)
  Future<void> loadProducts({String? category}) async {
    try {
      List<Product> loadedProducts;

      if (category != null && category != 'All') {
        loadedProducts = await _syncService.getProductsByCategory(category);
      } else {
        loadedProducts = await _syncService.getProducts();
      }

      _products.value = loadedProducts;
      _updateSyncStats();
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  /// Force full sync
  Future<bool> forceSync() async {
    if (!_isOnline.value) {
      Get.snackbar(
        'Offline',
        'Cannot sync while offline',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    _syncStatus.value = 'force_syncing';
    final success = await performSync(forceRefresh: true);

    if (success) {
      Get.snackbar(
        'Success',
        'Products synced successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to sync products',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    return success;
  }

  /// Update sync statistics
  void _updateSyncStats() {
    final stats = _syncService.getSyncStats();
    _localProductCount.value = stats['local_product_count'] ?? 0;
    _unsyncedCount.value = stats['unsynced_count'] ?? 0;
    _lastSyncTime.value = stats['last_sync_time'] != null
        ? DateTime.tryParse(stats['last_sync_time'])
        : null;
  }

  /// Get sync info for UI
  String getSyncInfo() {
    if (!_isOnline.value) {
      return 'Offline - Using cached data';
    }

    if (_isSyncing.value) {
      return 'Syncing...';
    }

    if (_lastSyncTime.value == null) {
      return 'Never synced';
    }

    final now = DateTime.now();
    final diff = now.difference(_lastSyncTime.value!);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  /// Get sync status color
  String getSyncStatusColor() {
    if (!_isOnline.value) return 'gray';
    if (_isSyncing.value) return 'blue';
    if (_syncStatus.value == 'synced') return 'green';
    if (_syncStatus.value == 'error' || _syncStatus.value == 'failed') {
      return 'red';
    }
    return 'gray';
  }

  /// Clear all local data (for testing)
  Future<void> clearLocalData() async {
    await _syncService.clearLocalData();
    _products.clear();
    _localProductCount.value = 0;
    _unsyncedCount.value = 0;
    _lastSyncTime.value = null;
    _syncStatus.value = 'cleared';

    Get.snackbar(
      'Success',
      'Local data cleared',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
