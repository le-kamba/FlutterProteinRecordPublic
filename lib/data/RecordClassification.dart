import 'dart:ui';

import 'package:flutter/foundation.dart';

/// 分類データを定義するクラス
/// 分類名称と、基本点数を定義するためのものです
/// 記録用のレコードクラスはProteinRecord.dartにあります

/// 大分類
enum MajorType {
  MEAT,
  FISH,
  MILK,
  EGG,
  SOY,
  ETC,
}

/// 小分類クラス
class MinorClassification {
  /// 小分類名称
  final String name;

  /// 説明
  final String description;

  /// 注釈(Nullable)
  final String notes;

  /// イメージ画像
  final String imageAssetName;

  /// 基本点数
  final double basePoint;

  /// デフォルトコンストラクタ
  /// [notes]のみがオプション
  MinorClassification(this.name,
      {@required this.description,
      @required this.basePoint,
      @required this.imageAssetName,
      this.notes});

  @override
  bool operator ==(Object other) {
    return other is MinorClassification &&
        name == other.name &&
        description == other.description &&
        notes == other.notes &&
        imageAssetName == other.imageAssetName &&
        basePoint == other.basePoint;
  }

  @override
  int get hashCode =>
      name.hashCode ^
      description.hashCode ^
      notes.hashCode ^
      imageAssetName.hashCode ^
      basePoint.hashCode;

  @override
  String toString() {
    return "$name, $basePoint";
  }
}

/// 大分類別点数クラスの抽象クラス
class MajorClassification {
  /// 大分類type
  final MajorType typeKey;

  /// 大分類名称画像パス
//  final String imageAssetName;

  /// 大分類名称
  final String name;

  /// 大分類背景色
  final Color color;

  /// 小区分別点数のList(NonNull)
  List<MinorClassification> minors;

  /// デフォルトコンストラクタ
  /// [minors] 小分類クラスのList
  MajorClassification(this.typeKey, this.name, this.color, this.minors);

  @override
  String toString() {
    return "$typeKey, $minors";
  }
}

/// 肉類基本点数データ
final meatPoints = MajorClassification(
    MajorType.MEAT, '肉', Color.fromARGB(255, 248, 187, 208), [
  MinorClassification('手のひらいっぱい',
      description: '(100g)',
      basePoint: 3.0,
      imageAssetName: 'assets/meat_full.png'),
  MinorClassification('手のひら半分',
      description: '(50〜60g)',
      basePoint: 1.5,
      imageAssetName: 'assets/meat_half.png'),
  MinorClassification('ひき肉',
      description: '(30〜40g)',
      basePoint: 1,
      imageAssetName: 'assets/meat_minch.png'),
  MinorClassification('ハム・ソーセージ',
      description: '(どちらか片方)',
      basePoint: 0.5,
      imageAssetName: 'assets/meat_ham.png'),
]);

/// 魚類基本点数データ
final fishPoints = MajorClassification(
    MajorType.FISH, '魚', Color.fromARGB(255, 197, 225, 165), [
  MinorClassification('手のひらいっぱい',
      description: '(60〜80g)',
      basePoint: 2.0,
      imageAssetName: 'assets/fish_full.png'),
  MinorClassification('手のひら半分',
      description: '(30〜40g)',
      basePoint: 1.0,
      imageAssetName: 'assets/fish_half.png'),
  MinorClassification('小魚',
      description: '(15g)',
      basePoint: 0.5,
      imageAssetName: 'assets/fish_shirasu.png'),
  MinorClassification('シーフード',
      description: '(30〜50g)',
      basePoint: 0.5,
      imageAssetName: 'assets/fish_seafood.png'),
]);

/// 乳製品基本点数データ
final milkPoints = MajorClassification(
    MajorType.MILK, '乳製品', Color.fromARGB(255, 192, 192, 155), [
  MinorClassification('牛乳',
      description: '(200cc)',
      basePoint: 1.0,
      imageAssetName: 'assets/milk.png'),
  MinorClassification('ヨーグルト',
      description: '(1個)', basePoint: 0.5, imageAssetName: 'assets/yogult.png'),
  MinorClassification('チーズ',
      description: '(1個)', basePoint: 0.5, imageAssetName: 'assets/cheese.png'),
]);

/// 卵基本点数データ
final eggPoints = MajorClassification(
    MajorType.EGG, '卵', Color.fromARGB(255, 255, 224, 178), [
  MinorClassification('M寸',
      description: '(1個)', basePoint: 1.0, imageAssetName: 'assets/egg.png'),
]);

/// 豆類基本点数データ
final soyPoints = MajorClassification(
    MajorType.SOY, '豆', Color.fromARGB(255, 197, 225, 165), [
  MinorClassification('納豆',
      description: '(1パック)',
      basePoint: 1.0,
      imageAssetName: 'assets/soybean.png'),
  MinorClassification('豆腐',
      description: '(1/4丁)', basePoint: 1.0, imageAssetName: 'assets/tofu.png'),
  MinorClassification('豆類',
      description: '(30g)',
      basePoint: 0.5,
      imageAssetName: 'assets/beans.png',
      notes: '※ナッツ類を除く'),
  MinorClassification('豆乳',
      description: '(200cc)',
      basePoint: 1.0,
      imageAssetName: 'assets/soymilk.png'),
]);

/// その他基本点数データ
final etcPoints = MajorClassification(
    MajorType.ETC, 'その他', Color.fromARGB(255, 255, 255, 255), [
  MinorClassification('調味料',
      description: '(1日分90g)',
      basePoint: 0.5,
      imageAssetName: 'assets/seasoning.png',
      notes: '※みそ・醤油等'),
  MinorClassification('スーパープロテイン',
      description: '(コップ1杯)',
      basePoint: 2.5,
      imageAssetName: 'assets/protein.png'),
]);

final proteinClassifications = {
  MajorType.MEAT: meatPoints,
  MajorType.FISH: fishPoints,
  MajorType.MILK: milkPoints,
  MajorType.EGG: eggPoints,
  MajorType.SOY: soyPoints,
  MajorType.ETC: etcPoints,
};
