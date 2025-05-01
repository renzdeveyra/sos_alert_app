import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsHelper {
  static Future<List<Contact>> getContacts() async {
    if (await Permission.contacts.request().isGranted) {
      return await FlutterContacts.getContacts(withProperties: true);
    }
    return [];
  }

  static Future<Contact?> selectContact() async {
    if (await Permission.contacts.request().isGranted) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        // Get full contact data
        return await FlutterContacts.getContact(contact.id);
      }
    }
    return null;
  }
}
