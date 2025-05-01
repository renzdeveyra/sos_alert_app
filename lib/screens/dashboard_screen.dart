import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_alert_app/screens/alert_screen.dart';
import 'package:sos_alert_app/screens/settings_screen.dart';
import 'package:sos_alert_app/services/app_state.dart';
import 'package:sos_alert_app/services/voice_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late VoiceService _voiceService;

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceService(onTriggerDetected: (_) => _triggerAlert());
    _initializeVoiceService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).loadSettings();
    });
  }

  Future<void> _initializeVoiceService() async {
    final prefs = await SharedPreferences.getInstance();
    final triggerPhrase = prefs.getString('trigger_phrase') ?? 'help me';
    await _voiceService.initialize();
    _voiceService.setTriggerPhrase(triggerPhrase);

    final isListening = prefs.getBool('listening_enabled') ?? false;
    if (isListening) {
      _voiceService.startListening();
    }
  }

  @override
  void dispose() {
    _voiceService.stopListening();
    super.dispose();
  }

  void _triggerAlert() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.activateAlert();

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AlertScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Alert'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status indicators
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatusIndicator(
                        'Voice Trigger',
                        appState.isListeningForTrigger,
                        Icons.mic,
                      ),
                      _buildStatusIndicator(
                        'Location',
                        appState.isLocationEnabled,
                        Icons.location_on,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // SOS Button
                GestureDetector(
                  onTap: _triggerAlert,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Tap the button to send an emergency alert',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool isActive, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: isActive ? Colors.green : Colors.grey, size: 30),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: isActive ? Colors.green : Colors.grey),
        ),
      ],
    );
  }
}
