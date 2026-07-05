import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_assets.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/icon_badge.dart';
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
    final colors = context.appColors;

    return AppScaffold(
      backgroundAsset: AppAssets.backgroundAuth,
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
              IconBadge(
                icon: Icons.recycling,
                size: 88,
                iconSize: 44,
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.85, 0.85)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Choose your role',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: colors.onGradient,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Dooro doorkaaga / Select role to continue',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onGradient.withValues(alpha: 0.85),
                    ),
              ),
              const Spacer(),
              GlassCard(
                onTap: () => _openLogin(context, 'client'),
                child: Row(
                  children: [
                    const IconBadge(
                      icon: Icons.home_outlined,
                      size: 44,
                      iconSize: 22,
                    ),
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
                    Icon(Icons.chevron_right, color: colors.textSecondary),
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
                    const IconBadge(
                      icon: Icons.local_shipping_outlined,
                      size: 44,
                      iconSize: 22,
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
                    Icon(Icons.chevron_right, color: colors.textSecondary),
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
