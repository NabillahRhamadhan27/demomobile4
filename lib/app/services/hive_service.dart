import 'package:hive/hive.dart';
import '../models/spice_model.dart';

class HiveService {
  static const boxName = 'spicesBox';

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SpiceAdapter());
    }
    await Hive.openBox<Spice>(boxName);
  }

  static Future<void> saveSpices(List<Spice> data) async {
    final box = Hive.box<Spice>(boxName);
    await box.clear();
    await box.addAll(data);
  }

  static List<Spice>? readSpices() {
    final box = Hive.box<Spice>(boxName);
    return box.values.toList();
  }
}
