import 'package:flutter/material.dart';

import '../theme/app_assets.dart';
import 'app_background.dart';

/// Shared scaffold with photo background — one image layer per screen.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.backgroundAsset = AppAssets.backgroundApp,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  /// Override for auth screens (e.g. login uses [AppAssets.backgroundAuth]).
  final String backgroundAsset;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      assetPath: backgroundAsset,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: extendBody,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
