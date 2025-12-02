import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/address_controller.dart';
import '../services/address_ai_service.dart';

/// Widget untuk menampilkan kandidat alamat hasil AI
class AIAddressCandidates extends StatelessWidget {
  const AIAddressCandidates({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressController>();

    return Obx(() {
      if (controller.processingAI.value) {
        return const Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  '🤖 AI sedang memproses alamat...',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }

      // Filter kandidat dengan confidence minimal 60%
      final validCandidates = controller.aiCandidates
          .where((c) => c.confidence >= 0.6)
          .toList();

      if (validCandidates.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Kandidat Alamat (AI Normalized)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 24,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      controller.aiCandidates.clear();
                      controller.aiFollowUp.value = '';
                    },
                  ),
                ],
              ),
            ),

            // Follow-up question (if any)
            if (controller.aiFollowUp.value.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade400, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.aiFollowUp.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Candidates list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: validCandidates.length,
              itemBuilder: (context, index) {
                final candidate = validCandidates[index];
                return _buildCandidateItem(controller, candidate, index);
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      );
    });
  }

  Widget _buildCandidateItem(
    AddressController controller,
    AddressCandidate candidate,
    int index,
  ) {
    final confidenceColor = _getConfidenceColor(candidate.confidence);
    final confidenceText = (candidate.confidence * 100).toStringAsFixed(0);

    return InkWell(
      onTap: () => controller.selectAICandidate(candidate),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade200, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Rank badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: index == 0
                        ? Colors.blue.shade700
                        : Colors.blue.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Confidence badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: confidenceColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '$confidenceText%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Formatted address
            Text(
              candidate.formattedAddress,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // Components (only show if available)
            if (candidate.components['city'] != null ||
                candidate.components['district'] != null ||
                candidate.components['village'] != null)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (candidate.components['city'] != null)
                    _buildComponentChip(
                      Icons.location_city,
                      candidate.components['city']!,
                    ),
                  if (candidate.components['district'] != null)
                    _buildComponentChip(
                      Icons.location_on,
                      candidate.components['district']!,
                    ),
                  if (candidate.components['village'] != null)
                    _buildComponentChip(
                      Icons.home,
                      candidate.components['village']!,
                    ),
                ],
              ),

            const SizedBox(height: 12),

            // Action button
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade700],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.touch_app, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'TAP UNTUK PILIH & GEOCODE',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blue.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
