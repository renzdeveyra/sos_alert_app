import 'package:flutter/material.dart';
import 'package:sos_alert_app/screens/dashboard_screen.dart';

class AlertSummaryScreen extends StatelessWidget {
  final bool wasCancelled;
  
  const AlertSummaryScreen({super.key, required this.wasCancelled});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Summary'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              wasCancelled ? Icons.cancel : Icons.check_circle,
              color: wasCancelled ? Colors.orange : Colors.green,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              wasCancelled 
                  ? 'Alert Cancelled' 
                  : 'Alert Completed Successfully',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            if (!wasCancelled)
              const Text(
                'Your emergency contacts have been notified',
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  (route) => false,
                );
              },
              child: const Text('Return to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}