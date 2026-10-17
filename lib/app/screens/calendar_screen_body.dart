part of 'calendar_screen.dart';

mixin _CalendarScreenBody
    on ConsumerState<CalendarScreen>, _CalendarScreenShared {
  static const _progressOverlayKey = ValueKey<String>(
    'calendar-batch-progress-overlay',
  );
  static const _cancelButtonKey = ValueKey<String>('calendar-batch-cancel');
  static const _feedbackHostKey = ValueKey<String>(
    'calendar-day-result-feedback-host',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Center(child: Text(l10n.calendar_noLeague));
    }

    final calendar = ref.watch(calendarServiceProvider);
    final week = league.currentWeek;
    final day = league.currentDay;
    final seasonYear = league.currentSeason.year;

    final currentMonth = _monthForInGame(league);
    final cursorMonthValue = ref.watch(calendarCursorMonthProvider);
    if (cursorMonthValue == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ref.read(calendarCursorMonthProvider.notifier).state = currentMonth;
      });
    }
    final month = cursorMonthValue ?? currentMonth;
    final firstSeasonYear = league.history.isNotEmpty
        ? league.history.map((h) => h.year).reduce((a, b) => a < b ? a : b)
        : seasonYear;
    final minMonthDate = _week1StartForSeason(firstSeasonYear);
    final minMonth = DateTime(minMonthDate.year, minMonthDate.month);
    final maxMonth = DateTime(currentMonth.year, currentMonth.month + 12);

    final playerId = league.playerTeamId;
    final currentWeek = week;
    final currentDay = day;

    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = monthEnd.day;
    final leading = monthStart.weekday - 1; // Mon=1 → leading 0
    final totalCells = ((leading + daysInMonth + 6) ~/ 7) * 7;
    final gridStart = monthStart.subtract(Duration(days: leading));

    final teamNameById = {for (final t in league.teams) t.id: t.name};
    final matchesByRound = <int, List<ScheduledMatch>>{};
    for (final m in league.currentSeason.schedule) {
      matchesByRound.putIfAbsent(m.round, () => []).add(m);
    }

    ({
      int week,
      int day,
      bool isPast,
      int matchCount,
      int? round,
      String? playerMatchLabel,
      ScheduledMatch? playerMatch,
      List<String> eventLabels,
    })?
    dayInfo(DateTime date) {
      final mapped = _inGameWeekDayForDate(date, seasonYear);
      if (mapped == null) return null;
      final w = mapped.week;
      final d = mapped.day;
      final isPast = w < currentWeek || (w == currentWeek && d < currentDay);

      var matchCount = 0;
      int? round;
      String? playerMatchLabel;
      ScheduledMatch? pm;

      final slot = calendar.regularSeasonSlotForDay(d);
      final isActualMatchDay = slot != null && calendar.isActualMatchDay(w, d);

      if (calendar.isRegularSeasonWeek(w) && slot != null && isActualMatchDay) {
        round = scheduleRoundForWeekSlot(w, slot);
        final fixtures = matchesByRound[round] ?? const [];
        matchCount = fixtures.length;

        if (playerId != null) {
          for (final f in fixtures) {
            if (f.homeTeamId == playerId || f.awayTeamId == playerId) {
              pm = f;
              break;
            }
          }
          if (pm != null) {
            final home = teamNameById[pm.homeTeamId] ?? pm.homeTeamId;
            final away = teamNameById[pm.awayTeamId] ?? pm.awayTeamId;
            final score = pm.result != null
                ? ' ${_formatMatchScore(pm.result!)}'
                : '';
            playerMatchLabel = '$home – $away$score';
          }
        }
      } else {
        // Play-in/playoff fixtures aren't part of `schedule` — they live in
        // `postseasonFixtures`, written eagerly as soon as each pairing is
        // known (see `game_calendar.md`), so — unlike the regular season
        // branch above — no "today or earlier" gating is needed here: a
        // fixture simply isn't in the list yet if it isn't known yet.
        //
        // Unlike the regular season (where every team plays every match
        // day), most teams aren't in the play-in/playoff at all — so, unless
        // the player's own team has a fixture today, no icon is shown.
        if (playerId != null) {
          for (final f in league.currentSeason.postseasonFixtures) {
            if (f.week != w || f.day != d) continue;
            final isPlayerSide =
                f.homeTeamId == playerId || f.awayTeamId == playerId;
            final isPendingPlayInFinal =
                f.id.startsWith('playIn:') &&
                f.id.endsWith(':final') &&
                !f.confirmed &&
                _isPlayerInPlayInConference(
                  league,
                  f.id.split(':')[1],
                  playerId,
                );
            if (isPlayerSide || isPendingPlayInFinal) {
              pm = f;
              break;
            }
          }
          if (pm != null) {
            matchCount = 1;
            final home =
                pm.homePlaceholderLabel ??
                teamNameById[pm.homeTeamId] ??
                pm.homeTeamId;
            final away =
                pm.awayPlaceholderLabel ??
                teamNameById[pm.awayTeamId] ??
                pm.awayTeamId;
            final score = pm.result != null
                ? ' ${_formatMatchScore(pm.result!)}'
                : '';
            playerMatchLabel = '$home – $away$score';
          }
        }
      }

      final eventLabels = <String>[];
      for (final e in calendar.eventsOn(w, d)) {
        if (e.id == CalendarEventId.draft) {
          final draft = league.currentSeason.draftState;
          if (draft != null && draft.order.isNotEmpty) {
            final total = draft.order.length;
            final currentPick = (draft.currentPickIndex + 1).clamp(1, total);
            eventLabels.add(
              '${l10n.calendar_event_draft} · ${l10n.calendar_pickProgress(currentPick, total)}',
            );
          } else {
            eventLabels.add(l10n.calendar_event_draft);
          }
          continue;
        }
        final label = calendarEventLabel(context, e.id);
        if (label != null) eventLabels.add(label);
      }

      return (
        week: w,
        day: d,
        isPast: isPast,
        matchCount: matchCount,
        round: round,
        playerMatchLabel: playerMatchLabel,
        playerMatch: pm,
        eventLabels: eventLabels,
      );
    }

    final selectedDay =
        ref.watch(calendarSelectedDayProvider) ??
        _dateForInGameWeekDay(seasonYear, currentWeek, currentDay);
    final selectedInfo = dayInfo(selectedDay);

    String selectedDayBody;
    final selectedMatch = selectedInfo?.playerMatch;
    if (selectedMatch != null) {
      final homeName =
          teamNameById[selectedMatch.homeTeamId] ?? selectedMatch.homeTeamId;
      final awayName =
          teamNameById[selectedMatch.awayTeamId] ?? selectedMatch.awayTeamId;
      final isPlayerHome = selectedMatch.homeTeamId == playerId;
      final opponentName = isPlayerHome ? awayName : homeName;
      if (selectedMatch.result != null) {
        selectedDayBody = l10n.calendar_selectedDay_matchResult(
          homeName,
          awayName,
          selectedMatch.result!.homeGoals,
          selectedMatch.result!.awayGoals,
        );
      } else {
        selectedDayBody = l10n.calendar_selectedDay_matchUpcoming(opponentName);
      }
    } else if (selectedInfo != null && selectedInfo.eventLabels.isNotEmpty) {
      selectedDayBody = l10n.calendar_selectedDay_offseasonEvent(
        selectedInfo.eventLabels.join(', '),
      );
    } else {
      selectedDayBody = l10n.calendar_selectedDay_noEvent;
    }

    final canSimulateSelectedDay = selectedInfo != null && !selectedInfo.isPast;

    return Scaffold(
      body: Stack(
        children: [
          ScreenBackground(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: month.isAfter(minMonth)
                                  ? () {
                                      ref
                                          .read(
                                            calendarCursorMonthProvider
                                                .notifier,
                                          )
                                          .state = DateTime(
                                        month.year,
                                        month.month - 1,
                                        1,
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Expanded(
                              child: Text(
                                MaterialLocalizations.of(
                                  context,
                                ).formatMonthYear(month),
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              onPressed: month.isBefore(maxMonth)
                                  ? () {
                                      ref
                                          .read(
                                            calendarCursorMonthProvider
                                                .notifier,
                                          )
                                          .state = DateTime(
                                        month.year,
                                        month.month + 1,
                                        1,
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.calendar_selectedDay_title} · ${dayName(context, selectedDay.weekday)} ${selectedDay.day}.${selectedDay.month.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                selectedDayBody,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, gridConstraints) {
                            // Grid dimensions are logical Flutter constraints. Do
                            // not use devicePixelRatio here: the seven-column
                            // geometry must be identical at every pixel density.
                            final logicalWidth = gridConstraints.hasBoundedWidth
                                ? gridConstraints.maxWidth
                                : MediaQuery.sizeOf(context).width;
                            final logicalHeight =
                                gridConstraints.hasBoundedHeight
                                ? gridConstraints.maxHeight
                                : MediaQuery.sizeOf(context).height;
                            final rowCount = (totalCells + 6) ~/ 7;
                            final tileExtent = _calendarTileExtent(
                              logicalWidth: logicalWidth,
                              logicalHeight: logicalHeight,
                              rowCount: rowCount,
                            );

                            return GridView.builder(
                              itemCount: totalCells,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    mainAxisExtent: tileExtent,
                                  ),
                              itemBuilder: (context, i) {
                                final date = gridStart.add(Duration(days: i));
                                final info = dayInfo(date);
                                final isInMonth = date.month == month.month;
                                final isEnabled =
                                    info != null && !info.isPast && isInMonth;
                                final isToday =
                                    info != null &&
                                    info.week == currentWeek &&
                                    info.day == currentDay;
                                final isSelected =
                                    info != null &&
                                    date.year == selectedDay.year &&
                                    date.month == selectedDay.month &&
                                    date.day == selectedDay.day;

                                return CalendarDayTile(
                                  key: ValueKey<DateTime>(date),
                                  date: date,
                                  isInMonth: isInMonth,
                                  isEnabled: isEnabled,
                                  isToday: isToday,
                                  isSelected: isSelected,
                                  matchCount: info?.matchCount ?? 0,
                                  matchConfirmed:
                                      info?.playerMatch?.confirmed ?? true,
                                  playerMatchLabel: info?.playerMatchLabel,
                                  eventLabels: info?.eventLabels ?? const [],
                                  onTap: info != null
                                      ? () {
                                          ref
                                                  .read(
                                                    calendarSelectedDayProvider
                                                        .notifier,
                                                  )
                                                  .state =
                                              date;
                                        }
                                      : null,
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: canSimulateSelectedDay && !_isSimulating
                                ? () => _simulateToDate(
                                    selectedInfo.week,
                                    selectedInfo.day,
                                  )
                                : null,
                            icon: const Icon(Icons.fast_forward),
                            label: Text(l10n.calendar_simulateUntilDate),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // The progress host is inserted before the feedback host. The
          // feedback is intentionally above the dimming layer, while
          // IgnorePointer keeps it non-blocking and leaves Cancel usable.
          if (_isSimulating)
            Positioned.fill(
              key: _progressOverlayKey,
              child: Stack(
                children: [
                  const ModalBarrier(dismissible: false, color: Colors.black54),
                  Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(child: Text(l10n.calendar_simulating)),
                              const SizedBox(width: 8),
                              TextButton(
                                key: _cancelButtonKey,
                                onPressed: _activeController?.cancelSimulation,
                                child: Text(l10n.calendar_cancel),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_feedback != null && _feedback!.results.isNotEmpty)
            Positioned.fill(
              key: _feedbackHostKey,
              child: IgnorePointer(
                child: CalendarDayResultPopup(
                  feedback: _feedback!,
                  teamId: playerId,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
