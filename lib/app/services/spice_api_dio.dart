import 'package:dio/dio.dart';
import '../models/spice_model.dart';

class SpiceApiDio {
  static final Dio dio = Dio(
    BaseOptions(baseUrl: 'https://68fcf00796f6ff19b9f6c1f2.mockapi.io/api/v1/'),
  );

  static Future<List<Spice>> fetchSpices() async {
    final response = await dio.get('spices');

    if (response.statusCode == 200) {
      final List data = response.data as List;
      return data
          .map((e) => Spice.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat data rempah (Dio)');
    }
  }
}
