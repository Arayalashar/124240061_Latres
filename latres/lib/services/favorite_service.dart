import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';

class FavoriteService {
  static final FavoriteService instance = FavoriteService._internal();
  FavoriteService._internal();
  factory FavoriteService() => instance;

  static const String _key = 'favorite_characters';

  final ValueNotifier<List<Character>> favoritesNotifier =
      ValueNotifier<List<Character>>([]);

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = prefs.getStringList(_key) ?? [];
      final loadedList = stringList.map((item) {
        final Map<String, dynamic> json =
            jsonDecode(item) as Map<String, dynamic>;
        return Character.fromJson(json);
      }).toList();
      favoritesNotifier.value = loadedList;
    } catch (e) {
      favoritesNotifier.value = [];
    }
  }

  bool isFavorite(int characterId) {
    return favoritesNotifier.value.any((c) => c.id == characterId);
  }

  Future<bool> toggleFavorite(Character character) async {
    final currentList = List<Character>.from(favoritesNotifier.value);
    final index = currentList.indexWhere((c) => c.id == character.id);
    bool isAdded = false;

    if (index >= 0) {
      currentList.removeAt(index);
      isAdded = false;
    } else {
      currentList.add(character);
      isAdded = true;
    }

    await _saveFavorites(currentList);
    return isAdded;
  }

  Future<void> removeFavorite(int characterId) async {
    final currentList = List<Character>.from(favoritesNotifier.value);
    currentList.removeWhere((c) => c.id == characterId);
    await _saveFavorites(currentList);
  }

  Future<void> _saveFavorites(List<Character> list) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = list.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_key, stringList);
    favoritesNotifier.value = List.unmodifiable(list);
  }
}
