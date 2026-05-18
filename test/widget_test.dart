import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offsub/main.dart';
import 'package:offsub/providers/subscription_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('OffSub shows empty home and add action', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SubscriptionProvider(),
        child: const OffSubApp(),
      ),
    );

    expect(find.text('OffSub'), findsOneWidget);
    expect(find.text('등록된 구독 서비스가 없어요'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}
