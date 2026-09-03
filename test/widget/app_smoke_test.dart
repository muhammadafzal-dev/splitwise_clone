import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise_clone/app/app.dart';
import 'package:splitwise_clone/app/providers.dart';
import 'package:splitwise_clone/data/mock/mock_store.dart';

void main() {
  testWidgets('app boots to the Groups screen and shows seeded groups', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Zero-latency store so the first frame's loading state resolves fast.
          mockStoreProvider.overrideWithValue(
            MockStore(latency: Duration.zero)..seed(),
          ),
        ],
        child: const SplitwiseApp(),
      ),
    );
    await tester.pumpAndSettle();

    // The Groups tab is the initial route.
    expect(find.text('Groups'), findsWidgets);
    // Seeded groups render.
    expect(find.text('Apartment'), findsOneWidget);
    expect(find.text('Kyoto Trip'), findsOneWidget);
  });
}
