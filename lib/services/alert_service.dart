import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sos_alert_app/services/location_service.dart';
import 'package:sos_alert_app/services/notification_service.dart';

class AlertService {
  static Future<Map<String, dynamic>> sendAlert() async {
    final prefs = await SharedPreferences.getInstance();
    final contacts = prefs.getStringList('emergency_contacts') ?? [];
    final isLocationEnabled = prefs.getBool('location_enabled') ?? false;

    // Extract phone numbers from contact strings (format: "Name: Number")
    final phoneNumbers =
        contacts.map((contact) {
          final parts = contact.split(': ');
          return parts.length > 1 ? parts[1] : contact;
        }).toList();

    Position? position;
    String locationText = 'Location sharing disabled';
    String locationUrl = '';

    if (isLocationEnabled) {
      position = await LocationService.getCurrentLocation();
      if (position != null) {
        locationText = LocationService.formatLocation(position);
        locationUrl = LocationService.getLocationUrl(position);
      } else {
        locationText = 'Failed to get location';
      }
    }

    // Create message content
    String messageContent = 'EMERGENCY ALERT: I need help!';
    if (position != null) {
      messageContent += '\nMy location: $locationText\n$locationUrl';
    }

    bool smsSent = false;
    int contactsNotified = 0;

    // Send SMS if there are contacts
    if (phoneNumbers.isNotEmpty) {
      try {
        // Create SMS URI with the first contact (we can only launch one SMS at a time)
        final Uri smsUri = Uri(
          scheme: 'sms',
          path: phoneNumbers.first,
          queryParameters: {'body': messageContent},
        );

        // Launch SMS app
        final canLaunch = await canLaunchUrl(smsUri);
        if (canLaunch) {
          await launchUrl(smsUri);
          smsSent = true;
          contactsNotified =
              1; // We can only send to one contact at a time with this method

          // For multiple contacts, we'll just count the first one
          if (phoneNumbers.length > 1) {
            print(
              'Note: Only sending to the first contact. Multiple SMS not supported.',
            );
          }
        } else {
          print('Could not launch SMS app');
        }
      } catch (e) {
        print('Failed to send SMS: $e');
      }
    }

    // Show local notification
    try {
      await NotificationService.showAlertNotification();
    } catch (e) {
      print('Failed to show notification: $e');
    }

    return {
      'success': true,
      'contactsNotified': contactsNotified,
      'smsSent': smsSent,
      'locationShared': position != null,
      'locationText': locationText,
      'position': position,
    };
  }
}
