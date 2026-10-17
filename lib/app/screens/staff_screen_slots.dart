part of 'staff_screen.dart';

mixin _StaffScreenSlots on ConsumerState<StaffScreen>, _StaffScreenShared {
  Widget _roleSection(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    StaffRole role,
  ) {
    final member = team.staff.member(role);
    final memberView = StaffPresentation.viewForSlot(member, role);
    final candidates = StaffPresentation.sortStaffCandidates(
      league.canonicalStaffFreeAgents,
      role,
    );
    final memberIsOccupied = memberView.isOccupied;
    final memberCanExtend =
        memberIsOccupied &&
        member != null &&
        (member.contract?.yearsRemaining ?? 99) <= 1;
    final memberCanFire =
        memberIsOccupied && member != null && _canFire(member);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              staffRoleLabel(context, role),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            if (member == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.staff_emptySlot),
                  StaffRatingStars(
                    key: ValueKey<String>('staff-slot-rating-${role.name}'),
                    slot: memberView,
                    keyPrefix: 'staff-slot-rating-${role.name}',
                  ),
                ],
              )
            else if (!memberIsOccupied)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('—'),
                  StaffRatingStars(
                    key: ValueKey<String>('staff-slot-rating-${role.name}'),
                    slot: memberView,
                    keyPrefix: 'staff-slot-rating-${role.name}',
                  ),
                ],
              )
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(member.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${member.age} · ${formatMoney(context, member.contract?.salary ?? 0)}',
                    ),
                    StaffRatingStars(
                      key: ValueKey<String>('staff-member-rating-${member.id}'),
                      slot: memberView,
                      keyPrefix: 'staff-member-rating-${member.id}',
                    ),
                    Text(
                      member.contract == null ||
                              member.contract!.yearsRemaining <= 0
                          ? l10n.staff_contractExpired
                          : l10n.staff_contractRemaining(
                              member.contract!.yearsRemaining,
                            ),
                    ),
                  ],
                ),
                onTap: () => _selectStaff(league, team, member, true),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    if (memberCanExtend)
                      TextButton(
                        onPressed: () => _submitDefaultOffer(
                          l10n,
                          league,
                          team,
                          member,
                          true,
                        ),
                        child: Text(l10n.contract_submitOffer),
                      ),
                    if (memberCanFire)
                      TextButton(
                        onPressed: () => _fire(l10n, role),
                        child: Text(l10n.staff_fire),
                      )
                    else
                      Tooltip(
                        message: l10n.staff_fireDisabled,
                        child: Text(
                          l10n.staff_fire,
                          style: TextStyle(
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (member == null) ...[
              const SizedBox(height: 6),
              Text(
                l10n.staff_candidatesHeader,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (candidates.isEmpty)
                Text(l10n.staff_noCandidates)
              else
                ...candidates.map((candidate) {
                  final offer = _defaultOffer(league, candidate);
                  final candidateView = StaffPresentation.viewForMember(
                    candidate,
                  );
                  final canHire =
                      _canSubmitStaffOffer(
                        league,
                        team,
                        candidate,
                        isExtension: false,
                      ) &&
                      _offerValidationError(
                            l10n,
                            team,
                            candidate,
                            offer,
                            isExtension: false,
                          ) ==
                          null;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(candidate.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${candidate.age} · ${formatMoney(context, offer.salary)}',
                        ),
                        StaffRatingStars(
                          key: ValueKey<String>(
                            'staff-candidate-rating-${candidate.id}',
                          ),
                          slot: candidateView,
                          keyPrefix: 'staff-candidate-rating-${candidate.id}',
                        ),
                      ],
                    ),
                    onTap: () => _selectStaff(league, team, candidate, false),
                    trailing: FilledButton.tonal(
                      onPressed: canHire
                          ? () => _submitStaffOffer(
                              l10n,
                              league,
                              team,
                              candidate,
                              false,
                              offer,
                            )
                          : null,
                      child: Text(l10n.staff_hire),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

  @override
  List<StaffAttributeView> _attributes(StaffSlotView view) =>
      view.relevantAttributes;

  @override
  String _attributeLabel(AppLocalizations l10n, StaffAttributeKey key) =>
      switch (key) {
        StaffAttributeKey.tactics => l10n.staff_attrTactics,
        StaffAttributeKey.motivation => l10n.staff_attrMotivation,
        StaffAttributeKey.development => l10n.staff_attrDevelopment,
        StaffAttributeKey.mentoring => l10n.staff_attrMentoring,
        StaffAttributeKey.coverage => l10n.staff_attrCoverage,
        StaffAttributeKey.evaluation => l10n.staff_attrEvaluation,
        StaffAttributeKey.rehabilitation => l10n.staff_attrRehabilitation,
        StaffAttributeKey.regenaration => l10n.staff_attrRegeneration,
        StaffAttributeKey.prevention => l10n.staff_attrPrevention,
        StaffAttributeKey.care => l10n.staff_attrCare,
        StaffAttributeKey.negotiation => l10n.staff_attrNegotiation,
      };
}
