import 'package:flutter/material.dart';

import '../models/topic.dart';
import '../services/seed_service.dart';
import '../services/storage_service.dart';

class TopicProvider extends ChangeNotifier {
  TopicProvider(this._storage, this._seedService);

  final StorageService _storage;
  final SeedService _seedService;

  List<Topic> _topics = [];
  bool _loading = false;
  String _searchQuery = '';

  List<Topic> get topics {
    if (_searchQuery.isEmpty) return _topics;
    return _topics
        .where((topic) => topic.name
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  bool get isLoading => _loading;

  Future<void> bootstrap() async {
    _loading = true;
    notifyListeners();
    await _seedService.seedIfEmpty();
    _topics = await _storage.getAllTopics();
    _loading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Topic? findById(String id) {
    try {
      return _topics.firstWhere((topic) => topic.id == id);
    } catch (_) {
      return null;
    }
  }
}
