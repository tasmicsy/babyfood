class Stage {
  final String key;
  final String label;
  final String range;
  final List<int> months;

  const Stage({
    required this.key,
    required this.label,
    required this.range,
    required this.months,
  });
}

/// 月齢定義（大カテゴリ = ステージ、中カテゴリ = 月齢）
const List<Stage> kStages = [
  Stage(key: 'gokun', label: 'ゴックン期', range: '5-6ヶ月', months: [5, 6]),
  Stage(key: 'mogu', label: 'モグモグ期', range: '7-8ヶ月', months: [7, 8]),
  Stage(key: 'kami', label: 'カミカミ期', range: '9-11ヶ月', months: [9, 10, 11]),
  Stage(
    key: 'paku',
    label: 'パクパク期',
    range: '12-18ヶ月',
    months: [12, 13, 14, 15, 16, 17, 18],
  ),
];

Stage stageByKey(String key) => kStages.firstWhere((s) => s.key == key);

/// 月フィルタの「すべて」を表すセンチネル値
const int kAllMonths = -1;
