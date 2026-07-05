import 'package:flutter_test/flutter_test.dart';
import 'package:apartment_rental/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ApartmentRentalApp());
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
