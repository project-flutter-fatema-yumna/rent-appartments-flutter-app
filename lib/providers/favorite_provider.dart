import 'package:flutter/material.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<int> _favoriteIds = {};
  Set<int> get favoriteIds => _favoriteIds;

  // التحقق هل الشقة مفضلة أم لا بناءً على ID الخاص بها
  bool isFavorite(int id) => _favoriteIds.contains(id);

  // تحديث الحالة
  void toggleFavorite(int id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners(); // هذا السطر سيقوم بتنبيه "كل" القلوب في "كل" الصفحات
  }

  // ميزة مهمة: لتعبئة البيانات عند تشغيل التطبيق أول مرة
 void loadInitialFavorites(List<int> ids) {
    _favoriteIds.clear(); // مسح القديم
    _favoriteIds.addAll(ids); // إضافة الجديد
    notifyListeners();
  }
}
