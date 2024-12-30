import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox('userBox');
    // TODO: Ajouter d’autres boxes si nécessaire.
    // TODO: Enregistrer des adapters (Hive.registerAdapter(...)) si vous avez des modèles.
  }
}
