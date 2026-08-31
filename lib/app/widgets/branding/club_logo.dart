import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/club_branding_provider.dart';

/// Decorative, fixed-size club logo with a fallback image and neutral
/// placeholder when neither image can be read.
class ClubLogo extends StatefulWidget {
  const ClubLogo({
    super.key,
    required this.assetPath,
    required this.fallbackAssetPath,
    this.onAssetFailure = _ignoreAssetFailure,
    this.size = 48.0,
  });

  final String assetPath;
  final String fallbackAssetPath;
  final void Function(String failedPath) onAssetFailure;
  final double size;

  @override
  State<ClubLogo> createState() => _ClubLogoState();

  static void _ignoreAssetFailure(String failedPath) {}
}

class _ClubLogoState extends State<ClubLogo> {
  String? _assetToLoad;
  String? _reportedFailure;
  bool _showPlaceholder = false;

  @override
  void initState() {
    super.initState();
    _assetToLoad = widget.assetPath;
  }

  @override
  void didUpdateWidget(covariant ClubLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath ||
        oldWidget.fallbackAssetPath != widget.fallbackAssetPath) {
      _assetToLoad = widget.assetPath;
      _reportedFailure = null;
      _showPlaceholder = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: _showPlaceholder
            ? _placeholder(context)
            : Image.asset(
                _assetToLoad ?? widget.assetPath,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  _handleImageFailure(_assetToLoad ?? widget.assetPath);
                  return _placeholder(context);
                },
              ),
      ),
    );
  }

  void _handleImageFailure(String failedPath) {
    if (_reportedFailure == failedPath) return;
    _reportedFailure = failedPath;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onAssetFailure(failedPath);
      final canUseFallback =
          failedPath == widget.assetPath &&
          widget.fallbackAssetPath.isNotEmpty &&
          widget.fallbackAssetPath != failedPath;
      if (canUseFallback) {
        setState(() {
          _assetToLoad = widget.fallbackAssetPath;
          _reportedFailure = null;
        });
      } else {
        setState(() => _showPlaceholder = true);
      }
    });
  }

  Widget _placeholder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.shield_outlined,
        size: widget.size * 0.62,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}

/// Resolves [teamId] through [clubBrandingProvider] and renders the result
/// via [ClubLogo], so callers that only have a team ID (standings, brackets,
/// rosters) don't need to touch `ClubBrandingResolution` themselves.
///
/// `ClubBrandingRegistry.resolve` already substitutes the registry's own
/// fallback asset when a team has no registered logo; `fallbackAssetPath`
/// below covers the separate case where that resolved asset path exists in
/// the registry but fails to actually load (e.g. a corrupt file), letting
/// `ClubLogo` retry once before falling back to its placeholder icon.
class TeamLogo extends ConsumerWidget {
  const TeamLogo({super.key, required this.teamId, this.size = 24});

  final String teamId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(clubBrandingProvider);
    final resolution = registry.resolve(teamId);
    return ClubLogo(
      assetPath: resolution.logoAsset,
      fallbackAssetPath: registry.assets.fallbackLogoAsset,
      size: size,
    );
  }
}
