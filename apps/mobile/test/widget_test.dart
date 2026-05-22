import 'package:flutter_test/flutter_test.dart';
import 'package:house_keeping_mobile/main.dart';

void main() {
  testWidgets('auth gate shows kakao login entry', (tester) async {
    await tester.pumpWidget(const HouseKeepingApp());

    expect(find.text('House Keeping'), findsOneWidget);
    expect(find.text('카카오로 계속하기'), findsOneWidget);
  });
}
