import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:proteinrecord/info_page/InfoPage.dart';
import 'package:proteinrecord/info_page/info_styles.dart';

import '../TestApp.dart';
import '../data/dummy_data.dart';

/// Infoページのテスト
void main() {
  final testViewPortSize = Size(1080, 1776);
  final mockRepository = MockPackageRepository();
  when(mockRepository.getAppName()).thenAnswer((_) => Future.value("AppName"));
  when(mockRepository.getBuildNumber()).thenAnswer((_) => Future.value("3"));
  when(mockRepository.getVersion()).thenAnswer((_) => Future.value("1.0.0"));

  /// テスト用の起動
  Widget testInfoPage() {
    return TestApp(InfoPage(
      packageInfoRepository: mockRepository,
    ));
  }

  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  group('InfoPageのウィジェット表示テスト', () {
    testWidgets('タイトルのチェック', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInfoPage());

      await tester.pumpAndSettle();

      expect(find.text('アプリ情報'), findsOneWidget);
    });

    testWidgets('アプリアイコンのチェック', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInfoPage());

      await tester.pumpAndSettle();

      // アイコンのチェック
      final finder = findByAssetImage('assets/icon/icon.png');
      expect(finder, findsOneWidget);
    });

    testWidgets('アプリ名', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInfoPage());

      await tester.pumpAndSettle();

      expect(
          find.byWidgetPredicate((widget) =>
              widget is Text &&
              widget.data == 'AppName' &&
              widget.style == appNameStyle),
          findsOneWidget);
    });

    testWidgets('バージョン', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInfoPage());

      await tester.pumpAndSettle();

      expect(
          find.byWidgetPredicate((widget) =>
              widget is Text &&
              widget.data == 'バージョン 1.0.0 (3)' &&
              widget.style == versionStyle),
          findsOneWidget);
    });

    testWidgets('ポリシーページ', (WidgetTester tester) async {
      await binding.setSurfaceSize(testViewPortSize);
      await tester.pumpWidget(testInfoPage());

      await tester.pumpAndSettle();

      expect(
          find.byWidgetPredicate((widget) =>
              widget is Text &&
              widget.data == '規約とプライバシーポリシー' &&
              widget.style == listLabelsStyle),
          findsOneWidget);
    });
  });
}
