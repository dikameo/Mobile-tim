import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_product_controller.dart';
import '../../config/theme.dart';

class AdminProductFormScreen extends StatelessWidget {
  final bool isEdit;
  final String? productId;
  final String? productName;

  const AdminProductFormScreen({
    super.key,
    required this.isEdit,
    this.productId,
    this.productName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<AdminProductController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add New Product'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Obx(
        () => controller.isSaving.value
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Saving product...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    _buildTextField(
                      controller: controller.nameController,
                      label: 'Product Name *',
                      hint: 'e.g., ProRoast 1000',
                      icon: Icons.inventory_2,
                    ),
                    const SizedBox(height: 16),

                    // Price
                    _buildTextField(
                      controller: controller.priceController,
                      label: 'Price (Rp) *',
                      hint: 'e.g., 15000000',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Capacity
                    _buildTextField(
                      controller: controller.capacityController,
                      label: 'Capacity',
                      hint: 'e.g., 1kg, 5kg',
                      icon: Icons.scale,
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    _buildCategoryDropdown(controller),
                    const SizedBox(height: 16),

                    // Description
                    _buildTextField(
                      controller: controller.descriptionController,
                      label: 'Description',
                      hint: 'Enter product description...',
                      icon: Icons.description,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 24),

                    // Images Section
                    const Text(
                      'Product Images',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Existing Images (for edit mode)
                    if (isEdit && controller.existingImageUrls.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Images:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              controller.existingImageUrls.length,
                              (index) => Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      controller.existingImageUrls[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () =>
                                          controller.removeExistingImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Selected New Images
                    if (controller.selectedImages.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'New Images Selected:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              controller.selectedImages.length,
                              (index) => Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      controller.selectedImages[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () =>
                                          controller.removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Pick Images Button
                    OutlinedButton.icon(
                      onPressed: controller.pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(isEdit ? 'Add More Images' : 'Select Images'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        foregroundColor: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tip: Select multiple images at once',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: () {
                        if (isEdit && productId != null) {
                          controller.updateProduct(productId!);
                        } else {
                          controller.createProduct();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isEdit ? 'Update Product' : 'Create Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.brightness == Brightness.dark
                    ? AppTheme.secondaryOrange
                    : AppTheme.primaryCharcoal,
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown(AdminProductController controller) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return DropdownButtonFormField<String>(
          value: controller.categoryController.text.isEmpty
              ? null
              : controller.categoryController.text,
          decoration: InputDecoration(
            labelText: 'Category *',
            prefixIcon: const Icon(Icons.category),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.brightness == Brightness.dark
                    ? AppTheme.secondaryOrange
                    : AppTheme.primaryCharcoal,
                width: 2,
              ),
            ),
          ),
          items: controller.categories
              .where((cat) => cat != 'All')
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              controller.categoryController.text = value;
            }
          },
        );
      },
    );
  }
}
