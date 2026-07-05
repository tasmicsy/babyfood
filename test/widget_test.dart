import 'package:flutter_test/flutter_test.dart';

import 'package:babyfood/main.dart';

void main() {
  testWidgets('ホーム画面がタイトルと記録ボタンを表示する', (WidgetTester tester) async {
    await tester.pumpWidget(const BabyFoodApp());
    await tester.pumpAndSettle();

    expect(find.text('もぐもぐ、いつから？'), findsOneWidget);
    expect(find.text('記録する'), findsOneWidget);
    expect(find.text('ゴックン期'), findsOneWidget);
  });
}
