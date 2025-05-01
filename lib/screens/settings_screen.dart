import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_alert_app/services/app_state.dart';
import 'package:sos_alert_app/services/contacts_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> _emergencyContacts = [];
  late TextEditingController _triggerPhraseController;

  @override
  void initState() {
    super.initState();
    _triggerPhraseController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _triggerPhraseController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emergencyContacts = prefs.getStringList('emergency_contacts') ?? [];
      _triggerPhraseController.text =
          prefs.getString('trigger_phrase') ?? 'help me';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('emergency_contacts', _emergencyContacts);
    await prefs.setString('trigger_phrase', _triggerPhraseController.text);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Emergency Contacts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._emergencyContacts.map(
            (contact) => ListTile(
              title: Text(contact),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _emergencyContacts.remove(contact);
                  });
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final contact = await ContactsHelper.selectContact();
              if (contact != null && contact.phones.isNotEmpty) {
                final phoneNumber = contact.phones.first.number;
                final contactName = contact.displayName;
                final contactInfo = '$contactName: $phoneNumber';

                setState(() {
                  if (!_emergencyContacts.contains(contactInfo)) {
                    _emergencyContacts.add(contactInfo);
                  }
                });
              }
            },
            child: const Text('Add Contact'),
          ),

          const Divider(height: 32),

          const Text(
            'Voice Activation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('Enable Voice Trigger'),
            value: appState.isListeningForTrigger,
            onChanged: (value) {
              appState.toggleListening();
            },
          ),
          TextField(
            controller: _triggerPhraseController,
            decoration: const InputDecoration(labelText: 'Trigger Phrase'),
          ),

          const Divider(height: 32),

          const Text(
            'Location Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('Share Location During Alerts'),
            value: appState.isLocationEnabled,
            onChanged: (value) {
              appState.toggleLocation();
            },
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
