part of 'matchday_screen.dart';

class _AutoPauseConfig {
  const _AutoPauseConfig({
    this.injury = true,
    this.redCard = true,
    this.halfTime = true,
    this.penaltyForUs = true,
  });

  final bool injury;
  final bool redCard;
  final bool halfTime;
  final bool penaltyForUs;

  _AutoPauseConfig copyWith({
    bool? injury,
    bool? redCard,
    bool? halfTime,
    bool? penaltyForUs,
  }) => _AutoPauseConfig(
    injury: injury ?? this.injury,
    redCard: redCard ?? this.redCard,
    halfTime: halfTime ?? this.halfTime,
    penaltyForUs: penaltyForUs ?? this.penaltyForUs,
  );
}

class _AutoPauseSheet extends StatefulWidget {
  const _AutoPauseSheet({required this.initial});

  final _AutoPauseConfig initial;

  @override
  State<_AutoPauseSheet> createState() => _AutoPauseSheetState();
}

class _AutoPauseSheetState extends State<_AutoPauseSheet> {
  late _AutoPauseConfig _config = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.matchday_autoPauseTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SwitchListTile(
              title: Text(l10n.matchday_autoPauseInjury),
              value: _config.injury,
              onChanged: (value) =>
                  setState(() => _config = _config.copyWith(injury: value)),
            ),
            SwitchListTile(
              title: Text(l10n.matchday_autoPauseRed),
              value: _config.redCard,
              onChanged: (value) =>
                  setState(() => _config = _config.copyWith(redCard: value)),
            ),
            SwitchListTile(
              title: Text(l10n.matchday_autoPauseHalfTime),
              value: _config.halfTime,
              onChanged: (value) =>
                  setState(() => _config = _config.copyWith(halfTime: value)),
            ),
            SwitchListTile(
              title: Text(l10n.matchday_autoPausePenalty),
              subtitle: Text(l10n.matchday_penaltyPauseUnavailable),
              value: _config.penaltyForUs,
              onChanged: (value) => setState(
                () => _config = _config.copyWith(penaltyForUs: value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_config),
                child: Text(l10n.common_save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
