import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import '../config/supabase_config.dart';
import '../services/address_ai_service.dart';

class AddressController extends GetxController {
  RxString address = ''.obs;
  Rx<LatLng> currentLatLng = LatLng(-6.200000, 106.816666).obs;
  RxString accuracyText = ''.obs;
  RxBool loading = false.obs;
  RxBool useGPS = false.obs; // FALSE = Network Mode

  // Tambahan untuk menampilkan koordinat
  RxString latitudeText = '-6.200000'.obs;
  RxString longitudeText = '106.816666'.obs;
  RxString coordinatesText = '-6.200000, 106.816666'.obs;

  // AI Address Processing
  final AddressAIService _aiService = AddressAIService();
  RxList<AddressCandidate> aiCandidates = <AddressCandidate>[].obs;
  RxString aiFollowUp = ''.obs;
  RxBool processingAI = false.obs;

  MapController? mapController;

  final loc.Location location = loc.Location();
  StreamSubscription<List<ConnectivityResult>>? connectivitySub;

  // Anti-flap & request staleness
  DateTime? _lastConnectivityEvent;
  int _currentRequestId = 0;

  @override
  void onInit() {
    super.onInit();
    // Load saved address first (non-blocking)
    loadSavedAddress().then((_) {
      // Jika belum ada saved address, coba network dulu (default)
      if (address.value.isEmpty) {
        _safeStartDefaultLocation();
      }
    });

    _initConnectivityListener();
  }

  void setMapController(MapController controller) {
    mapController = controller;
  }

  // UPDATE COORDINATES TEXT (helper)
  void _updateCoordinatesText(LatLng latLng) {
    latitudeText.value = latLng.latitude.toStringAsFixed(6);
    longitudeText.value = latLng.longitude.toStringAsFixed(6);
    coordinatesText.value =
        '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
  }

  // START DEFAULT LOCATION (non-blocking, protects against overlap)
  void _safeStartDefaultLocation() {
    // Start with network mode but don't block UI
    useGPS.value = false;
    getNetworkLocation();
  }

