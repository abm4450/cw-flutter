// Run from project root: flutter run -t tool/generate_app_icon.dart
// Generates assets/icon_app.png (1024x1024) from assets/logo.svg for iOS/Android app icon.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cw_flutter/core/constants/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const svgPath = 'assets/logo.svg';
  const outPath = 'assets/icon_app.png';
  const side = 1024.0;

  final svgFile = File(svgPath);
  if (!svgFile.existsSync()) {
    print('ERROR: $svgPath not found. Run from project root.');
    exit(1);
  }

  final svgString = await svgFile.readAsString();
  final loader = SvgStringLoader(svgString);
  final pictureInfo = await vg.loadPicture(loader, null);
  final picture = pictureInfo.picture;
  final size = pictureInfo.size;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final s = (side / size.width) < (side / size.height) ? side / size.width : side / size.height;
  final dx = (side - size.width * s) / 2;
  final dy = (side - size.height * s) / 2;

  canvas.drawRect(Rect.fromLTWH(0, 0, side, side), Paint()..color = AppColors.primary);
  canvas.save();
  canvas.translate(dx, dy);
  canvas.scale(s);
  canvas.drawPicture(picture);
  canvas.restore();

  final outPicture = recorder.endRecording();
  final image = await outPicture.toImage(side.toInt(), side.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  outPicture.dispose();

  if (byteData == null) {
    print('ERROR: Failed to encode PNG');
    exit(1);
  }

  final outFile = File(outPath);
  await outFile.parent.create(recursive: true);
  await outFile.writeAsBytes(byteData.buffer.asUint8List());
  print('Generated $outPath (1024x1024) from $svgPath');
  exit(0);
}
