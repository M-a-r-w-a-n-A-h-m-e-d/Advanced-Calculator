import 'package:flutter/material.dart';

class Age extends StatefulWidget {
  const Age({super.key});

  @override
  State<Age> createState() => _AgeState();
}

class _AgeState extends State<Age> {
  final TextEditingController _controller = TextEditingController();
  String _age = '';

  void _calculateAge() {
    final birthDate = DateTime.tryParse(_controller.text);
    if (birthDate != null) {
      final today = DateTime.now();
      final age = today.year -
          birthDate.year -
          (today.month < birthDate.month ||
                  (today.month == birthDate.month && today.day < birthDate.day)
              ? 1
              : 0);
      setState(() {
        _age = 'Your age is $age years.';
      });
    } else {
      setState(() {
        _age = 'Invalid date format. Use YYYY-MM-DD.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Age Calculation'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter your birth date (YYYY-MM-DD)',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateAge,
              child: const Text('Calculate Age'),
            ),
            const SizedBox(height: 20),
            Text(
              _age,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
