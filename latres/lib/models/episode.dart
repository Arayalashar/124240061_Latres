class Episode {
  final int id;
  final String name;
  final String airDate;
  final String episodeCode;

  Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episodeCode,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      airDate: json['air_date']?.toString() ?? (json['airDate']?.toString() ?? ''),
      episodeCode: json['episode']?.toString() ?? (json['episodeCode']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'airDate': airDate,
      'episodeCode': episodeCode,
    };
  }
}
