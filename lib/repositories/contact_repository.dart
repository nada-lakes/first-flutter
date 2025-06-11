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
    getData();
  }

  static Future<void> getData() async {
    final String? jsonString = _box.get(_key);

    if (jsonString == null) {
      _contacts = [];
      return;
    }
    
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      _contacts = decoded.map((contact) => Contact.fromJson(contact)).toList();
    } catch (e) {
      print("Failed to decode contacts JSON: $e");
      _contacts = [];
    }
  }

  static Future<void> _saveContacts() async {
    // Convert list of Contact objects to a single JSON string
    final String encoded = jsonEncode(_contacts.map((contact) => contact.toJson()).toList());
    await _box.put(_key, encoded);
  }

  static Future<void> addContact(Contact contact) async {
    _contacts.add(contact);
    await _saveContacts();
  }

  static Future<void> updateContact(Contact updatedContact) async {
    final index = _contacts.indexWhere((contact) => contact.id == updatedContact.id);
    if (index != -1) {
      _contacts[index] = updatedContact;
      await _saveContacts();
    }
  }

  static Future<void> deleteContact(int id) async {
      _contacts.removeWhere((contact) => contact.id == id);
      await _saveContacts();
  }

  static Future<void> updateFavoriteContact(int id, bool isFavorite) async {
    final index = _contacts.indexWhere((contact) => contact.id == id);
    if (index != -1) {
      _contacts[index].isFavorite = isFavorite;
      await _saveContacts();
    }
  }

}