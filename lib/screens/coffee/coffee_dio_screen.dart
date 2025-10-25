import 'package:flutter/material.dart';
import '../../services/dio_service.dart';

class CoffeeDioScreen extends StatefulWidget {
  const CoffeeDioScreen({super.key});

  @override
  State<CoffeeDioScreen> createState() => _CoffeeDioScreenState();
}

class _CoffeeDioScreenState extends State<CoffeeDioScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _coffees = [];
  int _timeMs = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await DioCoffeeService.fetchCoffees();
      setState(() {
        _coffees = res['data'] as List<dynamic>;
        _timeMs = res['timeMs'] as int;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dio - package dio'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Waktu respon: ${(_timeMs/1000).toStringAsFixed(3)} detik'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _coffees.length,
                        itemBuilder: (context, index) {
                          final c = _coffees[index] as Map<String, dynamic>;
                          final title = c['title'] ?? 'Tidak ada judul';
                          final desc = c['description'] ?? '';
                          final image = c['image'] ?? '';
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: image != '' ? Image.network(image, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_,__,___)=> const Icon(Icons.local_cafe)) : const Icon(Icons.local_cafe),
                              title: Text(title),
                              subtitle: Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
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
