import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Management'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(
                Icons.recycling,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Choose your role',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dooro doorkaaga / Select role to continue',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _openLogin(context, 'client'),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Client / Macmiil'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _openLogin(context, 'driver'),
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('Driver / Darawal'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
