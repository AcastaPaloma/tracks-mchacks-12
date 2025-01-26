
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

imglib.Image convertYUV420toImageColor(CameraImage image) {
  try {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[0].bytesPerRow;
    final int? uvPixelStride = image.planes[0].bytesPerPixel;
    // myLogger.d(image.planes[0].bytesPerRow); // nokia: 512, samsung: 320
    // myLogger.d(image.planes[0].bytesPerPixel); // 1 for both phones
    // myLogger.d(image.planes[1].bytesPerRow); // nokia: 512, samsung: 320
    // myLogger.d(image.planes[1].bytesPerPixel); // 2 for both phones
    // myLogger.d(image.planes[2].bytesPerRow); // nokia: 512, samsung: 320
    // myLogger.d(image.planes[2].bytesPerPixel); // 2 for both phones

    // imgLib -> Image package from https://pub.dartlang.org/packages/image
    var img2 = imglib.Image(width:width, height:height); // Create Image buffer

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int bytesPerRowY = image.planes[0].bytesPerRow;
        final int index = y * bytesPerRowY + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        img2.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return imglib.copyRotate(img2, angle: 90); //Image.memory(png);
  } catch (e) {
    print("ERROR: " + e.toString());
  }
  throw Exception("error during YUV420 conversion");
}


imglib.Image _convertYUV420toImageColor(CameraImage image) {
  const shift = (0xFF << 24);

  final int width = image.width;
  final int height = image.height;
  final int uvRowStride = image.planes[0].bytesPerRow;
  final int uvPixelStride = image.planes[0].bytesPerPixel!;

  final img = imglib.Image(width: height, height: width); // Create Image

  // Fill image buffer with plane[0] from YUV420_888
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
      final int index = y * width + x;

      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      // Calculate pixel color
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      // color: 0x FF  FF  FF  FFj
      //           A   B   G   R

      if (img.isBoundsSafe(height - y, x)) {
        img.setPixelRgba(height - y, x, r, g, b, shift);
      }
    }
  }

  return img;
}

// const shift = (0xFF << 24);
// Future<Image> convertYUV420toImageColor(CameraImage image) async {
//   try {
//     final int width = image.width;
//     final int height = image.height;
//     final int uvRowStride = image.planes[1].bytesPerRow;
//     final int uvPixelStride = image.planes[1].bytesPerPixel!;
//
//     print("uvRowStride: " + uvRowStride.toString());
//     print("uvPixelStride: " + uvPixelStride.toString());
//
//     // imgLib -> Image package from https://pub.dartlang.org/packages/image
//     var img = imglib.Image(width: width, height: height); // Create Image buffer
//
//     // Fill image buffer with plane[0] from YUV420_888
//     for (int x = 0; x < width; x++) {
//       for (int y = 0; y < height; y++) {
//         final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
//         final int index = y * width + x;
//
//         final yp = image.planes[0].bytes[index];
//         final up = image.planes[1].bytes[uvIndex];
//         final vp = image.planes[2].bytes[uvIndex];
//         // Calculate pixel color
//         int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
//         int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
//         int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
//         // color: 0x FF  FF  FF  FF
//         //           A   B   G   R
//         img.data[index] = shift | (b << 16) | (g << 8) | r;
//       }
//     }
//
//     imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
//     List<int> png = pngEncoder.encode(img);
//     return Image.memory(png);
//   } catch (e) {
//     print(">>>>>>>>>>>> ERROR:" + e.toString());
//   }
//   return null;
// }