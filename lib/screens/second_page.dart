import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Экинчи бет'), centerTitle: true),
      body: const Center(
        child: Text(
          'Бул экинчи беттин мазмуну 👋',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
