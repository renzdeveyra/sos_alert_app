import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_advanced/sms_advanced.dart';
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
        final SmsSender sender = SmsSender();
        int successCount = 0;

        for (final phoneNumber in phoneNumbers) {
          final SmsMessage message = SmsMessage(phoneNumber, messageContent);

          final result = await sender.sendSms(message);
          if (result?.state == SmsMessageState.Sent) {
            successCount++;
          }
        }

        smsSent = successCount > 0;
        contactsNotified = successCount;
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
