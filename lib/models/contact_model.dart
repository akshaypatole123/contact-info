class Contact {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String? imagePath;
  final bool isFavorite;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.imagePath,
    this.isFavorite = false,
  });

  // Copy with helper to easily duplicate objects with modified attributes
  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? imagePath,
    bool? isFavorite,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Convert a Contact object into a Map. SQLite maps keys to database columns.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'imagePath': imagePath,
      'isFavorite': isFavorite ? 1 : 0, // SQLite doesn't have a boolean type, store 1/0
    };
  }

  // Extract a Contact object from a database Map.
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
    );
  }
}
