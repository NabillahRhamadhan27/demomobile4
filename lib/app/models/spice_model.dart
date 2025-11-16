import 'package:hive/hive.dart';

part 'spice_model.g.dart';

@HiveType(typeId: 0)
class Spice extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String origin;

  @HiveField(3)
  final String exportStatus;

  @HiveField(4)
  final String image; // public URL

  Spice({
    required this.id,
    required this.name,
    required this.origin,
    required this.exportStatus,
    required this.image,
  });

  String get imageUrl => image;

  factory Spice.fromJson(Map<String, dynamic> json) {
    return Spice(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '-',
      origin: json['origin'] ?? '-',
      exportStatus: json['exportStatus'] ?? json['export_status'] ?? '-',
      image: json['image'] ?? json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'origin': origin,
    'exportStatus': exportStatus,
    'image': image,
  };
}
