import 'dart:async';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import '../config/supabase_config.dart';

class AddressController extends GetxController {
  RxString address = ''.obs;
  Rx<LatLng> currentLatLng = LatLng(-6.200000, 106.816666).obs;
  RxString accuracyText = ''.obs;
  RxBool loading = false.obs;
  RxBool useGPS = false.obs; // FALSE = Network Mode
  MapController? mapController;

  loc.Location location = loc.Location();
  StreamSubscription<List<ConnectivityResult>>? connectivitySub;
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    getNetworkLocation();
    _initConnectivityListener();
  }

  void setMapController(MapController controller) {
    mapController = controller;
  }

  /// ============================================================
  /// INIT CONNECTIVITY LISTENER
  /// ============================================================
  void _initConnectivityListener() {
    connectivitySub = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.isNotEmpty) {
          _handleConnectivityChange(results.first);
        }
      },
    );
  }

  /// ============================================================
  /// HANDLE INTERNET CHANGES (AUTO GPS / AUTO NETWORK RETRY)
  /// ============================================================
  void _handleConnectivityChange(ConnectivityResult status) {
    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    if (!useGPS.value) {
      // User sedang di mode NETWORK
      if (status == ConnectivityResult.none) {
        // Internet hilang → fallback ke GPS
        useGPS.value = true;
        Get.snackbar(
          "Internet Hilang",
          "Berpindah otomatis ke GPS",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        getGPSLocation();
      } else {
        // Internet kembali → retry Network dengan debounce
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          if (!useGPS.value) {
            Get.snackbar(
              "Internet Kembali",
              "Menggunakan Network Location kembali",
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 2),
            );
            getNetworkLocation();
          }
        });
      }
    }
  }

  /// Toggle GPS / Network Mode
  void toggleLocationMode(bool gps) {
    useGPS.value = gps;
    gps ? getGPSLocation() : getNetworkLocation();
  }

  /// ============================================================
  /// CHECK INTERNET
  /// ============================================================
  Future<bool> _checkInternet() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      // Handle list of connectivity results
      if (connectivityResult.isEmpty || 
          connectivityResult.contains(ConnectivityResult.none)) {
        Get.snackbar(
          "Tidak ada koneksi",
          "Mode Network membutuhkan internet",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        return false;
      }
      return true;
    } catch (e) {
      print("Error checking internet: $e");
      return false;
    }
  }

  /// ============================================================
  /// GET CURRENT LOCATION AUTO
  /// ============================================================
  Future<void> getCurrentLocation() async {
    if (useGPS.value) {
      return getGPSLocation();
    } else {
      return getNetworkLocation();
    }
  }

  /// ============================================================
  /// NETWORK LOCATION
  /// ============================================================
  Future<void> getNetworkLocation() async {
    if (loading.value) return; // Prevent multiple calls
    loading.value = true;

    try {
      // Cek internet sebelum network mode
      if (!await _checkInternet()) {
        loading.value = false;
        return;
      }

      // Enable GPS service
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          Get.snackbar(
            "Error", 
            "Layanan lokasi tidak diaktifkan",
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
      }

      // Permission
      loc.PermissionStatus permission = await location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != loc.PermissionStatus.granted) {
          Get.snackbar(
            "Error", 
            "Izin lokasi ditolak",
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
      }

      // Network mode = low accuracy
      await location.changeSettings(
        accuracy: loc.LocationAccuracy.low,
        interval: 600,
      );

      final data = await location.getLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Location request timeout');
        },
      );

      if (data.latitude != null && data.longitude != null) {
        final latLng = LatLng(data.latitude!, data.longitude!);

        _updateLocation(
          latLng,
          "Akurasi Network: ${data.accuracy?.toStringAsFixed(2) ?? 'N/A'} m",
        );

        await _getAddressFromCoordinates(latLng);
      }
    } on TimeoutException catch (_) {
      Get.snackbar(
        "Error", 
        "Timeout mendapatkan lokasi Network",
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        "Error", 
        "Gagal mendapatkan lokasi Network: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      loading.value = false;
    }
  }

  /// ============================================================
  /// GPS LOCATION
  /// ============================================================
  Future<void> getGPSLocation() async {
    if (loading.value) return; // Prevent multiple calls
    loading.value = true;

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          Get.snackbar(
            "Error", 
            "GPS tidak aktif",
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
      }

      loc.PermissionStatus permission = await location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != loc.PermissionStatus.granted) {
          Get.snackbar(
            "Error", 
            "Izin GPS ditolak",
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
      }

      await location.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        interval: 400,
      );

      final data = await location.getLocation().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException('GPS request timeout');
        },
      );

      if (data.latitude != null && data.longitude != null) {
        final latLng = LatLng(data.latitude!, data.longitude!);

        _updateLocation(
          latLng,
          "Akurasi GPS: ${data.accuracy?.toStringAsFixed(2) ?? 'N/A'} m",
        );

        await _getAddressFromCoordinates(latLng);
      }
    } on TimeoutException catch (_) {
      Get.snackbar(
        "Error", 
        "Timeout mendapatkan lokasi GPS",
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        "Error", 
        "Gagal mendapatkan lokasi GPS: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      loading.value = false;
    }
  }

  /// ============================================================
  /// SEARCH ALAMAT
  /// ============================================================
  Future<void> searchAddress(String query) async {
    if (query.isEmpty) return;

    loading.value = true;

    try {
      final result = await locationFromAddress(query).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Search timeout'),
      );

      if (result.isNotEmpty) {
        final latLng = LatLng(result.first.latitude, result.first.longitude);
        address.value = query;

        _updateLocation(latLng, "Lokasi berdasarkan alamat");
        await _getAddressFromCoordinates(latLng);
      } else {
        Get.snackbar(
          "Info", 
          "Alamat tidak ditemukan",
          snackPosition: SnackPosition.TOP,
        );
      }
    } on TimeoutException catch (_) {
      Get.snackbar(
        "Error", 
        "Timeout mencari alamat",
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      accuracyText.value = "Alamat tidak ditemukan";
      Get.snackbar(
        "Error", 
        "Gagal mencari alamat: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      loading.value = false;
    }
  }

  /// ============================================================
  /// REVERSE GEOCODING
  /// ============================================================
  Future<void> getAddressFromLatLng(LatLng latLng) async {
    loading.value = true;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude, 
        latLng.longitude,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Geocoding timeout'),
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        address.value = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        _updateLocation(latLng, "Lokasi dipilih dari peta");
      }
    } on TimeoutException catch (_) {
      Get.snackbar(
        "Error", 
        "Timeout mendapatkan alamat",
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        "Error", 
        "Gagal mendapatkan alamat: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      loading.value = false;
    }
  }

  /// ============================================================
  /// PRIVATE: Get address by coordinates
  /// ============================================================
  Future<void> _getAddressFromCoordinates(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude, 
        latLng.longitude,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        address.value = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }
    } catch (e) {
      print("Error getting address from coordinates: $e");
    }
  }

  /// ============================================================
  /// UPDATE MAP + TEXTS
  /// ============================================================
  void _updateLocation(LatLng newPos, String accuracy) {
    currentLatLng.value = newPos;
    accuracyText.value = accuracy;

    try {
      mapController?.move(newPos, 16);
    } catch (e) {
      print("Error moving map: $e");
    }
  }

  /// ============================================================
  /// SAVE ADDRESS TO SUPABASE
  /// ============================================================
  Future<bool> saveAddressToSupabase() async {
    if (address.value.isEmpty) {
      Get.snackbar(
        "Error", 
        "Alamat tidak boleh kosong",
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    final user = SupabaseConfig.currentUser;
    if (user == null) {
      Get.snackbar(
        "Error", 
        "User tidak ditemukan",
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    loading.value = true;

    try {
      final data = {
        'user_id': user.id,
        'alamat': address.value,
        'latitude': currentLatLng.value.latitude,
        'longitude': currentLatLng.value.longitude,
        'accuracy': accuracyText.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await SupabaseConfig.client
          .from('user_address')
          .upsert(data, onConflict: 'user_id');

      Get.snackbar(
        "Sukses", 
        "Alamat berhasil disimpan",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        "Error", 
        "Gagal menyimpan alamat: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      loading.value = false;
    }
  }

  /// ============================================================
  /// LOAD SAVED ADDRESS
  /// ============================================================
  Future<void> loadSavedAddress() async {
    final user = SupabaseConfig.currentUser;
    if (user == null) return;

    loading.value = true;

    try {
      final response = await SupabaseConfig.client
          .from('user_address')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        address.value = response['alamat'] ?? '';
        accuracyText.value = response['accuracy'] ?? '';

        final lat = response['latitude'] as double?;
        final lng = response['longitude'] as double?;

        if (lat != null && lng != null) {
          final latLng = LatLng(lat, lng);
          _updateLocation(latLng, accuracyText.value);
        }
      }
    } catch (e) {
      print("Failed to load saved address: $e");
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    connectivitySub?.cancel();
    mapController = null;
    super.onClose();
  }
}