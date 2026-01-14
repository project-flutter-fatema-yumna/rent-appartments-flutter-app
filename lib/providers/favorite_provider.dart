import 'package:flutter/material.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<int> _favoriteIds = {};
  Set<int> get favoriteIds => _favoriteIds;

  bool isFavorite(int id) => _favoriteIds.contains(id);

  void toggleFavorite(int id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }
 void loadInitialFavorites(List<int> ids) {
    _favoriteIds.clear();
    _favoriteIds.addAll(ids);
    notifyListeners();
  }
}
