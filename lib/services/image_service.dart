import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class _CompressParams {
  final Uint8List bytes;
  final int maxSize;
  final int quality;

  const _CompressParams(this.bytes, this.maxSize, this.quality);
}

Uint8List _compressInIsolate(_CompressParams params) {
  final decoded = img.decodeImage(params.bytes);
  if (decoded == null) {
    throw const FormatException('画像を読み込めませんでした');
  }

  img.Image resized = decoded;
  final width = decoded.width;
  final height = decoded.height;
  if (width > height && width > params.maxSize) {
    resized = img.copyResize(decoded, width: params.maxSize);
  } else if (height >= width && height > params.maxSize) {
    resized = img.copyResize(decoded, height: params.maxSize);
  }

  return Uint8List.fromList(img.encodeJpg(resized, quality: params.quality));
}

class ImageService {
  ImageService._();

  /// 写真を縮小・再エンコードして容量を抑える。
  static Future<Uint8List> compress(
    Uint8List bytes, {
    int maxSize = 480,
    int quality = 60,
  }) {
    return compute(_compressInIsolate, _CompressParams(bytes, maxSize, quality));
  }
}
