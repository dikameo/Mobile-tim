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
