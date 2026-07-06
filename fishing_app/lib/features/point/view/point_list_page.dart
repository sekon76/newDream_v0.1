import 'package:flutter/material.dart';

class PointListPage extends StatelessWidget {
  const PointListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 포인트')),
      body: const Center(child: Text('낚시 포인트 목록 (구현 예정)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
