import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../services/api_service.dart';

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  final ApiService _apiService = ApiService();

  List<Episode> _episodes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();
  }

  Future<void> _fetchEpisodes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final episodes = await _apiService.getEpisodes();
      if (mounted) {
        setState(() {
          _episodes = episodes;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Episode'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchEpisodes,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_episodes.isEmpty) {
      return const Center(child: Text('Tidak ada episode'));
    }

    return RefreshIndicator(
      onRefresh: _fetchEpisodes,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _episodes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final episode = _episodes[index];

          return Card(
            child: ListTile(
              leading: Chip(
                label: Text(
                  episode.episodeCode,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                episode.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(episode.airDate),
            ),
          );
        },
      ),
    );
  }
}
