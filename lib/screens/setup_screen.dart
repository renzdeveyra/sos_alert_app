import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_alert_app/screens/dashboard_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _currentStep = 0;
  final List<String> _emergencyContacts = [];
  String _triggerPhrase = "help me";
  late TextEditingController _triggerPhraseController;

  @override
  void initState() {
    super.initState();
    _triggerPhraseController = TextEditingController(text: _triggerPhrase);
  }

  @override
  void dispose() {
    _triggerPhraseController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.contacts.request();
    await Permission.location.request();
    await Permission.microphone.request();
    await Permission.sms.request();
    await Permission.phone.request();
  }

  Future<void> _completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('setup_complete', true);
    await prefs.setStringList('emergency_contacts', _emergencyContacts);
    await prefs.setString('trigger_phrase', _triggerPhraseController.text);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOS Alert Setup')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            _completeSetup();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        steps: [
          Step(
            title: const Text('Emergency Contacts'),
            content: Column(
              children: [
                const Text(
                  'Add emergency contacts who will receive your alerts',
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add contact selection logic
                  },
                  child: const Text('Add Contact'),
                ),
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Voice Activation'),
            content: Column(
              children: [
                const Text('Set up a trigger phrase for voice activation'),
                TextField(
                  controller: _triggerPhraseController,
                  decoration: const InputDecoration(
                    labelText: 'Trigger Phrase',
                  ),
                  onChanged: (value) {
                    _triggerPhrase = value;
                  },
                ),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Permissions'),
            content: Column(
              children: [
                const Text(
                  'Grant necessary permissions for the app to function',
                ),
                ElevatedButton(
                  onPressed: _requestPermissions,
                  child: const Text('Grant Permissions'),
                ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}
