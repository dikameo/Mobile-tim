import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String name;

  const ProductDetailPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(child: Text('Detail untuk $name')),
    );
  }
}
