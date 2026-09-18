import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  final Player player;

  const ProfileScreen({super.key, required this.player});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Player _player;

  @override
  void initState() {
    super.initState();
    _player = widget.player;
    _reloadPlayer();
  }

  Future<void> _reloadPlayer() async {
    final freshPlayer = await StorageService.getPlayer();
    if (freshPlayer != null && mounted) {
      setState(() {
        _player = freshPlayer;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF00A896).withOpacity(0.2),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Color(0xFF00A896),
              ),
            ),
            const SizedBox(height: 16),
            // Исправлено: username вместо name
            Text(
              _player.username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'XP Упай',
                    value: '${_player.xp}',
                    icon: Icons.bolt,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Сабақтар',
                    value: '${_player.completedLessonsCount}',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
