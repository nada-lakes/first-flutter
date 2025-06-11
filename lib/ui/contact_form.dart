import 'package:first_flutter/models/contact.dart';
import 'package:first_flutter/repositories/contact_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ContactForm extends StatefulWidget {
  final Contact? contact;
  const ContactForm({super.key, this.contact});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  Uint8List? _selectedImage;
  XFile? _pickedXFile;
  String? _base64Image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      _pickedXFile = pickedFile;
      _selectedImage = imageBytes;
      _base64Image = base64Encode(imageBytes);
      if(mounted) setState(() {}); // trigger render
    }
  }

  @override
  void initState() {
    super.initState();
    Contact? contact = widget.contact;
      if (contact != null) {
        _nameController.text = contact.name;
        _phoneController.text = contact.phoneNumber;
        if (contact.photo != null) {
          final decodedBytes = base64Decode(contact.photo.toString());
          _selectedImage = decodedBytes;
          _base64Image = widget.contact?.photo;
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView( 
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          _selectedImage != null ? MemoryImage(_selectedImage!) : null,
                      child: _selectedImage == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Please input fullname",
                  labelText: "Name",
                  labelStyle: TextStyle(fontSize: 20),
                  icon: Icon(Icons.person, color: Colors.blue),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  } else if (RegExp(r'\d').hasMatch(value)) {
                    return 'Name cannot contain numbers';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _phoneController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "+62",
                  labelText: "Phone Number",
                  labelStyle: TextStyle(fontSize: 20),
                  icon: Icon(Icons.phone, color: Colors.green),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  } else if (!RegExp(r'^\+?\d+$').hasMatch(value)) {
                    return 'Only digits allowed (may start with +)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final box = Hive.box(ContactRepository.boxName);

                    String? finalPhotoPath = widget.contact?.photo;

                    if (_pickedXFile != null) {
                      finalPhotoPath = _base64Image;
                    }

                    if (widget.contact == null) {
                      int latestId = box.get('latestId', defaultValue: 0);

                      final contact = Contact(
                        id: latestId + 1,
                        name: _nameController.text,
                        phoneNumber: _phoneController.text,
                        isFavorite: false,
                        photo: finalPhotoPath,
                      );

                      await ContactRepository.addContact(contact);
                      await box.put('latestId', contact.id);
                    } else {
                      final updated = Contact(
                        id: widget.contact!.id,
                        name: _nameController.text,
                        phoneNumber: _phoneController.text,
                        isFavorite: widget.contact!.isFavorite,
                        photo: finalPhotoPath,
                      );

                      await ContactRepository.updateContact(updated);
                    }
                    if (context.mounted) Navigator.pop(context, true);
                  }
                },
                child: const Text('Save Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
