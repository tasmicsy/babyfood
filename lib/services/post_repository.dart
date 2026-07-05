import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/food_post.dart';

/// 投稿データ（JSONファイル）と画像ファイルを端末ローカルに保存・読み込みする。
class PostRepository {
  static const _uuid = Uuid();

  Future<Directory> _rootDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/babyfood');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> _imagesDir() async {
    final root = await _rootDir();
    final dir = Directory('${root.path}/images');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _postsFile() async {
    final root = await _rootDir();
    return File('${root.path}/posts.json');
  }

  Future<List<FoodPost>> loadPosts() async {
    final file = await _postsFile();
    if (!await file.exists()) return [];
    try {
      final content = await file.readAsString();
      final decoded = jsonDecode(content) as List<dynamic>;
      final posts = decoded
          .map((e) => FoodPost.fromJson(e as Map<String, dynamic>))
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    } catch (_) {
      return [];
    }
  }

  Future<void> _writePosts(List<FoodPost> posts) async {
    final file = await _postsFile();
    await file.writeAsString(jsonEncode(posts.map((p) => p.toJson()).toList()));
  }

  Future<FoodPost> addPost({
    required Uint8List imageBytes,
    required String memo,
    required String stage,
    required int month,
  }) async {
    final id = '${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 8)}';
    final imagesDir = await _imagesDir();
    final imageFile = File('${imagesDir.path}/$id.jpg');
    await imageFile.writeAsBytes(imageBytes);

    final post = FoodPost(
      id: id,
      imagePath: imageFile.path,
      memo: memo,
      stage: stage,
      month: month,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    final posts = await loadPosts();
    posts.insert(0, post);
    await _writePosts(posts);
    return post;
  }
}
