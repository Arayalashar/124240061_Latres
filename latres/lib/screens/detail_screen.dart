import 'package:flutter/material.dart';
import '../models/character.dart';

class DetailScreen extends StatelessWidget {
  final int characterId;
  final Character? character;

  const DetailScreen({
    super.key,
    required this.characterId,
    this.character,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(character?.name ?? 'Detail Karakter'),
      ),
      body: Center(
        child: Text('Detail Karakter ID: $characterId'),
      ),
    );
  }
}
