import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart'; // <── WAJIB
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;

  /// UNIVERSAL UPLOAD (WEB + ANDROID)
  static Future<String> uploadImageUniversal(
    XFile file,
    String fileName,
  ) async {
    final path = "uploads/$fileName";

    try {
      if (kIsWeb) {
        // WEB: uploadBinary
        final bytes = await file.readAsBytes();

        await supabase.storage
            .from('spice-images')
            .uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
      } else {
        // ANDROID: upload melalui File langsung
        final f = File(file.path);

        await supabase.storage
            .from('spice-images')
            .upload(path, f, fileOptions: const FileOptions(upsert: true));
      }

      return supabase.storage.from('spice-images').getPublicUrl(path);
    } catch (e) {
      debugPrint("Upload error: $e");
      return "";
    }
  }

  static Future<void> insertSpice(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await supabase.from('spices').insert({
        'user_id': userId,
        'external_id': data['id'],
        'name': data['name'],
        'origin': data['origin'],
        'export_status': data['exportStatus'],
        'image': data['image'], // public URL
      });
    } catch (e) {
      debugPrint("Supabase insert error: $e");
      rethrow;
    }
  }

  static Future<void> deleteSpice(String spiceId) async {
    try {
      await supabase
          .from('spices')
          .delete()
          .or('external_id.eq.$spiceId,id.eq.$spiceId');
    } catch (e) {
      debugPrint("Supabase delete error: $e");
      rethrow;
    }
  }

  static Future<String> uploadXFile(XFile file, String fileName) async {
    final bytes = await file.readAsBytes();
    final path = 'uploads/$fileName';

    try {
      await supabase.storage
          .from('spice-images')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      return supabase.storage.from('spice-images').getPublicUrl(path);
    } catch (e) {
      debugPrint("Supabase upload error: $e");
      return "";
    }
  }
}
