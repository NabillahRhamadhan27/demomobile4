class Spice {
  final String id;
  final String name;
  final String origin;
  final String exportStatus;
  final String image;

  Spice({
    required this.id,
    required this.name,
    required this.origin,
    required this.exportStatus,
    required this.image,
  });

  factory Spice.fromJson(Map<String, dynamic> json) {
    return Spice(
      id: json['id'] ?? '',
      name: json['name'] ?? '-',
      origin: json['origin'] ?? '-',
      exportStatus: json['exportStatus'] ?? '-',
      image: json['image'] ?? '',
    );
  }
}
