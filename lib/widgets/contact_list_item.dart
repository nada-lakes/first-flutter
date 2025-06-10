import 'dart:io';

import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactListItem extends StatelessWidget {
  final Contact contact;
  final void Function(int id, bool isFavorite) updateFavoriteContact;
  final VoidCallback onTap;

  const ContactListItem({
    super.key,
    required this.contact,
    required this.updateFavoriteContact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    Widget avatar;

    if(contact.photoPath != null && contact.photoPath!.isNotEmpty) {
      avatar = CircleAvatar(
        backgroundImage: FileImage(File(contact.photoPath!)),
        radius: 24,
      );
    } else {
      avatar = const CircleAvatar(
        radius: 24,
        child: Icon(Icons.person),
      );
    }

    return ListTile(
      leading: avatar,
      title: Text(contact.name),
      subtitle: Text(contact.phoneNumber),
      trailing: IconButton(
        icon: Icon(contact.isFavorite ? Icons.favorite : Icons.favorite_border),
        color: contact.isFavorite ? Colors.blue : Colors.blue,
        onPressed: () => updateFavoriteContact(contact.id, contact.isFavorite),
      ),
      onTap: onTap,
    );
  }
}
