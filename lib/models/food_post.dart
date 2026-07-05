class FoodPost {
  final String id;
  final String imagePath;
  final String memo;
  final String stage;
  final int month;
  final int createdAt;

  const FoodPost({
    required this.id,
    required this.imagePath,
    required this.memo,
    required this.stage,
    required this.month,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'memo': memo,
        'stage': stage,
        'month': month,
        'createdAt': createdAt,
      };

  factory FoodPost.fromJson(Map<String, dynamic> json) => FoodPost(
        id: json['id'] as String,
        imagePath: json['imagePath'] as String,
        memo: json['memo'] as String? ?? '',
        stage: json['stage'] as String,
        month: json['month'] as int,
        createdAt: json['createdAt'] as int,
      );
}
