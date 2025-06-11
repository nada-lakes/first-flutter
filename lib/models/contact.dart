class Contact {
  int id;
  String name;
  String phoneNumber;
  bool isFavorite;
  String? photo;

  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.isFavorite,
    this.photo
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone_number': phoneNumber,
    'isFavorite': isFavorite,
    'photo': photo,
  };

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json['id'],
    name: json['name'],
    phoneNumber: json['phone_number'],
    isFavorite: json['isFavorite'],
    photo: json['photo'],
  );

}
