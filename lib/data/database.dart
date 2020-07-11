import 'package:hive/hive.dart';

part 'database.g.dart';

@HiveType(typeId: 1)
class RecordModel {
  @HiveField(0)
  String date;
  @HiveField(1)
  List<int> meat;
  @HiveField(2)
  List<int> fish;
  @HiveField(3)
  List<int> milk;
  @HiveField(4)
  List<int> egg;
  @HiveField(5)
  List<int> soy;
  @HiveField(6)
  List<int> etc;
  @HiveField(7)
  bool wentWorkout;

  RecordModel(this.date, this.meat, this.fish, this.milk, this.egg, this.soy,
      this.etc, this.wentWorkout);
}

/// Boxを内包するクラス
/// Singletonやboxを開くのを非同期で待つのに使う
/// Boxのファイル名を間違えないようにするためにもこれを起点にアクセスすることとする
/// また、DIに対応するときにもきっと役に立つ
class RecordModelBox {
  Future<Box> box = Hive.openBox<RecordModel>('record');

  /// deleteFromDiskをした後はdatabaseが閉じてしまうため、もう一度開くための関数
  Future<void> open() async {
    Box b = await box;
    if (!b.isOpen) {
      box = Hive.openBox<RecordModel>('record');
    }
  }
}
