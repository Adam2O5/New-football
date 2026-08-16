import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/development_provider.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:go_router/go_router.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class DevelopmentScreen extends ConsumerStatefulWidget {
  const DevelopmentScreen({super.key});

  @override
  ConsumerState<DevelopmentScreen> createState() => _DevelopmentScreenState();
}

class _DevelopmentScreenState extends ConsumerState<DevelopmentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dev_title),
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
              color: Theme.of(context).colorScheme.surface,
              child: TabBar(
                controller: _tabController,
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

  Widget _buildPlayersTab(
    BuildContext context,
    AppLocalizations l10n,
    DevelopmentData data,
  ) {
    if (data.players.isEmpty) {
      return Center(child: Text(l10n.dev_noPlayers));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: data.players.length,
      itemBuilder: (context, index) {
        final entry = data.players[index];
        final player = entry.player;
        final ovrDelta = entry.ovrDelta;
        final weeklyOvrDelta = entry.weeklyOvrDelta;
        final potDelta = entry.potentialDelta;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${l10n.dev_progress}: ${entry.progress.toStringAsFixed(1)}% '
                      '${_progressDirection(entry.progressDirection)} '
                      '${entry.progressDelta >= 0 ? '+' : ''}${entry.progressDelta.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  player.position.code,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '${player.age}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  player.potentialStars.toStringAsFixed(1),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  ovrDelta > 0 ? '+$ovrDelta' : '$ovrDelta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ovrDelta > 0
                        ? Colors.green
                        : ovrDelta < 0
                        ? Colors.red
                        : null,
                  ),
                ),
              ),
              SizedBox(
                width: 42,
                child: Text(
                  weeklyOvrDelta > 0 ? '+$weeklyOvrDelta' : '$weeklyOvrDelta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: weeklyOvrDelta > 0
                        ? Colors.green
                        : weeklyOvrDelta < 0
                        ? Colors.red
                        : null,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: potDelta != 0.0
                    ? Text(
                        potDelta > 0
                            ? '+${potDelta.toStringAsFixed(1)}'
                            : potDelta.toStringAsFixed(1),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: potDelta > 0 ? Colors.green : Colors.red,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

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
            width: 56,
            child: Text(
              _staffAttrLabel(l10n, attr),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 40,
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
            const SizedBox(
              width: 56,
              child: Text('-', textAlign: TextAlign.center),
            ),
            const SizedBox(width: 40),
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
            width: 56,
            child: Text(
              entry.currentValues[i].toStringAsFixed(1),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 40,
            child: _buildGrowthDelta(context, entry.deltas[i]),
          ),
        ],
      ],
    );
  }

  Widget _buildGrowthDelta(BuildContext context, double? delta) {
    if (delta == null) return const SizedBox.shrink();

    String text;
    Color? color;

    if (delta > 0) {
      text = '+${delta.toStringAsFixed(1)}';
      color = Colors.green;
    } else if (delta < 0) {
      text = delta.toStringAsFixed(1);
      color = Colors.red;
    } else {
      text = '0';
      color = Theme.of(context).textTheme.bodyMedium?.color;
    }

    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: color, fontSize: 12),
    );
  }
}

String _progressDirection(int direction) => switch (direction) {
  1 => '↑',
  -1 => '↓',
  _ => '→',
};

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
