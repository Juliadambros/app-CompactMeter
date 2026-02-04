import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o projeto')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          '',
        ),
      ),
    );
  }
}
