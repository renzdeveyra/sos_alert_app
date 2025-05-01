import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_alert_app/screens/alert_summary_screen.dart';
import 'package:sos_alert_app/services/app_state.dart';
import 'package:sos_alert_app/services/alert_service.dart';
import 'package:sos_alert_app/services/location_service.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  String _locationInfo = 'Fetching location...';
  bool _isAlertSent = false;

  @override
  void initState() {
    super.initState();
    _sendAlert();
  }

  Future<void> _sendAlert() async {
    try {
      final result = await AlertService.sendAlert();

      if (result['success']) {
        setState(() {
          _isAlertSent = true;
          _locationInfo = result['locationText'];
        });
      } else {
        setState(() {
          _isAlertSent = false;
          _locationInfo = 'Failed to send alert';
        });
      }
    } catch (e) {
      setState(() {
        _isAlertSent = false;
        _locationInfo = 'Error: ${e.toString()}';
      });
    }
  }

  // This method can be used to manually refresh location if needed
  Future<void> _refreshLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _locationInfo = LocationService.formatLocation(position);
        });
      } else {
        setState(() {
          _locationInfo = 'Failed to get location';
        });
      }
    } catch (e) {
      setState(() {
        _locationInfo = 'Failed to get location';
      });
    }
  }

  void _cancelAlert() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.deactivateAlert();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AlertSummaryScreen(wasCancelled: true),
      ),
    );
  }

  void _completeAlert() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.deactivateAlert();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AlertSummaryScreen(wasCancelled: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert in Progress'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isAlertSent ? Icons.check_circle : Icons.hourglass_top,
              color: _isAlertSent ? Colors.green : Colors.orange,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              _isAlertSent ? 'Alert Sent!' : 'Sending Alert...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Text(
              'Location: $_locationInfo',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _refreshLocation,
              child: const Text('Refresh Location'),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _cancelAlert,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Cancel Alert'),
                ),
                ElevatedButton(
                  onPressed: _isAlertSent ? _completeAlert : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Complete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
