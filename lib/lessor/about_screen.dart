import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  static const String id = 'AboutScreen';

  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo + name
          Center(
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 32,
                  child: Icon(Icons.apartment, size: 32),
                ),
                SizedBox(height: 12),
                Text(
                  'Flats App',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'What is Flats App?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Flats App is a smart rental platform designed to connect apartment '
                'owners and tenants in a simple, fast, and reliable way. Whether '
                'you\'re looking to rent your next home or list a property, Flats App '
                'makes it easier.',
          ),

          const SizedBox(height: 24),

          const Text(
            'Key Features',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          _BulletPoint(text: 'Browse available apartments with photos and full details.'),
          _BulletPoint(text: 'Send reservation requests directly to owners.'),
          _BulletPoint(text: 'Track booking status: Pending, Accepted, or Rejected.'),
          _BulletPoint(text: 'Manage your wallet balance, withdrawals, and deposits.'),
          _BulletPoint(text: 'Built-in chat between tenants and owners.'),
          _BulletPoint(text: 'Manage tenants and bookings from one place (for owners).'),

          const SizedBox(height: 24),

          const Text(
            'Who We Are',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Flats App was developed by a passionate team focused on making the '
                'rental process smoother, clearer, and more transparent for both '
                'tenants and property owners.',
          ),

          const SizedBox(height: 24),

          const Text(
            'Useful Links',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• Terms of Service'),
          const Text('• Privacy Policy'),
          const Text('• Contact Support'),

          const SizedBox(height: 24),

          const Text(
            'Enjoying the app?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Rate us on the store or share the app with a friend!',
          ),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
