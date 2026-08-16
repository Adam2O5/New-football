import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/tactics/position_group.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

Future<void> showSubstituteSheet(
  BuildContext context, {
  required AppLocalizations l10n,
  required Player outPlayer,
  required List<Player> candidates,
  required ValueChanged<Player> onSelected,
}) {
  final preferredGroup = substituteGroupOf(outPlayer.position);
  final sorted = [...candidates]
    ..sort((a, b) {
      final aMatches = substituteGroupOf(a.position) == preferredGroup;
      final bMatches = substituteGroupOf(b.position) == preferredGroup;
      if (aMatches != bMatches) return aMatches ? -1 : 1;
      return b.overall().compareTo(a.overall());
    });

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SubstituteSheet(
      l10n: l10n,
      outPlayer: outPlayer,
      candidates: sorted,
      preferredGroup: preferredGroup,
      onSelected: onSelected,
    ),
  );
}

class SubstituteSheet extends StatelessWidget {
  const SubstituteSheet({
    super.key,
    required this.l10n,
    required this.outPlayer,
    required this.candidates,
    required this.preferredGroup,
    required this.onSelected,
  });

  final AppLocalizations l10n;
  final Player outPlayer;
  final List<Player> candidates;
  final SubstituteGroup preferredGroup;
  final ValueChanged<Player> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(
                outPlayer.position.code,
                style: const TextStyle(fontSize: 11),
              ),
            ),
            title: Text(l10n.substitute_sheetTitle(outPlayer.name)),
            subtitle: Text(l10n.substitute_sheetSubtitle),
          ),
          const Divider(height: 1),
          if (candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.substitute_sheetEmpty),
            ),
          for (final candidate in candidates)
            ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    substituteGroupOf(candidate.position) == preferredGroup
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: Text(
                  candidate.position.code,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              title: Text(candidate.name),
              subtitle: Text(
                '${l10n.stat_ovr} ${candidate.overall().round()} '
                '· ${l10n.stat_form} ${candidate.state.form}'
                '${candidate.state.injured ? ' · ${l10n.squad_injury}' : ''}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => context.push('/game/player/${candidate.id}'),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onSelected(candidate);
              },
            ),
        ],
      ),
    );
  }
}
