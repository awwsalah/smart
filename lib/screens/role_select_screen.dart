import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
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
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Waste Management'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Icon(
                Icons.recycling,
                size: 80,
                color: context.appColors.accent,
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.85, 0.85)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Choose your role',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Dooro doorkaaga / Select role to continue',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
              ),
              const Spacer(),
              GlassCard(
                onTap: () => _openLogin(context, 'client'),
                child: Row(
                  children: [
                    Icon(Icons.home_outlined, color: context.appColors.accent),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client / Macmiil',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Request waste pickup',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white70),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.12, curve: Curves.easeOutCubic),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                onTap: () => _openLogin(context, 'driver'),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: context.appColors.accent,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Driver / Darawal',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Accept and collect pickups',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white70),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 160.ms, duration: 400.ms)
                  .slideY(begin: 0.12, curve: Curves.easeOutCubic),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
