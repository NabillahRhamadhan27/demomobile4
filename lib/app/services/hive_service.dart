import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/spice_model.dart';

class HiveService {
  static const String boxName = 'spicesBox';
  static const String keySpices = 'spices';

  static Future<void> init() async {
    await Hive.initFlutter();

    // register adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SpiceAdapter());
    }

    await Hive.openBox(boxName);
  }

  static Future<void> saveSpices(List<Spice> spices) async {
    final box = Hive.box(boxName);
    final listJson = spices.map((e) => e.toJson()).toList();
    await box.put(keySpices, listJson);
  }

  static List<Spice>? readSpices() {
    final box = Hive.box(boxName);
    final raw = box.get(keySpices);
    if (raw == null) return null;
    try {
      final list = List<Map<String, dynamic>>.from(raw as List);
      return list.map((e) => Spice.fromJson(e)).toList();
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearCache() async {
    final box = Hive.box(boxName);
    await box.delete(keySpices);
  }

  static Future<void> removeById(String id) async {
    final current = readSpices();
    if (current == null) return;
    final filtered = current.where((s) => s.id != id).toList();
    await saveSpices(filtered);
  }
}
