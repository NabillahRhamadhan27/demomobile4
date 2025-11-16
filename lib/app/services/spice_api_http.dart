import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/spice_model.dart';

class SpiceApiHttp {
  static const String baseUrl =
      'https://68fcf00796f6ff19b9f6c1f2.mockapi.io/api/v1/spices';

  static Future<List<Spice>> fetchSpices() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((e) => Spice.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat data rempah (HTTP)');
    }
  }
}
