import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pera_x_ui/app/app.dart';
import 'package:pera_x_ui/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('PEX dashboard loads', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();

    await tester.pumpWidget(const ProviderScope(child: PeraXApp()));
    await tester.pump();

    expect(find.text('Command Center'), findsOneWidget);
    expect(find.text('PEX HOLDINGS (SOLANA L1)'), findsOneWidget);
    expect(find.text('Credits'), findsWidgets);
  });
}
