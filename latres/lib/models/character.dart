class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String originName;
  final String locationName;
  final String image;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.originName,
    required this.locationName,
    required this.image,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    String parseOriginName(dynamic origin) {
      if (origin is Map) {
        return origin['name']?.toString() ?? '';
      }
      return json['originName']?.toString() ?? '';
    }

    String parseLocationName(dynamic location) {
      if (location is Map) {
        return location['name']?.toString() ?? '';
      }
      return json['locationName']?.toString() ?? '';
    }

    return Character(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      species: json['species']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      originName: parseOriginName(json['origin']),
      locationName: parseLocationName(json['location']),
      image: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'gender': gender,
      'originName': originName,
      'locationName': locationName,
      'image': image,
    };
  }
}
