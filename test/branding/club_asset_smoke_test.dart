@Tags(['asset'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/branding/club_asset_registry.dart';

const _legacyFallbackAsset = 'assets/images/Syrenka FC.jpg';

void main() {
  final assetRegistry = ClubAssetRegistry.production;
  final logoPaths = List<String>.of(assetRegistry.logoAssets)..sort();
  final fallbackPath = assetRegistry.fallbackLogoAsset;
  final pathsToLoad = <String>{...logoPaths, fallbackPath}.toList()..sort();

  test(
    'validates the complete registered logo manifest and fallback',
    () async {
      expect(logoPaths, hasLength(30));
      expect(logoPaths.toSet(), equals(assetRegistry.logoAssets));
      expect(fallbackPath, isNotEmpty);
      expect(fallbackPath.toLowerCase(), endsWith('.png'));
      expect(fallbackPath, isNot(equals(_legacyFallbackAsset)));
      expect(assetRegistry.logoAssets, contains(fallbackPath));
      expect(pathsToLoad, hasLength(30));
      expect(pathsToLoad, contains(fallbackPath));

      final pubspec = await File('pubspec.yaml').readAsString();
      final declaredAssetPaths = _declaredAssetPaths(pubspec);
      for (final path in pathsToLoad) {
        expect(
          declaredAssetPaths,
          contains(path),
          reason: '$path must be explicitly declared in pubspec.yaml',
        );
      }
      expect(declaredAssetPaths, isNot(contains(_legacyFallbackAsset)));
    },
  );

  // Keep each codec smoke check in its own test zone. The Flutter test image
  // decoder can leave later codec futures pending when all 30 are decoded by
  // one test, while one deterministic asset per test completes reliably.
  for (final path in pathsToLoad) {
    testWidgets('loads and decodes registered asset $path', (tester) async {
      await tester.runAsync(() => _loadAndDecodeAsset(path));
    });
  }
}

Set<String> _declaredAssetPaths(String pubspec) {
  final lines = pubspec.split(RegExp(r'\r?\n'));
  final flutterIndex = lines.indexWhere((line) => line == 'flutter:');
  final assetsIndex = lines.indexWhere((line) => line == '  assets:');

  expect(flutterIndex, greaterThanOrEqualTo(0));
  expect(assetsIndex, greaterThan(flutterIndex));

  final declared = <String>{};
  for (var index = assetsIndex + 1; index < lines.length; index++) {
    final line = lines[index];
    final match = RegExp(r'^\s{4}-\s+(.+?)\s*$').firstMatch(line);
    if (match != null) {
      declared.add(match.group(1)!);
      continue;
    }
    if (line.trim().isEmpty) continue;
    break;
  }
  return declared;
}

Future<void> _loadAndDecodeAsset(String path) async {
  final assetData = await rootBundle.load(path);
  expect(
    assetData.lengthInBytes,
    greaterThan(0),
    reason: '$path must contain image data',
  );

  final codec = await ui.instantiateImageCodec(
    assetData.buffer.asUint8List(
      assetData.offsetInBytes,
      assetData.lengthInBytes,
    ),
  );
  try {
    final frame = await codec.getNextFrame();
    try {
      expect(
        frame.image.width,
        greaterThan(0),
        reason: '$path must decode to a positive image width',
      );
      expect(
        frame.image.height,
        greaterThan(0),
        reason: '$path must decode to a positive image height',
      );
    } finally {
      frame.image.dispose();
    }
  } finally {
    codec.dispose();
  }
}
