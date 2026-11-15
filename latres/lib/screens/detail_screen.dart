import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';

class DetailScreen extends StatefulWidget {
  final int characterId;
  final Character? character;

  const DetailScreen({
    super.key,
    required this.characterId,
    this.character,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ApiService _apiService = ApiService();
  Character? _character;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _character = widget.character;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = _character == null;
      _errorMessage = null;
    });

    try {
      final detail = await _apiService.getCharacterDetail(widget.characterId);
      if (mounted) {
        setState(() {
          _character = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return Colors.green;
      case 'dead':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _toggleFavorite() async {
    if (_character == null) return;
    final added = await FavoriteService.instance.toggleFavorite(_character!);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added
                ? '${_character!.name} ditambahkan ke favorit'
                : '${_character!.name} dihapus dari favorit',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_character?.name ?? 'Detail Karakter'),
        actions: [
          if (_character != null)
            ValueListenableBuilder<List<Character>>(
              valueListenable: FavoriteService.instance.favoritesNotifier,
              builder: (context, favorites, child) {
                final isFav =
                    FavoriteService.instance.isFavorite(_character!.id);
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null,
                  ),
                  onPressed: _toggleFavorite,
                );
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _character == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchDetail,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final character = _character!;
    final color = _getStatusColor(character.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                character.image,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            character.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    character.status,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _infoRow('Spesies', character.species),
                  const Divider(),
                  _infoRow('Gender', character.gender),
                  const Divider(),
                  _infoRow('Origin', character.originName.isEmpty ? '-' : character.originName),
                  const Divider(),
                  _infoRow('Location', character.locationName.isEmpty ? '-' : character.locationName),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<List<Character>>(
            valueListenable: FavoriteService.instance.favoritesNotifier,
            builder: (context, favorites, child) {
              final isFav = FavoriteService.instance.isFavorite(character.id);
              return ElevatedButton.icon(
                onPressed: _toggleFavorite,
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                label: Text(isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFav ? Colors.red : null,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
