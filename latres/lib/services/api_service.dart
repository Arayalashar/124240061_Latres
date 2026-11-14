import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';

class ApiService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  Future<List<Character>> getCharacters({String? status, String? name}) async {
    final queryParameters = <String, String>{};

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParameters['status'] = status.toLowerCase();
    }

    if (name != null && name.trim().isNotEmpty) {
      queryParameters['name'] = name.trim();
    }

    final uri = Uri.parse('$baseUrl/character').replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] as List<dynamic>? ?? [];
        return results
            .map((item) => Character.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            'Gagal memuat karakter (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception && !e.toString().contains('Gagal memuat karakter')) {
        throw Exception('Terjadi kesalahan koneksi: $e');
      }
      rethrow;
    }
  }

  Future<Character> getCharacterDetail(int id) async {
    final uri = Uri.parse('$baseUrl/character/$id');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Character.fromJson(data);
      } else {
        throw Exception(
            'Gagal memuat detail karakter (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception && !e.toString().contains('Gagal memuat detail')) {
        throw Exception('Terjadi kesalahan koneksi: $e');
      }
      rethrow;
    }
  }

  Future<List<Episode>> getEpisodes() async {
    final uri = Uri.parse('$baseUrl/episode');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] as List<dynamic>? ?? [];
        return results
            .map((item) => Episode.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Gagal memuat daftar episode (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception &&
          !e.toString().contains('Gagal memuat daftar episode')) {
        throw Exception('Terjadi kesalahan koneksi: $e');
      }
      rethrow;
    }
  }
}
