import 'package:flutter/material.dart';
import '/services/http_service.dart';

class CoffeeHttpScreen extends StatefulWidget {
  const CoffeeHttpScreen({super.key});

  @override
  State<CoffeeHttpScreen> createState() => _CoffeeHttpScreenState();
}

class _CoffeeHttpScreenState extends State<CoffeeHttpScreen> {
  List coffees = [];
  bool _isLoading = false;

  Future<void> _fetchCoffees() async {
    setState(() => _isLoading = true);
    final data = await HttpService.getCoffees();
    setState(() {
      coffees = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("HTTP - package http")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchCoffees,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Muat Produk"),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : coffees.isEmpty
                ? const Center(child: Text("Tidak ada data atau gagal memuat."))
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: coffees.length,
                    itemBuilder: (context, index) {
                      final c = coffees[index];
                      final imageUrl = c['image'] ?? c['image_url'] ?? '';

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 60,
                                                  color: Colors.grey,
                                                ),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c['name'] ?? 'Tanpa Nama',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rp${c['price'] ?? '-'}",
                                    style: const TextStyle(color: Colors.brown),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
