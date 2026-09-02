import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/branding/club_color_tokens.dart';
import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/development_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class DevelopmentScreen extends ConsumerStatefulWidget {
  const DevelopmentScreen({super.key});

  @override
  ConsumerState<DevelopmentScreen> createState() => _DevelopmentScreenState();
}

class _DevelopmentScreenState extends ConsumerState<DevelopmentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Column widths shared between the header row and data rows so they stay
  // pixel-aligned inside the horizontally scrollable table.
  static const double _colNameWidth = 140;
  static const double _colAgeWidth = 40;
  static const double _colPositionWidth = 40;
  static const double _colOvrWidth = 36;
  static const double _colOvrDeltaWidth = 44;
  static const double _colPotentialWidth = 68;
  static const double _colPotentialDeltaWidth = 44;

  static const double _playersTableWidth =
      _colNameWidth +
      _colAgeWidth +
      _colPositionWidth +
      _colOvrWidth +
      _colOvrDeltaWidth +
      _colPotentialWidth +
      _colPotentialDeltaWidth +
      16;

  // Staff attribute values are shown as a 5-star rating derived from the raw
  // 0-99 rating scale used elsewhere for attributes (see `_bar` in
  // player_detail_screen.dart). Adjust if staff attributes use a different
  // scale.
  static const double _staffAttrMax = 5.0;
  static const int _staffAttrStarCount = 5;
  static const double _staffAttrValueWidth = 64;
  static const double _staffAttrDeltaWidth = 40;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = ref.watch(developmentDataProvider);
    if (data == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.dev_title),
          leading: IconButton(
            tooltip: l10n.common_cancel,
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/game'),
          ),
        ),
        body: ScreenBackground(child: Center(child: Text(l10n.dev_noTeam))),
      );
    }

    final team = ref.watch(activeLeagueProvider)?.playerTeam;
    final brandingRegistry = ref.watch(clubBrandingProvider);
    final branding = team == null ? null : brandingRegistry.resolve(team.id);
    final colorScheme = Theme.of(context).colorScheme;
    final headerBackground = branding?.primaryColor ?? colorScheme.surface;
    final headerForeground = branding == null
        ? colorScheme.onSurface
        : foregroundFor(headerBackground);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dev_title),
        backgroundColor: headerBackground,
        foregroundColor: headerForeground,
        leading: IconButton(
          tooltip: l10n.common_cancel,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/game'),
        ),
      ),
      body: ScreenBackground(
        child: Column(
          children: [
            Material(
              color: headerBackground,
              child: TabBar(
                controller: _tabController,
                labelColor: headerForeground,
                unselectedLabelColor: headerForeground.withValues(alpha: 0.7),
                indicatorColor: headerForeground,
                tabs: [
                  Tab(text: l10n.dev_tabPlayers),
                  Tab(text: l10n.dev_tabStaff),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPlayersTab(context, l10n, data),
                  _buildStaffTab(context, l10n, data),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Players tab ---------------------------------------------------------

  Widget _buildPlayersTab(
    BuildContext context,
    AppLocalizations l10n,
    DevelopmentData data,
  ) {
    if (data.players.isEmpty) {
      return Center(child: Text(l10n.dev_noPlayers));
    }

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _playersTableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPlayersHeaderRow(l10n),
              const Divider(height: 1),
              for (final entry in data.players)
                _buildPlayerRow(context, l10n, entry),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersHeaderRow(AppLocalizations l10n) {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: _colNameWidth,
            child: Text(l10n.dev_colName, style: headerStyle),
          ),
          SizedBox(
            width: _colAgeWidth,
            child: Text(
              l10n.dev_colAge,
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
          SizedBox(
            width: _colPositionWidth,
            child: Text(
              l10n.dev_colPosition,
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
          SizedBox(
            width: _colOvrWidth,
            child: Text(
              l10n.dev_colOvr,
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
          SizedBox(
            width: _colOvrDeltaWidth,
            child: Text(
              l10n.dev_colChange,
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
          SizedBox(
            width: _colPotentialWidth,
            child: Text(
              l10n.dev_colPotential,
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
          SizedBox(
            width: _colPotentialDeltaWidth,
            child: Text(
              l10n.dev_colChange,
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(
    BuildContext context,
    AppLocalizations l10n,
    PlayerDevEntry entry,
  ) {
    final player = entry.player;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/game/player/${player.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: [
              SizedBox(
                width: _colNameWidth,
                child: Text(
                  player.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(
                width: _colAgeWidth,
                child: Text(
                  '${player.age}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(
                width: _colPositionWidth,
                child: Text(
                  player.position.code,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(
                width: _colOvrWidth,
                child: Text(
                  '${roundedOvrForDisplay(player.overall())}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(
                width: _colOvrDeltaWidth,
                child: _buildIntDeltaText(context, entry.ovrDelta),
              ),
              SizedBox(
                width: _colPotentialWidth,
                child: PotentialStars(
                  playerId: player.id,
                  stars: displayedPotentialStars(player.potentialStars),
                  color: potentialStarColor(player.age),
                  l10n: l10n,
                ),
              ),
              SizedBox(
                width: _colPotentialDeltaWidth,
                child: _buildDoubleDeltaText(context, entry.potentialDelta),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Staff tab -------------------------------------------------------------

  Widget _buildStaffTab(
    BuildContext context,
    AppLocalizations l10n,
    DevelopmentData data,
  ) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final entry in data.staff)
          _buildStaffRolePair(context, l10n, entry),
      ],
    );
  }

  Widget _buildStaffRolePair(
    BuildContext context,
    AppLocalizations l10n,
    StaffDevEntry entry,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStaffHeaderRow(l10n, entry),
            const Divider(height: 8),
            _buildStaffDataRow(context, l10n, entry),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffHeaderRow(AppLocalizations l10n, StaffDevEntry entry) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            _roleLabel(l10n, entry.role),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            l10n.dev_colAge,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        for (final attr in entry.attributeNames) ...[
          SizedBox(
            width: _staffAttrValueWidth,
            child: Text(
              _staffAttrLabel(l10n, attr),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: _staffAttrDeltaWidth,
            child: Text(
              l10n.dev_colChange,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStaffDataRow(
    BuildContext context,
    AppLocalizations l10n,
    StaffDevEntry entry,
  ) {
    final member = entry.member;

    if (member == null) {
      return Row(
        children: [
          Expanded(flex: 3, child: Text(l10n.dev_vacant)),
          const SizedBox(
            width: 40,
            child: Text('-', textAlign: TextAlign.center),
          ),
          for (var i = 0; i < entry.attributeNames.length; i++) ...[
            SizedBox(
              width: _staffAttrValueWidth,
              child: const Text('-', textAlign: TextAlign.center),
            ),
            SizedBox(width: _staffAttrDeltaWidth),
          ],
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 3, child: Text(member.name)),
        SizedBox(
          width: 40,
          child: Text(member.age.toString(), textAlign: TextAlign.center),
        ),
        for (var i = 0; i < entry.attributeNames.length; i++) ...[
          SizedBox(
            width: _staffAttrValueWidth,
            child: _buildAttributeStars(context, entry.currentValues[i]),
          ),
          SizedBox(
            width: _staffAttrDeltaWidth,
            child: _buildNullableDoubleDeltaText(context, entry.deltas[i]),
          ),
        ],
      ],
    );
  }

  /// Renders [value] (0-[_staffAttrMax]) as a row of [_staffAttrStarCount]
  /// full/half/empty stars, matching the rounding granularity already used
  /// for player potential (half-star steps).
  Widget _buildAttributeStars(BuildContext context, double value) {
    final ratio = (value / _staffAttrMax).clamp(0.0, 1.0);
    final filled = ratio * _staffAttrStarCount;
    final color = Theme.of(context).colorScheme.tertiary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _staffAttrStarCount; i++)
          Icon(_starIconFor(filled - i), size: 12, color: color),
      ],
    );
  }

  IconData _starIconFor(double remainder) {
    if (remainder >= 1.0) return Icons.star;
    if (remainder >= 0.5) return Icons.star_half;
    return Icons.star_border;
  }

  // --- Shared delta formatting -----------------------------------------------

  /// Color for a delta value: green when positive, red when negative, and the
  /// theme's normal body text color when there is no change.
  Color? _deltaColor(BuildContext context, num delta) {
    if (delta > 0) return Colors.green;
    if (delta < 0) return Colors.red;
    return Theme.of(context).textTheme.bodySmall?.color;
  }

  Widget _buildIntDeltaText(BuildContext context, int delta) {
    final text = delta > 0 ? '+$delta' : '$delta';
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: _deltaColor(context, delta)),
    );
  }

  /// As [_buildDoubleDeltaText], but `null` (no previous snapshot to compare
  /// against) renders nothing rather than "0" — that case means "unknown",
  /// not "no change".
  Widget _buildNullableDoubleDeltaText(BuildContext context, double? delta) {
    //if (delta == null) return const SizedBox.shrink();
    return _buildDoubleDeltaText(context, delta ?? 0);
  }

  Widget _buildDoubleDeltaText(BuildContext context, double delta) {
    final String text;
    if (delta > 0) {
      text = '+${delta.toStringAsFixed(1)}';
    } else if (delta < 0) {
      text = delta.toStringAsFixed(1);
    } else {
      text = '0';
    }
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: _deltaColor(context, delta)),
    );
  }
}

String _staffAttrLabel(AppLocalizations l10n, String attrName) =>
    switch (attrName) {
      'tactics' => l10n.staffAttr_tactics,
      'motivation' => l10n.staffAttr_motivation,
      'development' => l10n.staffAttr_development,
      'mentoring' => l10n.staffAttr_mentoring,
      'coverage' => l10n.staffAttr_coverage,
      'evaluation' => l10n.staffAttr_evaluation,
      'rehabilitation' => l10n.staffAttr_rehabilitation,
      'regenaration' => l10n.staffAttr_regenaration,
      'prevention' => l10n.staffAttr_prevention,
      'care' => l10n.staffAttr_care,
      'negotiation' => l10n.staffAttr_negotiation,
      _ => attrName,
    };

String _roleLabel(AppLocalizations l10n, StaffRole role) => switch (role) {
  StaffRole.headCoach => l10n.staffRole_headCoach,
  StaffRole.youthCoach => l10n.staffRole_youthCoach,
  StaffRole.scout => l10n.staffRole_scout,
  StaffRole.physio => l10n.staffRole_physio,
  StaffRole.doctor => l10n.staffRole_doctor,
  StaffRole.cfo => l10n.staffRole_cfo,
};
