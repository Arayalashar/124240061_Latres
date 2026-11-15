import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';

class ApiService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  Future<List<Character>> getCharacters({String? status, String? name}) async {
    final params = <String, String>{};

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      params['status'] = status.toLowerCase();
    }

    if (name != null && name.trim().isNotEmpty) {
      params['name'] = name.trim();
    }

    final uri = Uri.parse('$baseUrl/character').replace(
      queryParameters: params.isNotEmpty ? params : null,
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];
        return results.map((item) => Character.fromJson(item)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Gagal memuat data karakter');
      }
    } catch (e) {
      throw Exception('Gagal menghubungi server');
    }
  }

  Future<Character> getCharacterDetail(int id) async {
    final uri = Uri.parse('$baseUrl/character/$id');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Character.fromJson(data);
      } else {
        throw Exception('Gagal memuat detail karakter');
      }
    } catch (e) {
      throw Exception('Gagal menghubungi server');
    }
  }

  Future<List<Episode>> getEpisodes() async {
    final uri = Uri.parse('$baseUrl/episode');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];
        return results.map((item) => Episode.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat daftar episode');
      }
    } catch (e) {
      throw Exception('Gagal menghubungi server');
    }
  }
}
