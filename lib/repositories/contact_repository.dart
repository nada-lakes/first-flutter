import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact.dart';

class ContactRepository {
  static const String boxName = 'contactsBox';
  static const String _key = 'contacts';

  // Variables are not immediately initialized during declaration, but will be initialized later before use.
  static late Box _box;
  static List<Contact> _contacts = [];

  static List<Contact> get contacts => _contacts;

  static Future<void> init() async {
    _box = await Hive.openBox(boxName);
    final String? jsonString = _box.get(_key);

    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _contacts = decoded.map((e) => Contact.fromJson(e)).toList();
      } catch (e) {
        print("Failed to decode contacts JSON: $e");
        _contacts = [];
      }
    } else {
      _contacts = [];
    }
  }

  static Future<void> _saveContacts() async {
    // Convert list of Contact objects to a single JSON string
    final String encoded = jsonEncode(_contacts.map((c) => c.toJson()).toList());
    await _box.put(_key, encoded);
  }

  static Future<void> addContact(Contact contact) async {
    _contacts.add(contact);
    await _saveContacts();
  }

  static Future<void> updateContact(Contact updatedContact) async {
    final index = _contacts.indexWhere((c) => c.id == updatedContact.id);
    if (index != -1) {
      _contacts[index] = updatedContact;
      await _saveContacts();
    }
  }

  static Future<void> deleteContact(int id) async {
    final contact = _contacts.firstWhere((c) => c.id == id);

      _contacts.removeWhere((c) => c.id == id);
      await _saveContacts();
  }

  static Future<void> updateFavoriteContact(int id, bool isFavorite) async {
    final index = _contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      _contacts[index].isFavorite = isFavorite;
      await _saveContacts();
    }
  }

  static Future<void> refresh() async {
    final String? jsonString = _box.get(_key);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _contacts = decoded.map((e) => Contact.fromJson(e)).toList();
      } catch (e) {
        print("Failed to refresh contacts: $e");
        _contacts = [];
      }
    } else {
      _contacts = [];
    }
  }

}