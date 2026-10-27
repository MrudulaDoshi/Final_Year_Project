import 'package:flutter_test/flutter_test.dart';
import 'package:uwb_hospital_navigation_new_flutter/main.dart';

void main() {
  testWidgets('app title renders', (WidgetTester tester) async {
    await tester.pumpWidget(const HospitalNavigationApp());
    expect(find.text('UWB Hospital Navigation'), findsOneWidget);
  });
}
