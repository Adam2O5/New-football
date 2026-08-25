import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/widgets/team_selection/team_row.dart';
import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class NewGameScreen extends ConsumerStatefulWidget {
  const NewGameScreen({super.key});

  @override
  ConsumerState<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends ConsumerState<NewGameScreen> {
  final _nameCtrl = TextEditingController();
  String? _selectedTeamId;
  bool _creating = false;
  bool _nameInitialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _create(AppLocalizations l10n) async {
    final teamId = _selectedTeamId;
    final name = _nameCtrl.text.trim();
    if (teamId == null || name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.newGame_missingFields)));
      return;
    }
    setState(() => _creating = true);
    await ref
        .read(gameControllerProvider.notifier)
        .createNewGame(NewGameRequest(saveName: name, playerTeamId: teamId));
    if (!mounted) return;
    setState(() => _creating = false);
    final err = ref.read(gameControllerProvider).hasError;
    if (err) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.newGame_createFailed)));
      return;
    }
    context.go('/game');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_nameInitialized) {
      _nameCtrl.text = l10n.newGame_defaultSaveName;
      _nameInitialized = true;
    }
    final teams = ref.watch(gameFactoryProvider).previewTeams();
    final brandingRegistry = ref.watch(clubBrandingProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newGame_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ScreenBackground(
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const ValueKey('new-game-save-name'),
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.newGame_saveName,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.newGame_chooseTeam,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      key: const ValueKey('new-game-team-list'),
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        final selected = team.id == _selectedTeamId;
                        final selectionState = selected
                            ? l10n.newGame_teamSelected
                            : l10n.newGame_teamNotSelected;
                        final conferenceLabel = switch (team.conference) {
                          Conference.europe =>
                            l10n.teamOverview_conferenceEurope,
                          Conference.restOfTheWorld =>
                            l10n.teamOverview_conferenceRestOfWorld,
                        };
                        return TeamRow(
                          key: ValueKey('new-game-team-row-${team.id}'),
                          teamId: team.id,
                          name: team.name,
                          city: team.city,
                          conferenceLabel: conferenceLabel,
                          branding: brandingRegistry.resolve(team.id),
                          selected: selected,
                          localizedSemanticsLabel: l10n.newGame_teamSemantics(
                            team.name,
                            team.city,
                            conferenceLabel,
                            selectionState,
                          ),
                          onActivate: () =>
                              setState(() => _selectedTeamId = team.id),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    key: const ValueKey('new-game-fixed-action'),
                    width: double.infinity,
                    child: FilledButton(
                      key: const ValueKey('new-game-start-button'),
                      onPressed: _creating ? null : () => _create(l10n),
                      child: _creating
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.newGame_start),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
