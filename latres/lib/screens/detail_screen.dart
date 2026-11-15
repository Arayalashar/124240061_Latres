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
    _fetchCharacterDetail();
  }

  Future<void> _fetchCharacterDetail() async {
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
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Future<void> _toggleFavorite() async {
    if (_character == null) return;
    final isAdded =
        await FavoriteService.instance.toggleFavorite(_character!);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAdded
                ? '${_character!.name} ditambahkan ke favorit'
                : '${_character!.name} dihapus dari favorit',
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
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
                    color: isFav ? Colors.redAccent : Colors.white,
                  ),
                  tooltip:
                      isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null && _character == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Detail Karakter',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchCharacterDetail,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final character = _character!;
    final statusColor = _getStatusColor(character.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gambar Karakter
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  character.image,
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 220,
                    height: 220,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 220,
                      height: 220,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Nama Karakter
          Text(
            character.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),

          const SizedBox(height: 8),

          // Status Badge
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    character.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Detail Info Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.fingerprint,
                    label: 'Spesies',
                    value: character.species.isEmpty
                        ? 'Unknown'
                        : character.species,
                  ),
                  const Divider(height: 16),
                  _buildInfoTile(
                    icon: Icons.transgender,
                    label: 'Gender',
                    value: character.gender.isEmpty
                        ? 'Unknown'
                        : character.gender,
                  ),
                  const Divider(height: 16),
                  _buildInfoTile(
                    icon: Icons.public,
                    label: 'Origin',
                    value: character.originName.isEmpty
                        ? 'Unknown'
                        : character.originName,
                  ),
                  const Divider(height: 16),
                  _buildInfoTile(
                    icon: Icons.place,
                    label: 'Lokasi Terakhir',
                    value: character.locationName.isEmpty
                        ? 'Unknown'
                        : character.locationName,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Button Favorite
          ValueListenableBuilder<List<Character>>(
            valueListenable: FavoriteService.instance.favoritesNotifier,
            builder: (context, favorites, child) {
              final isFav =
                  FavoriteService.instance.isFavorite(character.id);
              return ElevatedButton.icon(
                onPressed: _toggleFavorite,
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                label: Text(
                  isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isFav ? Colors.redAccent : Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
