// Run: flutter test test/generate_app_icon_test.dart
// This generates assets/icon_app.png from assets/logo.svg (for app icon).
// After it passes, run: dart run flutter_launcher_icons
// to update iOS/Android app icons.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cw_flutter/core/constants/app_colors.dart';

void main() {
  testWidgets('Generate app icon PNG from logo.svg', (WidgetTester tester) async {
    const svgPath = 'assets/logo.svg';
    const outPath = 'assets/icon_app.png';
    const side = 1024.0;

    final svgFile = File(svgPath);
    if (!svgFile.existsSync()) {
      throw Exception('$svgPath not found. Run from project root.');
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

    expect(byteData, isNotNull);

    final outFile = File(outPath);
    await outFile.parent.create(recursive: true);
    await outFile.writeAsBytes(byteData!.buffer.asUint8List());

    expect(outFile.existsSync(), isTrue);
  });
}
