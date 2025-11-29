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

  @override
  void onInit() {
    super.onInit();
    getNetworkLocation(); // Start default
    _initConnectivityListener();
  }

  void setMapController(MapController controller) {
    mapController = controller;
  }

  // ============================================================
  // CONNECTIVITY LISTENER (FIXED)
  // ============================================================
  void _initConnectivityListener() {
    connectivitySub = Connectivity().onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // Internet hilang → fallback otomatis ke GPS jika user pakai NETWORK
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      if (!useGPS.value) {
        useGPS.value = true;
        Get.snackbar(
          "Internet Hilang",
          "Berpindah otomatis ke GPS",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        getGPSLocation();
      }
      return;
    }

    // Internet kembali → jika user MODE NETWORK, aktifkan kembali
    if (!useGPS.value) {
      getNetworkLocation();
    }
  }

  // ============================================================
  // CHECK INTERNET (FIXED)
  // ============================================================
  Future<bool> _checkInternet() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none) && results.isNotEmpty;
  }

  // ============================================================
  // TOGGLE MODE LOCATION (SAFE)
  // ============================================================
  Future<void> toggleLocationMode(bool gps) async {
    useGPS.value = gps;

    if (gps) {
      getGPSLocation();
    } else {
      if (await _checkInternet()) {
        getNetworkLocation();
      } else {
        Get.snackbar(
          "Tidak ada Internet",
          "Tidak bisa masuk mode Network. Tetap pakai GPS.",
          snackPosition: SnackPosition.TOP,
        );
        useGPS.value = true;
      }
    }
  }

  // ============================================================
  // AUTO GET LOCATION (GPS/NETWORK)
  // ============================================================
  Future<void> getCurrentLocation() async {
    if (useGPS.value) {
      return getGPSLocation();
    }
    return getNetworkLocation();
  }

  // ============================================================
  // NETWORK LOCATION
  // ============================================================
  Future<void> getNetworkLocation() async {
    if (loading.value) return;

    loading.value = true;

    try {
      if (!await _checkInternet()) {
        Get.snackbar(
          "Tidak ada koneksi",
          "Mode Network membutuhkan internet",
          snackPosition: SnackPosition.TOP,
        );
        loading.value = false;
        return;
      }

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          Get.snackbar("Error", "Layanan lokasi tidak aktif");
          loading.value = false;
          return;
        }
      }

      loc.PermissionStatus permission = await location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != loc.PermissionStatus.granted) {
          Get.snackbar("Error", "Izin lokasi ditolak");
          loading.value = false;
          return;
        }
      }

      await location.changeSettings(
        accuracy: loc.LocationAccuracy.low,
        interval: 600,
      );

      final data = await location.getLocation().timeout(
        const Duration(seconds: 15),
      );

      if (data.latitude != null && data.longitude != null) {
        LatLng latLng = LatLng(data.latitude!, data.longitude!);

        _updateLocation(
          latLng,
          "Akurasi Network: ${data.accuracy?.toStringAsFixed(2) ?? 'N/A'} m",
        );

        await _getAddressFromCoordinates(latLng);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal mendapatkan Network Location: $e",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      loading.value = false;
    }
  }

  // ============================================================
  // GPS LOCATION
  // ============================================================
  Future<void> getGPSLocation() async {
    if (loading.value) return;

    loading.value = true;

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          Get.snackbar("Error", "GPS tidak aktif");
          loading.value = false;
          return;
        }
      }

      loc.PermissionStatus permission = await location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != loc.PermissionStatus.granted) {
          Get.snackbar("Error", "Izin lokasi ditolak");
          loading.value = false;
          return;
        }
      }

      await location.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        interval: 400,
      );

      final data = await location.getLocation().timeout(
        const Duration(seconds: 20),
      );

      if (data.latitude != null && data.longitude != null) {
        LatLng latLng = LatLng(data.latitude!, data.longitude!);

        _updateLocation(
          latLng,
          "Akurasi GPS: ${data.accuracy?.toStringAsFixed(2) ?? 'N/A'} m",
        );

        await _getAddressFromCoordinates(latLng);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal mendapatkan GPS: $e",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      loading.value = false;
    }
  }

  // ============================================================
  // SEARCH ADDRESS
  // ============================================================
  Future<void> searchAddress(String query) async {
    if (query.isEmpty) return;

    loading.value = true;

    try {
      final result = await locationFromAddress(
        query,
      ).timeout(const Duration(seconds: 10));

      if (result.isNotEmpty) {
        LatLng latLng = LatLng(result.first.latitude, result.first.longitude);

        _updateLocation(latLng, "Lokasi berdasarkan alamat");

        await _getAddressFromCoordinates(latLng);
      } else {
        Get.snackbar("Info", "Alamat tidak ditemukan");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mencari alamat: $e");
    } finally {
      loading.value = false;
    }
  }

  // ============================================================
  // REVERSE GEOCODING
  // ============================================================
  Future<void> getAddressFromLatLng(LatLng latLng) async {
    loading.value = true;

    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark p = placemarks.first;

        address.value = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.postalCode,
          p.country,
        ].where((e) => e != null && e!.isNotEmpty).join(', ');

        _updateLocation(latLng, "Lokasi dipilih dari peta");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mendapatkan alamat: $e");
    } finally {
      loading.value = false;
    }
  }

  // ============================================================
  // PRIVATE: reverse geocoding otomatis
  // ============================================================
  Future<void> _getAddressFromCoordinates(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark p = placemarks.first;

        address.value = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.postalCode,
          p.country,
        ].where((e) => e != null && e!.isNotEmpty).join(', ');
      }
    } catch (e) {
      print("Error reverse geocoding: $e");
    }
  }

  // ============================================================
  // UPDATE MAP + TEXT
  // ============================================================
  void _updateLocation(LatLng newPos, String accuracy) {
    currentLatLng.value = newPos;
    accuracyText.value = accuracy;

    try {
      mapController?.move(newPos, 16);
    } catch (_) {}
  }

  // ============================================================
  // SAVE ADDRESS TO SUPABASE
  // ============================================================
  Future<bool> saveAddressToSupabase() async {
    if (address.value.isEmpty) {
      Get.snackbar("Error", "Alamat tidak boleh kosong");
      return false;
    }

    final user = SupabaseConfig.currentUser;
    if (user == null) return false;

    loading.value = true;

    try {
      await SupabaseConfig.client.from('user_address').upsert({
        'user_id': user.id,
        'alamat': address.value,
        'latitude': currentLatLng.value.latitude,
        'longitude': currentLatLng.value.longitude,
        'accuracy': accuracyText.value,
        'updated_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar("Sukses", "Alamat berhasil disimpan");
      return true;
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan alamat: $e");
      return false;
    } finally {
      loading.value = false;
    }
  }

  // ============================================================
  // LOAD SAVED ADDRESS
  // ============================================================
  Future<void> loadSavedAddress() async {
    final user = SupabaseConfig.currentUser;
    if (user == null) return;

    loading.value = true;

    try {
      final res = await SupabaseConfig.client
          .from('user_address')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (res != null) {
        address.value = res['alamat'] ?? '';
        accuracyText.value = res['accuracy'] ?? '';

        final lat = res['latitude'] as double?;
        final lng = res['longitude'] as double?;

        if (lat != null && lng != null) {
          _updateLocation(LatLng(lat, lng), accuracyText.value);
        }
      }
    } catch (e) {
      print("Error load saved address: $e");
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    connectivitySub?.cancel();
    mapController = null;
    super.onClose();
  }
}
