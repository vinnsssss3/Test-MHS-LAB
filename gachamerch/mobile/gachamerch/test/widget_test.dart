import 'package:flutter_test/flutter_test.dart';
import 'package:gachamerch/main.dart';
import 'package:provider/provider.dart';
import 'package:gachamerch/providers/auth_provider.dart';
import 'package:gachamerch/providers/store_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => StoreProvider()),
        ],
        child: const GachaMerchApp(),
      ),
    );
    expect(find.byType(GachaMerchApp), findsOneWidget);
  });
}