  // CONNECTIVITY LISTENER (FIXED + anti-flap)
  void _initConnectivityListener() {
    connectivitySub = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // Debounce rapid flaps: ignore events within 700ms
      final now = DateTime.now();
      if (_lastConnectivityEvent != null &&
          now.difference(_lastConnectivityEvent!).inMilliseconds < 700) {
        _lastConnectivityEvent = now;
        return;
      }
      _lastConnectivityEvent = now;
      _handleConnectivityChange(results);
    });
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // If no connectivity → fallback to GPS only if user currently on NETWORK
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      if (!useGPS.value) {
        useGPS.value = true;
        Get.snackbar(
          "Internet Hilang",
          "Berpindah otomatis ke GPS",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        // fire-and-forget
        getGPSLocation();
      }
      return;
    }

    // If connected (wifi/mobile), and user prefers NETWORK, try network location
    if (!useGPS.value) {
      getNetworkLocation();
    }
  }

  Future<bool> _checkInternet() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return !results.contains(ConnectivityResult.none) && results.isNotEmpty;
    } catch (e) {
      // conservatively assume no internet if check fails
      return false;
    }
  }

  // TOGGLE MODE LOCATION (SAFE)
  Future<void> toggleLocationMode(bool gps) async {
    // Prevent quick repeated toggles
    if (loading.value) {
      Get.snackbar("Tunggu", "Sedang memproses lokasi saat ini");
      return;
    }

    useGPS.value = gps;

    if (gps) {
      await getGPSLocation();
    } else {
      if (await _checkInternet()) {
        await getNetworkLocation();
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

  // GET CURRENT LOCATION (delegator)
  Future<void> getCurrentLocation() async {
    if (useGPS.value) {
      await getGPSLocation();
    } else {
      await getNetworkLocation();
    }
  }

  // HELPER: safe call to underlying location.getLocation with timeout
  // returns loc.LocationData? (null if failed)
  Future<loc.LocationData?> _safeRequestLocation({
    required loc.LocationAccuracy accuracy,
    required Duration timeout,
  }) async {
    try {
      // Use requestPermission/service checks before calling
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return null;
        }
      }

      loc.PermissionStatus permission = await location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != loc.PermissionStatus.granted) {
          return null;
        }
      }

      await location.changeSettings(
        accuracy: accuracy,
        interval: 500, // let package try to get fresh value
      );

      // Get location with timeout
      final data = await location.getLocation().timeout(timeout);
      return data;
    } catch (e) {
      // could be timeout or permission/service error
      return null;
    }
  }

  // NETWORK LOCATION (faster, lower accuracy, shorter timeout)
  Future<void> getNetworkLocation() async {
    // Prevent overlapping calls
    if (loading.value) return;
    loading.value = true;
    final int requestId = ++_currentRequestId;

    try {
      if (!await _checkInternet()) {
        if (requestId == _currentRequestId) {
          Get.snackbar(
            "Tidak ada koneksi",
            "Mode Network membutuhkan internet",
            snackPosition: SnackPosition.TOP,
          );
        }
        return;
      }

      // Try to obtain a quick network-based location (low accuracy, short timeout)
      final data = await _safeRequestLocation(
        accuracy: loc.LocationAccuracy.low,
        timeout: const Duration(seconds: 8),
      );

      // If this request is no longer current, ignore result
      if (requestId != _currentRequestId) return;

      if (data == null) {
        // fallback: try with slightly higher accuracy but still limited time
        final fallback = await _safeRequestLocation(
          accuracy: loc.LocationAccuracy.balanced,
          timeout: const Duration(seconds: 6),
        );

        if (requestId != _currentRequestId) return;

        if (fallback == null) {
          Get.snackbar(
            "Info",
            "Tidak dapat mendapatkan lokasi jaringan dengan cepat",
          );
          return;
        } else {
          _applyLocationData(
            fallback,
            "Akurasi Network (fallback): ${fallback.accuracy?.toStringAsFixed(2) ?? 'N/A'} m",
          );
          await _getAddressFromCoordinates(currentLatLng.value);
          return;
        }
      }

      _applyLocationData(
        data,
        "Akurasi Network: ${data.accuracy?.toStringAsFixed(2) ?? 'N/A'} m",
      );
      await _getAddressFromCoordinates(currentLatLng.value);
    } catch (e) {
      // Only show error if this request is still current
      if (requestId == _currentRequestId) {
        Get.snackbar(
          "Error",
          "Gagal mendapatkan Network Location: $e",
          snackPosition: SnackPosition.TOP,
        );
      }
    } finally {
      // Only reset loading if this is still the current request
      if (requestId == _currentRequestId) {
        loading.value = false;
      }
    }
  }

  // GPS LOCATION (higher accuracy, longer timeout but bounded)
  Future<void> getGPSLocation() async {
    if (loading.value) return;
    loading.value = true;
    final int requestId = ++_currentRequestId;

    try {
      // Stronger timeout but bounded to avoid UI freeze
      final data = await _safeRequestLocation(
        accuracy: loc.LocationAccuracy.high,
        timeout: const Duration(seconds: 12),
      );

      if (requestId != _currentRequestId) return;

      if (data == null) {
        // fallback to a balanced/low accuracy quick read
        final fallback = await _safeRequestLocation(
          accuracy: loc.LocationAccuracy.balanced,
          timeout: const Duration(seconds: 6),
        );

        if (requestId != _currentRequestId) return;

        if (fallback == null) {
          Get.snackbar(
            "Error",
            "Tidak dapat mendapatkan lokasi GPS dengan cepat",
            snackPosition: SnackPosition.TOP,
          );
          return;
        } else {
          _applyLocationData(
            fallback,
            "Akurasi GPS (fallback): ${fallback.accuracy?.toStringAsFixed(2) ?? 'N/A'} m",
          );
          await _getAddressFromCoordinates(currentLatLng.value);
          return;
        }
      }

      _applyLocationData(
        data,
        "Akurasi GPS: ${data.accuracy?.toStringAsFixed(2) ?? 'N/A'} m",
      );
      await _getAddressFromCoordinates(currentLatLng.value);
    } catch (e) {
      if (requestId == _currentRequestId) {
        Get.snackbar(
          "Error",
          "Gagal mendapatkan GPS: $e",
          snackPosition: SnackPosition.TOP,
        );
      }
    } finally {
      if (requestId == _currentRequestId) {
        loading.value = false;
      }
    }
  }

  // APPLY location data to reactive state and map
  void _applyLocationData(loc.LocationData data, String accuracy) {
    if (data.latitude != null && data.longitude != null) {
      final latLng = LatLng(data.latitude!, data.longitude!);
      currentLatLng.value = latLng;
      _updateCoordinatesText(latLng);
      accuracyText.value = accuracy;
      try {
        mapController?.move(latLng, 16);
      } catch (e) {
        // ignore map move errors
      }
    }
  }

  // AI ADDRESS NORMALIZATION (NEW)
  Future<void> processAddressWithAI(String userInput) async {
    if (userInput.isEmpty || userInput.length < 5) {
      Get.snackbar("Info", "Masukkan alamat minimal 5 karakter");
      return;
    }

    if (processingAI.value) return;

    processingAI.value = true;
    aiCandidates.clear();
    aiFollowUp.value = '';

    try {
      debugPrint('🤖 [AddressController] Processing with AI: $userInput');

      final response = await _aiService.processAddress(userInput);

      debugPrint(
        '✅ [AddressController] AI returned ${response.candidates.length} candidates',
      );

      // Filter valid candidates (confidence >= 60%)
      final validCandidates = response.candidates
          .where((c) => c.confidence >= 0.6)
          .toList();

      // Update reactive variables
      aiCandidates.value = validCandidates;
      aiFollowUp.value = response.followUp ?? '';

      // Show follow-up question if exists
      if (response.followUp != null && response.followUp!.isNotEmpty) {
        Get.snackbar(
          "Klarifikasi",
          response.followUp!,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.TOP,
        );
      }

      // If we have valid candidates, show success
      if (validCandidates.isNotEmpty) {
        Get.snackbar(
          "Berhasil",
          "Ditemukan ${validCandidates.length} kandidat alamat berkualitas tinggi",
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // No valid candidates - suggest using direct search
        Get.snackbar(
          "Gunakan Pencarian Biasa",
          "AI tidak dapat memproses alamat ini dengan confidence tinggi. Tekan Enter untuk menggunakan pencarian alamat biasa.",
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ [AddressController] AI processing error: $e');
      Get.snackbar(
        "Error",
        "Gagal memproses alamat dengan AI: $e",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      processingAI.value = false;
    }
  }

  // SELECT AI CANDIDATE & GEOCODE
  Future<void> selectAICandidate(AddressCandidate candidate) async {
    if (loading.value) return;

    loading.value = true;
    final int requestId = ++_currentRequestId;

    try {
      debugPrint(
        '🔍 [AddressController] Geocoding AI candidate: ${candidate.suggestedQuery}',
      );

      // Use suggested_query untuk geocoding
      final result = await locationFromAddress(
        candidate.suggestedQuery,
      ).timeout(const Duration(seconds: 10));

      if (requestId != _currentRequestId) return;

      if (result.isNotEmpty) {
        final latLng = LatLng(result.first.latitude, result.first.longitude);
        currentLatLng.value = latLng;
        _updateCoordinatesText(latLng);
        address.value = candidate.formattedAddress;
        accuracyText.value =
            "AI Normalized (${(candidate.confidence * 100).toStringAsFixed(0)}% confidence)";

        try {
          mapController?.move(latLng, 16);
        } catch (_) {}

        Get.snackbar(
          "Berhasil",
          "Alamat dipilih dan ditemukan di peta",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          "Info",
          "Alamat tidak ditemukan di peta. Coba kandidat lain atau ubah input.",
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      if (requestId == _currentRequestId) {
        Get.snackbar("Error", "Gagal menemukan lokasi: $e");
      }
    } finally {
      if (requestId == _currentRequestId) {
        loading.value = false;
      }
    }
  }

  // SEARCH ADDRESS (geocoding) - kept with timeout
  Future<void> searchAddress(String query) async {
    if (query.isEmpty) return;
    if (loading.value) return;

    loading.value = true;
    final int requestId = ++_currentRequestId;

    try {
      final result = await locationFromAddress(
        query,
      ).timeout(const Duration(seconds: 10));

      if (requestId != _currentRequestId) return;

      if (result.isNotEmpty) {
        final latLng = LatLng(result.first.latitude, result.first.longitude);
        currentLatLng.value = latLng;
        _updateCoordinatesText(latLng);
        address.value = query;
        accuracyText.value = "Berdasarkan alamat";
        try {
          mapController?.move(latLng, 16);
        } catch (_) {}
        await _getAddressFromCoordinates(latLng);
      } else {
        Get.snackbar("Info", "Alamat tidak ditemukan");
      }
    } catch (e) {
      if (requestId == _currentRequestId) {
        Get.snackbar("Error", "Gagal mencari alamat: $e");
      }
    } finally {
      if (requestId == _currentRequestId) {
        loading.value = false;
      }
    }
  }

  // REVERSE GEOCODING
  Future<void> getAddressFromLatLng(LatLng latLng) async {
    if (loading.value) return;
    loading.value = true;
    final int requestId = ++_currentRequestId;

    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      ).timeout(const Duration(seconds: 8));

      if (requestId != _currentRequestId) return;

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address.value = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.postalCode,
          p.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        _updateLocation(latLng, "Lokasi dipilih dari peta");
      }
    } catch (e) {
      if (requestId == _currentRequestId) {
        Get.snackbar("Error", "Gagal mendapatkan alamat: $e");
      }
    } finally {
      if (requestId == _currentRequestId) {
        loading.value = false;
      }
    }
  }

  // PRIVATE: reverse geocoding otomatis (no snackbar)
  Future<void> _getAddressFromCoordinates(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      ).timeout(const Duration(seconds: 8));

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address.value = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.postalCode,
          p.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }
    } catch (e) {
      // silent fail (we don't want to spam user)
      print("Error reverse geocoding: $e");
    }
  }

  // UPDATE MAP + TEXT (explicit)
  void _updateLocation(LatLng newPos, String accuracy) {
    currentLatLng.value = newPos;
    _updateCoordinatesText(newPos);
    accuracyText.value = accuracy;
    try {
      mapController?.move(newPos, 16);
    } catch (_) {}
  }

  // SAVE ADDRESS TO SUPABASE
  Future<bool> saveAddressToSupabase() async {
    if (address.value.isEmpty) {
      Get.snackbar("Error", "Alamat tidak boleh kosong");
      return false;
    }

    final user = SupabaseConfig.currentUser;
    if (user == null) {
      Get.snackbar("Error", "User tidak ditemukan");
      return false;
    }

    if (loading.value) return false;
    loading.value = true;
    final int requestId = ++_currentRequestId;

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
          .upsert(data, onConflict: 'user_id')
          .timeout(const Duration(seconds: 10));

      if (requestId != _currentRequestId) return false;

      Get.snackbar(
        "Sukses",
        "Alamat berhasil disimpan",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return true;
    } catch (e) {
      if (requestId == _currentRequestId) {
        Get.snackbar("Error", "Gagal menyimpan alamat: $e");
      }
      return false;
    } finally {
      if (requestId == _currentRequestId) {
        loading.value = false;
      }
    }
  }

  // LOAD SAVED ADDRESS
  Future<void> loadSavedAddress() async {
    final user = SupabaseConfig.currentUser;
    if (user == null) return;

    if (loading.value) return;
    loading.value = true;

    try {
      final res = await SupabaseConfig.client
          .from('user_address')
          .select()
          .eq('user_id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (res != null) {
        address.value = res['alamat'] ?? '';
        accuracyText.value = res['accuracy'] ?? '';

        final lat = res['latitude'] as double?;
        final lng = res['longitude'] as double?;

        if (lat != null && lng != null) {
          final latLng = LatLng(lat, lng);
          _updateLocation(latLng, accuracyText.value);
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
