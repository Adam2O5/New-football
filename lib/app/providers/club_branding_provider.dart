import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/branding/club_branding_registry.dart';

/// The single production branding resolver shared by presentation screens.
///
/// Tests can replace this provider with an in-memory registry fixture without
/// creating screen-local ID maps.
final clubBrandingProvider = Provider<ClubBrandingRegistry>(
  (_) => ClubBrandingRegistry.production,
);

/// Compatibility alias for code that names the provided value explicitly.
final clubBrandingRegistryProvider = clubBrandingProvider;
