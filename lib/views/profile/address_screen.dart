import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/address_controller.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({Key? key}) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final MapController mapController = MapController();
  late final AddressController controller;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<AddressController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setMapController(mapController);
      // Load saved address if exists
      controller.loadSavedAddress();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      "Tersalin",
      "$label berhasil disalin ke clipboard",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _showSuccessNotification(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    // Show snackbar dengan styling yang menarik
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '✓ Berhasil Disimpan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.address.value.length > 50
                        ? '${controller.address.value.substring(0, 50)}...'
                        : controller.address.value,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Alamat Saya"), centerTitle: true),
      body: Obx(() {
        return Stack(
          children: [
            Column(
              children: [
                // ==============================
                // 🔍 SEARCH BAR
                // ==============================
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Cari Alamat",
                      hintText: "Masukkan nama jalan atau tempat",
                      filled: true,
                      fillColor: theme.cardColor,
                      labelStyle: TextStyle(color: color.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color.primary, width: 2),
                      ),
                      prefixIcon: Icon(Icons.search, color: color.primary),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: color.error),
                              onPressed: () {
                                searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {}); // Update suffix icon visibility
                    },
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        controller.searchAddress(value);
                      }
                    },
                    textInputAction: TextInputAction.search,
                  ),
                ),

                // ==============================
                // 🎚️ LOCATION MODE SWITCH
                // ==============================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi,
                          size: 20,
                          color: controller.useGPS.value
                              ? color.outline
                              : color.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Network",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: controller.useGPS.value
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: controller.useGPS.value
                                  ? color.outline
                                  : color.primary,
                            ),
                          ),
                        ),
                        Switch(
                          value: controller.useGPS.value,
                          onChanged: controller.loading.value
                              ? null
                              : controller.toggleLocationMode,
                          activeColor: color.primary,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.gps_fixed,
                                size: 20,
                                color: controller.useGPS.value
                                    ? color.primary
                                    : color.outline,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "GPS",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: controller.useGPS.value
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: controller.useGPS.value
                                      ? color.primary
                                      : color.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ==============================
                // 📍 COORDINATES DISPLAY
                // ==============================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        // Latitude Row
                        Row(
                          children: [
                            Icon(Icons.north, size: 16, color: color.primary),
                            const SizedBox(width: 8),
                            Text(
                              "Latitude:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color.outline,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.latitudeText.value,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: color.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.copy,
                                size: 18,
                                color: color.primary,
                              ),
                              onPressed: () => _copyToClipboard(
                                controller.latitudeText.value,
                                "Latitude",
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(color: color.outlineVariant, height: 1),
                        const SizedBox(height: 8),
                        // Longitude Row
                        Row(
                          children: [
                            Icon(Icons.east, size: 16, color: color.primary),
                            const SizedBox(width: 8),
                            Text(
                              "Longitude:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color.outline,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.longitudeText.value,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: color.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.copy,
                                size: 18,
                                color: color.primary,
                              ),
                              onPressed: () => _copyToClipboard(
                                controller.longitudeText.value,
                                "Longitude",
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ==============================
                // 📍 ACCURACY INFO
                // ==============================
                if (controller.accuracyText.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? color.primaryContainer.withOpacity(0.2)
                            : color.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: color.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.accuracyText.value,
                              style: TextStyle(
                                fontSize: 12,
                                color: color.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // ==============================
                // 🗺️ MAP
                // ==============================
                Expanded(
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: controller.currentLatLng.value,
                          initialZoom: 16,
                          minZoom: 5,
                          maxZoom: 18,
                          onTap: (tapPosition, point) {
                            if (!controller.loading.value) {
                              controller.getAddressFromLatLng(point);
                            }
                          },
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName: 'com.rosty.app',
                            maxZoom: 19,
                            tileProvider: NetworkTileProvider(),
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 50,
                                height: 50,
                                point: controller.currentLatLng.value,
                                child: const Icon(
                                  Icons.location_pin,
                                  size: 50,
                                  color: Colors.red,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // 🔄 Floating Buttons
                      Positioned(
                        right: 16,
                        top: 16,
                        child: Column(
                          children: [
                            // Recenter button
                            Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(28),
                              child: FloatingActionButton.small(
                                heroTag: 'recenter_map',
                                onPressed: () {
                                  try {
                                    mapController.move(
                                      controller.currentLatLng.value,
                                      16,
                                    );
                                  } catch (e) {
                                    debugPrint("Error recentering map: $e");
                                  }
                                },
                                backgroundColor: theme.cardColor,
                                child: Icon(
                                  Icons.my_location,
                                  color: color.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Refresh button
                            Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(28),
                              child: FloatingActionButton.small(
                                heroTag: 'refresh_location',
                                onPressed: controller.loading.value
                                    ? null
                                    : controller.getCurrentLocation,
                                backgroundColor: theme.cardColor,
                                child: Icon(
                                  Icons.refresh,
                                  color: controller.loading.value
                                      ? color.outline
                                      : color.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ==============================
                // 📝 ALAMAT DISPLAY
                // ==============================
                if (controller.address.value.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border(
                        top: BorderSide(color: color.outlineVariant, width: 1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: color.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Alamat Terpilih:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.address.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: color.onSurface,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                // ==============================
                // 🔥 SIMPAN BUTTON
                // ==============================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black54 : Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            controller.loading.value ||
                                controller.address.value.isEmpty
                            ? null
                            : () async {
                                final success = await controller
                                    .saveAddressToSupabase();
                                if (success && mounted) {
                                  // Tampilkan notifikasi sukses
                                  _showSuccessNotification(context);

                                  // Tunggu sebentar agar notifikasi terlihat
                                  await Future.delayed(
                                    const Duration(milliseconds: 500),
                                  );

                                  // Kembali ke halaman sebelumnya dengan data
                                  Get.back(
                                    result: {
                                      'address': controller.address.value,
                                      'latitude': controller
                                          .currentLatLng
                                          .value
                                          .latitude,
                                      'longitude': controller
                                          .currentLatLng
                                          .value
                                          .longitude,
                                    },
                                  );
                                }
                              },
                        icon: controller.loading.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    color.onPrimary,
                                  ),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          controller.loading.value
                              ? "Menyimpan..."
                              : "Simpan Alamat",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color.primary,
                          foregroundColor: color.onPrimary,
                          disabledBackgroundColor: color.primary.withOpacity(
                            0.3,
                          ),
                          disabledForegroundColor: color.onPrimary.withOpacity(
                            0.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ==============================
            // ⏳ LOADING OVERLAY
            // ==============================
            if (controller.loading.value)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    color: theme.cardColor,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              color: color.primary,
                              strokeWidth: 4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            controller.useGPS.value
                                ? "Mengambil lokasi GPS..."
                                : "Mengambil lokasi Network...",
                            style: TextStyle(
                              color: color.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Mohon tunggu sebentar",
                            style: TextStyle(
                              color: color.outline,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
