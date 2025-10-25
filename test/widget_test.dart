import 'package:flutter_test/flutter_test.dart';
import 'package:demomodul3/main.dart'; // pastikan nama project sesuai pubspec.yaml

void main() {
  testWidgets('SpiceTrack Dashboard loads successfully', (
    WidgetTester tester,
  ) async {
    // Build app dan jalankan frame
    await tester.pumpWidget(const SpiceTrackApp());

    // Cek apakah teks judul SpiceTrack muncul
    expect(find.text('SpiceTrack Dashboard'), findsOneWidget);
  });
}
