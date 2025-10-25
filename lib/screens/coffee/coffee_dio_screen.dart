import 'package:flutter/material.dart';
import '/services/dio_service.dart';

class CoffeeDioScreen extends StatefulWidget {
  const CoffeeDioScreen({super.key});

  @override
  State<CoffeeDioScreen> createState() => _CoffeeDioScreenState();
}

class _CoffeeDioScreenState extends State<CoffeeDioScreen> {
  List coffees = [];
  bool _isLoading = false;

  Future<void> _fetchCoffees() async {
    setState(() => _isLoading = true);
    final data = await DioService.getCoffees();
    setState(() {
      coffees = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dio - package dio")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchCoffees,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Muat Produk"),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : coffees.isEmpty
                ? const Center(child: Text("Tidak ada data atau gagal memuat."))
                : ListView.builder(
                    itemCount: coffees.length,
                    itemBuilder: (context, index) {
                      final c = coffees[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          title: Text(c['name'] ?? 'Tanpa Nama'),
                          subtitle: Text(c['description'] ?? ''),
                          trailing: Text("Rp${c['price'] ?? '-'}"),
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
