import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:proteinrecord/data/RecordClassification.dart';

/// ProteinRecordクラスのテスト
void main() {
  group("MinorClassificationのテスト", () {
    test('operator ==', () {
      var record1 = MinorClassification("小分類名",
          basePoint: 3.5,
          description: 'せつめい',
          notes: 'のーと',
          imageAssetName: 'assets/image.jpg');
      var record2 = MinorClassification("小分類名",
          basePoint: 3.5,
          description: 'せつめい',
          notes: 'のーと',
          imageAssetName: 'assets/image.jpg');
      expect(record1 == record2, isTrue);
    });
  });

  group("proteinClassificationsのテスト", () {
    test('Meat', () {
      var record = proteinClassifications[MajorType.MEAT].minors;
      expect(record.length, 4);
      expect(
          record[0] ==
              MinorClassification('手のひらいっぱい',
                  description: '(100g)',
                  imageAssetName: 'assets/meat_full.png',
                  basePoint: 3.0),
          true);
      expect(
          record[1] ==
              MinorClassification('手のひら半分',
                  description: '(50〜60g)',
                  imageAssetName: 'assets/meat_half.png',
                  basePoint: 1.5),
          true);
      expect(
          record[2] ==
              MinorClassification('ひき肉',
                  description: '(30〜40g)',
                  imageAssetName: 'assets/meat_minch.png',
                  basePoint: 1.0),
          true);
      expect(
          record[3] ==
              MinorClassification('ハム・ソーセージ',
                  description: '(どちらか片方)',
                  imageAssetName: 'assets/meat_ham.png',
                  basePoint: 0.5),
          true);
    });
    test('Fish', () {
      var record = proteinClassifications[MajorType.FISH].minors;
      expect(record.length, 4);
      expect(
          record[0] ==
              MinorClassification('手のひらいっぱい',
                  description: '(60〜80g)',
                  imageAssetName: 'assets/fish_full.png',
                  basePoint: 2.0),
          true);
      expect(
          record[1] ==
              MinorClassification('手のひら半分',
                  description: '(30〜40g)',
                  imageAssetName: 'assets/fish_half.png',
                  basePoint: 1.0),
          true);
      expect(
          record[2] ==
              MinorClassification('小魚',
                  description: '(15g)',
                  imageAssetName: 'assets/fish_shirasu.png',
                  basePoint: 0.5),
          true);
      expect(
          record[3] ==
              MinorClassification('シーフード',
                  description: '(30〜50g)',
                  imageAssetName: 'assets/fish_seafood.png',
                  basePoint: 0.5),
          true);
    });
    test('Milk', () {
      var record = proteinClassifications[MajorType.MILK].minors;
      expect(record.length, 3);
      expect(
          record[0] ==
              MinorClassification('牛乳',
                  description: '(200cc)',
                  imageAssetName: 'assets/milk.png',
                  basePoint: 1.0),
          true);
      expect(
          record[1] ==
              MinorClassification('ヨーグルト',
                  description: '(1個)',
                  imageAssetName: 'assets/yogult.png',
                  basePoint: 0.5),
          true);
      expect(
          record[2] ==
              MinorClassification('チーズ',
                  description: '(1個)',
                  imageAssetName: 'assets/cheese.png',
                  basePoint: 0.5),
          true);
    });
    test('Egg', () {
      var record = proteinClassifications[MajorType.EGG].minors;
      expect(record.length, 1);
      expect(
          record[0] ==
              MinorClassification('M寸',
                  description: '(1個)',
                  imageAssetName: 'assets/egg.png',
                  basePoint: 1.0),
          true);
    });
    test('Soy', () {
      var record = proteinClassifications[MajorType.SOY].minors;
      expect(record.length, 4);
      expect(
          record[0] ==
              MinorClassification('納豆',
                  description: '(1パック)',
                  imageAssetName: 'assets/soybean.png',
                  basePoint: 1.0),
          true);
      expect(
          record[1] ==
              MinorClassification('豆腐',
                  description: '(1/4丁)',
                  imageAssetName: 'assets/tofu.png',
                  basePoint: 1.0),
          true);
      expect(
          record[2] ==
              MinorClassification('豆類',
                  description: '(30g)',
                  imageAssetName: 'assets/beans.png',
                  notes: '※ナッツ類を除く',
                  basePoint: 0.5),
          true);
      expect(
          record[3] ==
              MinorClassification('豆乳',
                  description: '(200cc)',
                  imageAssetName: 'assets/soymilk.png',
                  basePoint: 1.0),
          true);
    });
    test('Etc', () {
      var record = proteinClassifications[MajorType.ETC].minors;
      expect(record.length, 2);
      expect(
          record[0] ==
              MinorClassification('調味料',
                  description: '(1日分90g)',
                  imageAssetName: 'assets/seasoning.png',
                  notes: '※みそ・醤油等',
                  basePoint: 0.5),
          true);
      expect(
          record[1] ==
              MinorClassification('スーパープロテイン',
                  description: '(コップ1杯)',
                  imageAssetName: 'assets/protein.png',
                  basePoint: 2.5),
          true);
    });
  });
}
