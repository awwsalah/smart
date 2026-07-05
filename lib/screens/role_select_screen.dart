import 'package:flutter/material.dart';

import 'login_screen.dart';

/// First screen — user picks Client or Driver before login/register.
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  void _openLogin(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.recycling,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Choose your role',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dooro doorkaaga / Select role to continue',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _openLogin(context, 'client'),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Client / Macmiil'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _openLogin(context, 'driver'),
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text('Driver / Darawal'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
