import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/spice_model.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;

  /// UNIVERSAL UPLOAD — WEB (uploadBinary) & ANDROID (File)
  static Future<String> uploadImageUniversal(
    XFile file,
    String fileName,
  ) async {
    final path = "uploads/$fileName";

    try {
      if (kIsWeb) {
        final bytes = await file.readAsBytes();

        await supabase.storage
            .from('spice-images')
            .uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
      } else {
        final f = File(file.path);

        await supabase.storage
            .from('spice-images')
            .upload(path, f, fileOptions: const FileOptions(upsert: true));
      }

      return supabase.storage.from('spice-images').getPublicUrl(path);
    } catch (e) {
      debugPrint("Supabase upload error: $e");
      return "";
    }
  }

  /// INSERT SPICE — Mengirim OBJEK Spice (bukan Map)
  static Future<void> insertSpice(String userId, Spice spice) async {
    try {
      await supabase.from('spices_user').insert({
        'user_id': userId,
        'spice_id': spice.id,
        'name': spice.name,
        'origin': spice.origin,
        'exportStatus': spice.exportStatus,
        'image_url': spice.image,
      });
    } catch (e) {
      debugPrint("Supabase insert error: $e");
      rethrow;
    }
  }

  static Future<void> deleteSpice(String spiceId) async {
    try {
      await supabase.from('spices_user').delete().eq('spice_id', spiceId);
    } catch (e) {
      debugPrint("Supabase delete error: $e");
      rethrow;
    }
  }
}
