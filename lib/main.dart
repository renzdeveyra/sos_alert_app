import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_alert_app/screens/setup_screen.dart';
import 'package:sos_alert_app/screens/dashboard_screen.dart';
import 'package:sos_alert_app/services/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isSetupComplete = prefs.getBool('setup_complete') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: SOSAlertApp(isSetupComplete: isSetupComplete),
    ),
  );
}

class SOSAlertApp extends StatelessWidget {
  final bool isSetupComplete;

  const SOSAlertApp({super.key, required this.isSetupComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS Alert App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: isSetupComplete ? const DashboardScreen() : const SetupScreen(),
    );
  }
}
