import 'package:flutter/material.dart';

import '../data/ProteinRecord.dart';
import '../data/RecordClassification.dart';
import '../main.dart';
import '../repository/ProteinRecordRepository.dart';
import '../services/NavigationService.dart';

/// データ入力画面用のViewModel
class InputViewModel with ChangeNotifier {
  ProteinRecord record;
  ProteinRecordRepository repository;

  /// コンストラクタ
  InputViewModel(this.record, {@required this.repository}) {
    if (record == null) {
      throw ArgumentError.notNull("record");
    }
  }

  /// カウントアップ
  /// [major] 変更する大分類 [MajorType]
  /// [minorIndex] 変更する小分類インデクス
  void countUp(MajorType major, int minorIndex,
      {@required InputPageBloc bloc}) {
    final result = record.addCount(major, minorIndex);
    if (result) {
      repository.save(record);
      notifyListeners();

      bloc.setModified();
    }
  }

  /// カウントダウン
  /// [major] 変更する大分類 [MajorType]
  /// [minorIndex] 変更する小分類インデクス
  void countDown(MajorType major, int minorIndex,
      {@required InputPageBloc bloc}) {
    final result = record.subCount(major, minorIndex);
    if (result) {
      repository.save(record);
      notifyListeners();

      bloc.setModified();
    }
  }

  /// カウントをゼロクリア
  /// ゼロクリアしたデータが保存されます
  void deleteRecord({@required InputPageBloc bloc}) {
    record.clearAllPoints();
    repository.save(record);

    notifyListeners();

    bloc.setModified();
  }
}

/// BLoC:ChangeNotifierでは都合が悪いものを出す
/// ウィジェットの再描画はChangeNotifierの方が簡単なのでそちらを使う。
/// StreamBuilderは結構書くのが面倒だしコードが長くなるから。
/// こちらも厳密にはビジネスロジックではないからViewModelに近いが
/// Providerパターンの違いを明確にするため[Bloc]を使う
class InputPageBloc {
  bool _isModified = false;

  bool get isModified => _isModified;

  InputPageBloc();

  void dispose() {}

  void setModified() {
    _isModified = true;
  }

  void returnWithResult() {
    final navigatorService = locator<NavigationService>();
    navigatorService.goBack(isModified);
  }
}
