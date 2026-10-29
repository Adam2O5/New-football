import 'package:flutter/material.dart';

/// Small portrait, intermediate size and landscape; normal, 130% and 200%
/// text, with both languages at the smallest 200% configuration.
const layoutScenarios = <({Size viewport, double textScale, Locale locale})>[
  (viewport: Size(320, 568), textScale: 1, locale: Locale('pl')),
  (viewport: Size(320, 568), textScale: 2, locale: Locale('pl')),
  (viewport: Size(320, 568), textScale: 2, locale: Locale('en')),
  (viewport: Size(390, 844), textScale: 1.3, locale: Locale('en')),
  (viewport: Size(844, 390), textScale: 1, locale: Locale('pl')),
  (viewport: Size(844, 390), textScale: 2, locale: Locale('en')),
];
