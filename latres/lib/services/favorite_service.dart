import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';

class FavoriteService {
  static final FavoriteService instance = FavoriteService._internal();
  FavoriteService._internal();

  static const String _key = 'favorite_characters';

  final ValueNotifier<List<Character>> favoritesNotifier =
      ValueNotifier<List<Character>>([]);

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = prefs.getStringList(_key) ?? [];
      final loadedList = stringList.map((item) {
        return Character.fromJson(jsonDecode(item));
      }).toList();
      favoritesNotifier.value = loadedList;
    } catch (_) {
      favoritesNotifier.value = [];
    }
  }

  bool isFavorite(int characterId) {
    return favoritesNotifier.value.any((c) => c.id == characterId);
  }

  Future<bool> toggleFavorite(Character character) async {
    final list = List<Character>.from(favoritesNotifier.value);
    final index = list.indexWhere((c) => c.id == character.id);
    bool added = false;

    if (index >= 0) {
      list.removeAt(index);
      added = false;
    } else {
      list.add(character);
      added = true;
    }

    await _save(list);
    return added;
  }

  Future<void> removeFavorite(int characterId) async {
    final list = List<Character>.from(favoritesNotifier.value);
    list.removeWhere((c) => c.id == characterId);
    await _save(list);
  }

  Future<void> _save(List<Character> list) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = list.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_key, stringList);
    favoritesNotifier.value = list;
  }
}
