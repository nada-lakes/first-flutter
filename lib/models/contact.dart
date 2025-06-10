class Contact {
  int id;
  String name;
  String phoneNumber;
  bool isFavorite;
  String? photoPath;

  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.isFavorite,
    this.photoPath
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone_number': phoneNumber,
    'is_favorite': isFavorite,
    'photo_path': photoPath,
  };

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json['id'],
    name: json['name'],
    phoneNumber: json['phone_number'],
    isFavorite: json['is_favorite'],
    photoPath: json['photo_path'],
  );

}
