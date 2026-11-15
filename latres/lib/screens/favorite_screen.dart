import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/favorite_service.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return Colors.green;
      case 'dead':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karakter Favorit'),
      ),
      body: ValueListenableBuilder<List<Character>>(
        valueListenable: FavoriteService.instance.favoritesNotifier,
        builder: (context, favorites, child) {
          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada karakter favorit',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tekan ikon hati pada daftar atau detail karakter untuk menyimpannya di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final character = favorites[index];
              final statusColor = _getStatusColor(character.status);

              return Dismissible(
                key: ValueKey(character.id),
                direction: DismissDirection.horizontal,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Row(
                    children: [
                      Icon(Icons.delete, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                secondaryBackground: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.delete, color: Colors.white),
                    ],
                  ),
                ),
                onDismissed: (direction) async {
                  await FavoriteService.instance.removeFavorite(character.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${character.name} berhasil dihapus dari favorit'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: ClipOval(
                      child: Image.network(
                        character.image,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image,
                              color: Colors.grey),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey[200],
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      character.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${character.status} - ${character.species}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            characterId: character.id,
                            character: character,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
