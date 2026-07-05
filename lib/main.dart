import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'db/database_helper.dart';
import 'screens/role_select_screen.dart';
import 'services/auth_provider.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  await NotificationService.instance.initialize();
  runApp(const WasteManagementApp());
}

class WasteManagementApp extends StatelessWidget {
  const WasteManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Waste Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const RoleSelectScreen(),
      ),
    );
  }
}
