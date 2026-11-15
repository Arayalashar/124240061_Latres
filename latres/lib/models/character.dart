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
    final origin = json['origin'];
    final location = json['location'];

    String getOriginName() {
      if (origin is Map) return origin['name'] ?? '';
      return json['originName'] ?? '';
    }

    String getLocationName() {
      if (location is Map) return location['name'] ?? '';
      return json['locationName'] ?? '';
    }

    return Character(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      species: json['species'] ?? '',
      gender: json['gender'] ?? '',
      originName: getOriginName(),
      locationName: getLocationName(),
      image: json['image'] ?? '',
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
