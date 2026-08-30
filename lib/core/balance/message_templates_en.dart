import 'package:new_football/core/balance/message_templates_pl.dart';

class MessageTemplatesEn {
  static const Map<String, MessageTextTemplate> templates = {
    'msg_walkover_title': MessageTextTemplate(
      key: 'msg_walkover_title',
      title: 'Risk of Forfeit',
      body:
          'You cannot field a legal squad for the match. Reason: {reason}. '
          'Complete your lineup before facing {opponentName} to avoid a '
          'forfeit.',
    ),
    'msg_lineupNoGk_title': MessageTextTemplate(
      key: 'msg_lineupNoGk_title',
      title: 'No Goalkeeper in the Lineup',
      body:
          'Your current lineup for the match against {opponentName} does '
          'not include an available goalkeeper. Set at least one fit '
          'goalkeeper in the starting eleven or on the bench.',
    ),
    'msg_benchIncomplete_title': MessageTextTemplate(
      key: 'msg_benchIncomplete_title',
      title: 'Incomplete Bench',
      body:
          'Your bench for the match against {opponentName} is incomplete. '
          'You have only {currentBenchCount} of the {requiredBenchCount} '
          'required spots filled.',
    ),
    'msg_suspensionStart_title': MessageTextTemplate(
      key: 'msg_suspensionStart_title',
      title: 'Player Suspended',
      body:
          '{playerName} has been suspended for {matches} match(es). Reason: '
          '{reason}.',
    ),
    'msg_suspensionEnd_title': MessageTextTemplate(
      key: 'msg_suspensionEnd_title',
      title: 'Suspension Over',
      body: '{playerName} has served their suspension and is available again.',
    ),
    'msg_injury_title': MessageTextTemplate(
      key: 'msg_injury_title',
      title: 'Player Injury',
      body:
          '{playerName} has suffered an injury: {injuryName}. Expected '
          'recovery time: {recoveryTime} days. Medical status: {severity}.',
    ),
    'msg_injuryReturn_title': MessageTextTemplate(
      key: 'msg_injuryReturn_title',
      title: 'Return from Injury',
      body:
          '{playerName} has completed rehabilitation from {injuryName} and '
          'can return to training and matchday squads.',
    ),
    'msg_injuryRecurrence_title': MessageTextTemplate(
      key: 'msg_injuryRecurrence_title',
      title: 'Injury Recurrence',
      body:
          '{playerName} has suffered a recurrence of {injuryName}. The new '
          'expected recovery time is {recoveryTime} days.',
    ),
    'msg_potentialLoss_title': MessageTextTemplate(
      key: 'msg_potentialLoss_title',
      title: 'Potential Decline',
      body:
          '{playerName} may lose some development potential as a result of '
          'the injury sustained.',
    ),
    'msg_playerEvent_plateau_title': MessageTextTemplate(
      key: 'msg_playerEvent_plateau_title',
      title: 'Development Plateau',
      body:
          '{playerName} has entered a period of stagnation. Staff suggest '
          'changing the training plan or showing more patience to break '
          'the plateau.',
    ),
    'msg_playerEvent_coldStreak_title': MessageTextTemplate(
      key: 'msg_playerEvent_coldStreak_title',
      title: 'Player in Poor Form',
      body:
          '{playerName} is showing a noticeable drop in form. You can keep '
          'backing them or reduce their role until form improves.',
    ),
    'msg_playerEvent_injuryComplication_title': MessageTextTemplate(
      key: 'msg_playerEvent_injuryComplication_title',
      title: 'Injury Complications',
      body:
          "{playerName}'s recovery is not going smoothly. The decision "
          'concerns the pace of their return and the risk of worsening the '
          'problem.',
    ),
    'msg_playerEvent_veteranMotivation_title': MessageTextTemplate(
      key: 'msg_playerEvent_veteranMotivation_title',
      title: 'Veteran Motivation',
      body:
          '{playerName} expects a clear signal about their role in the '
          'squad. The right response can improve their morale and '
          'commitment.',
    ),
    'msg_playerEvent_extraTraining_title': MessageTextTemplate(
      key: 'msg_playerEvent_extraTraining_title',
      title: 'Extra Training Request',
      body:
          '{playerName} wants to start an additional training cycle. This '
          'could speed up development but also increases physical strain.',
    ),
    'msg_playerEvent_personalSupport_title': MessageTextTemplate(
      key: 'msg_playerEvent_personalSupport_title',
      title: 'Needs Support',
      body:
          '{playerName} is dealing with problems off the pitch and expects '
          'support from the club. Your response may affect morale and '
          'form.',
    ),
    'msg_playerEvent_breakthrough_title': MessageTextTemplate(
      key: 'msg_playerEvent_breakthrough_title',
      title: 'Development Breakthrough',
      body: '{playerName} has taken a clear step forward recently.',
    ),
    'msg_playerEvent_personalProblems_title': MessageTextTemplate(
      key: 'msg_playerEvent_personalProblems_title',
      title: 'Personal Problems',
      body:
          '{playerName} is going through a difficult period outside '
          'football. This may temporarily reduce their focus and match '
          'sharpness.',
    ),
    'msg_playerEvent_lateBloomer_title': MessageTextTemplate(
      key: 'msg_playerEvent_lateBloomer_title',
      title: 'Late Bloomer',
      body:
          '{playerName} is developing better than previously expected. '
          "It's worth reassessing their role and potential in the sporting "
          'project.',
    ),
    'msg_playerEvent_nationalTeam_title': MessageTextTemplate(
      key: 'msg_playerEvent_nationalTeam_title',
      title: 'National Team Call-up',
      body:
          '{playerName} has been called up to the national team. This may '
          "boost the player's prestige but will also increase their "
          'workload.',
    ),
    'msg_playerEvent_inspiredPerformance_title': MessageTextTemplate(
      key: 'msg_playerEvent_inspiredPerformance_title',
      title: 'Player on a Roll',
      body:
          '{playerName} is in excellent form right now. Recent performances '
          "suggest it's worth keeping them in an important role.",
    ),
    'msg_teamEvent_moreMinutesRequest_title': MessageTextTemplate(
      key: 'msg_teamEvent_moreMinutesRequest_title',
      title: 'Request for More Minutes',
      body:
          '{playerName} believes they deserve a bigger role in the team. '
          'They expect a clear statement on playing time and their place '
          'in the rotation.',
    ),
    'msg_teamEvent_transferRequestI_title': MessageTextTemplate(
      key: 'msg_teamEvent_transferRequestI_title',
      title: 'Transfer Request',
      body:
          '{playerName} has asked, for the first time, for permission to '
          'leave the club. Reason: {reason}. Your decision will affect the '
          'atmosphere in the dressing room.',
    ),
    'msg_teamEvent_transferRequestII_title': MessageTextTemplate(
      key: 'msg_teamEvent_transferRequestII_title',
      title: 'Repeated Transfer Request',
      body:
          '{playerName} has repeated their transfer request and expects a '
          'concrete response. Continuing to ignore the situation may '
          'worsen their attitude.',
    ),
    'msg_teamEvent_dressingRoomConflict_title': MessageTextTemplate(
      key: 'msg_teamEvent_dressingRoomConflict_title',
      title: 'Dressing Room Conflict',
      body:
          'A conflict has broken out in the squad between {personA} and '
          '{personB}. Staff are waiting on a decision on whether to '
          'intervene or let the situation die down.',
    ),
    'msg_teamEvent_publicCriticism_title': MessageTextTemplate(
      key: 'msg_teamEvent_publicCriticism_title',
      title: 'Public Criticism',
      body:
          '{playerName} has publicly commented on the situation at the '
          'club. You must decide whether to respond, discipline the '
          'player, or ignore the matter.',
    ),
    'msg_teamEvent_declineToExtend_title': MessageTextTemplate(
      key: 'msg_teamEvent_declineToExtend_title',
      title: 'Unwilling to Extend Contract',
      body:
          '{playerName} is not currently interested in extending their '
          'contract.',
    ),
    'msg_teamEvent_leaderSupport_title': MessageTextTemplate(
      key: 'msg_teamEvent_leaderSupport_title',
      title: "Leader's Support",
      body:
          "{playerName} has publicly backed the staff's decisions and "
          'helped calm tensions in the squad. Team morale may benefit from '
          'this.',
    ),
    'msg_teamEvent_promiseBroken_title': MessageTextTemplate(
      key: 'msg_teamEvent_promiseBroken_title',
      title: 'Broken Promise',
      body:
          'A promise made to {playerName} has not been kept. This may '
          'affect morale, relationships, and their willingness to stay at '
          'the club.',
    ),
    'msg_teamEvent_atmosphereShift_title': MessageTextTemplate(
      key: 'msg_teamEvent_atmosphereShift_title',
      title: 'Team Atmosphere Shift',
      body:
          'There has been a noticeable mood change in the dressing room. '
          "It's worth checking what's behind this shift.",
    ),
    'msg_retirementPlayer_title': MessageTextTemplate(
      key: 'msg_retirementPlayer_title',
      title: 'Player Retiring',
      body:
          '{playerName} has announced their retirement after the '
          '{seasonLabel} season. The club should start planning a '
          'replacement.',
    ),
    'msg_retirementStaff_title': MessageTextTemplate(
      key: 'msg_retirementStaff_title',
      title: 'Staff Member Departing',
      body:
          '{staffName}, serving as {staffRole}, has announced they will '
          "leave after the {seasonLabel} season. It's worth preparing a "
          'succession plan.',
    ),
    'msg_retirementLeagueDigest_digest_title': MessageTextTemplate(
      key: 'msg_retirementLeagueDigest_digest_title',
      title: 'League Retirement Summary',
      body:
          'In week {week}, {count} people across the league announced '
          'their retirement. Check the summary report to assess the '
          'impact on the market.',
    ),
    'msg_rosterWarning_title': MessageTextTemplate(
      key: 'msg_rosterWarning_title',
      title: 'Roster Issue',
      body:
          'Your roster currently does not meet the rules. Detail: '
          '{reason}. Current count: {currentCount}. Required range: '
          '{requiredRange}.',
    ),
    'msg_contractOffer_title': MessageTextTemplate(
      key: 'msg_contractOffer_title',
      title: 'Contract Negotiation Update',
      body:
          'There is new information in the negotiations with '
          '{subjectName}. Check the offer details and decide on next '
          'steps.',
    ),
    'msg_contractOffer_accept_title': MessageTextTemplate(
      key: 'msg_contractOffer_accept_title',
      title: 'Offer Accepted',
      body:
          '{subjectName} has accepted the contract terms. Agreed length: '
          '{years} year(s), salary: {salary}. All that remains is to '
          'finalize the signing.',
    ),
    'msg_contractOffer_reject_title': MessageTextTemplate(
      key: 'msg_contractOffer_reject_title',
      title: 'Offer Rejected',
      body:
          '{subjectName} has rejected your contract proposal. Reason for '
          'rejection: {reason}. You can come back with a new offer.',
    ),
    'msg_contractOffer_hardReject_title': MessageTextTemplate(
      key: 'msg_contractOffer_hardReject_title',
      title: 'Firm Offer Rejection',
      body:
          '{subjectName} has firmly rejected the proposal and does not '
          'want to continue talks right now. Reason: {reason}.',
    ),
    'msg_contractOffer_waiting_title': MessageTextTemplate(
      key: 'msg_contractOffer_waiting_title',
      title: 'Awaiting Decision',
      body:
          '{subjectName} is holding off on responding to the offer. The '
          'player or agent needs more time to assess the market '
          'situation.',
    ),
    'msg_contractOffer_counter_title': MessageTextTemplate(
      key: 'msg_contractOffer_counter_title',
      title: 'Contract Counter-Offer',
      body:
          '{subjectName} has made a counter-offer. Expected length: '
          '{years} year(s), expected salary: {salary}, additional terms: '
          '{extraTerms}.',
    ),
    'msg_contractOffer_rfaQualifyingOffer_title': MessageTextTemplate(
      key: 'msg_contractOffer_rfaQualifyingOffer_title',
      title: 'RFA Qualifying Offer',
      body:
          'You must decide whether to submit a qualifying offer for '
          '{subjectName} before the {extensionWindowEnd} window closes. '
          'Submitting the offer will let you retain control over their '
          'RFA status.',
    ),
    'msg_contractOfferResponse_title': MessageTextTemplate(
      key: 'msg_contractOfferResponse_title',
      title: 'Contract Offer Response',
      body:
          'A new response has been received regarding the offer to '
          '{subjectName}. Check the negotiation details.',
    ),
    'msg_contractOfferResponse_accept_title': MessageTextTemplate(
      key: 'msg_contractOfferResponse_accept_title',
      title: 'Contract Response Accepted',
      body:
          '{subjectName} has accepted the terms presented. You can proceed '
          'to finalize the contract.',
    ),
    'msg_contractOfferResponse_reject_title': MessageTextTemplate(
      key: 'msg_contractOfferResponse_reject_title',
      title: 'Contract Response Rejected',
      body:
          '{subjectName} has rejected the latest proposal. Reason: '
          '{reason}.',
    ),
    'msg_contractOfferResponse_hardReject_title': MessageTextTemplate(
      key: 'msg_contractOfferResponse_hardReject_title',
      title: 'Contract Talks Closed',
      body:
          '{subjectName} is definitively ending the current stage of '
          'negotiations. Further attempts right now are very unlikely to '
          'succeed.',
    ),
    'msg_contractOfferResponse_waiting_title': MessageTextTemplate(
      key: 'msg_contractOfferResponse_waiting_title',
      title: 'Negotiations on Hold',
      body:
          '{subjectName} is still weighing the situation and has not made '
          'a decision. For now, talks remain open.',
    ),
    'msg_contractOfferResponse_counter_title': MessageTextTemplate(
      key: 'msg_contractOfferResponse_counter_title',
      title: 'New Counter-Offer',
      body:
          '{subjectName} has come back with a new proposal: {years} '
          'year(s), {salary}, additional terms: {extraTerms}.',
    ),
    'msg_contractSigned_title': MessageTextTemplate(
      key: 'msg_contractSigned_title',
      title: 'Contract Signed',
      body:
          '{subjectName} has signed a contract with {teamName}. Contract '
          'length: {years} year(s), value: {salary}.',
    ),
    'msg_contractExpiring_player_title': MessageTextTemplate(
      key: 'msg_contractExpiring_player_title',
      title: 'Player Contract Expiring',
      body:
          "{subjectName}'s contract expires after the {seasonLabel} "
          'season. This is a good time to start talks or prepare '
          'alternatives.',
    ),
    'msg_contractExpiring_staff_title': MessageTextTemplate(
      key: 'msg_contractExpiring_staff_title',
      title: 'Staff Contract Expiring',
      body:
          "{subjectName}'s contract as {staffRole} expires after the "
          '{seasonLabel} season. Consider extending it or replacing them.',
    ),
    'msg_contractLostToRival_lostToRival_title': MessageTextTemplate(
      key: 'msg_contractLostToRival_lostToRival_title',
      title: 'Negotiation Target Chose Another Club',
      body:
          '{subjectName} has signed with {winnerTeamName}. Your offer is '
          'no longer valid.',
    ),
    'msg_contractExpired_player_title': MessageTextTemplate(
      key: 'msg_contractExpired_player_title',
      title: 'Contract Expired',
      body:
          "{subjectName}'s contract with {teamName} has expired. The "
          "player's status has changed according to the contract market "
          'rules.',
    ),
    'msg_contractExpired_staff_title': MessageTextTemplate(
      key: 'msg_contractExpired_staff_title',
      title: 'Staff Contract Expired',
      body:
          "{subjectName}'s contract as {staffRole} at {teamName} has come "
          'to an end.',
    ),
    'msg_declineToExtend_title': MessageTextTemplate(
      key: 'msg_declineToExtend_title',
      title: 'Declined to Extend',
      body:
          '{subjectName} does not currently want to discuss a contract '
          'extension. Reason: {reason}.',
    ),
    'msg_rfaOfferSheet_title': MessageTextTemplate(
      key: 'msg_rfaOfferSheet_title',
      title: 'RFA Offer Sheet',
      body:
          '{subjectName} has received an offer sheet from '
          '{rivalTeamName}. You must decide whether to match the offer: '
          '{salary} over {years} year(s).',
    ),
    'msg_staffOfferResponse_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_title',
      title: 'Staff Offer Response',
      body:
          'A response has been received in the negotiations with '
          '{subjectName}. Check the details of the proposal.',
    ),
    'msg_staffOfferResponse_accept_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_accept_title',
      title: 'Staff Accepted the Offer',
      body:
          '{subjectName} has accepted the offer to take on the role of '
          '{staffRole} at your club.',
    ),
    'msg_staffOfferResponse_reject_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_reject_title',
      title: 'Staff Rejected the Offer',
      body:
          '{subjectName} has rejected the job offer for the {staffRole} '
          'position. Reason: {reason}.',
    ),
    'msg_staffOfferResponse_hardReject_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_hardReject_title',
      title: 'Definitive Staff Refusal',
      body:
          '{subjectName} has firmly ended talks and is not interested in '
          'further negotiations.',
    ),
    'msg_staffOfferResponse_waiting_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_waiting_title',
      title: 'Staff Awaiting Decision',
      body:
          '{subjectName} needs more time to weigh the offer and other '
          'options.',
    ),
    'msg_staffOfferResponse_counter_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_counter_title',
      title: 'Staff Counter-Offer',
      body:
          '{subjectName} has sent a counter-offer for the {staffRole} '
          'role. Expected terms: {salary} and {extraTerms}.',
    ),
    'msg_staffOfferResponse_lostToRival_title': MessageTextTemplate(
      key: 'msg_staffOfferResponse_lostToRival_title',
      title: 'Staff Candidate Chose a Rival',
      body:
          '{subjectName} has joined {winnerTeamName}, so talks with your '
          'club have ended.',
    ),
    'msg_staffSigned_title': MessageTextTemplate(
      key: 'msg_staffSigned_title',
      title: 'Staff Member Signed',
      body: '{subjectName} has officially joined {teamName} as {staffRole}.',
    ),
    'msg_staffGrowth_title': MessageTextTemplate(
      key: 'msg_staffGrowth_title',
      title: 'Staff Development',
      body:
          '{subjectName} has improved their competency rating in '
          '{focusArea}. Current growth: {growthValue}.',
    ),
    'msg_staffHired_title': MessageTextTemplate(
      key: 'msg_staffHired_title',
      title: 'New Staff Member',
      body: 'The club has hired {subjectName} as {staffRole}.',
    ),
    'msg_staffFired_title': MessageTextTemplate(
      key: 'msg_staffFired_title',
      title: 'Staff Departure',
      body: '{subjectName} is no longer serving as {staffRole} at {teamName}.',
    ),
    'msg_staffSlotEmpty_title': MessageTextTemplate(
      key: 'msg_staffSlotEmpty_title',
      title: 'Vacant Staff Position',
      body:
          "The {staffRole} position remains unfilled. Lacking this role "
          "may weaken the club's operations.",
    ),
    'msg_trade_title': MessageTextTemplate(
      key: 'msg_trade_title',
      title: 'Trade Update',
      body:
          'There is a new message regarding the trade with '
          '{otherTeamName}.',
    ),
    'msg_tradeOffer_title': MessageTextTemplate(
      key: 'msg_tradeOffer_title',
      title: 'New Trade Offer',
      body:
          '{otherTeamName} has sent a trade offer. Response deadline: '
          '{tradeOfferExpiry}.',
    ),
    'msg_trade_counter_title': MessageTextTemplate(
      key: 'msg_trade_counter_title',
      title: 'Trade Counter-Offer',
      body: '{otherTeamName} has responded with a counter-offer.',
    ),
    'msg_trade_accepted_title': MessageTextTemplate(
      key: 'msg_trade_accepted_title',
      title: 'Trade Accepted',
      body: 'The trade with {otherTeamName} has been accepted.',
    ),
    'msg_trade_rejected_title': MessageTextTemplate(
      key: 'msg_trade_rejected_title',
      title: 'Trade Rejected',
      body: '{otherTeamName} has rejected the trade proposal.',
    ),
    'msg_trade_hardRejected_title': MessageTextTemplate(
      key: 'msg_trade_hardRejected_title',
      title: 'Trade Firmly Rejected',
      body:
          '{otherTeamName} has firmly rejected the trade offer and does '
          'not want to revisit this package in its current form.',
    ),
    'msg_trade_ntcRefusal_title': MessageTextTemplate(
      key: 'msg_trade_ntcRefusal_title',
      title: 'No-Trade Clause Blocked the Trade',
      body:
          '{subjectName} has exercised their no-trade clause and blocked '
          'the trade to {otherTeamName}.',
    ),
    'msg_trade_leagueDigest_title': MessageTextTemplate(
      key: 'msg_trade_leagueDigest_title',
      title: 'League Trade Digest',
      body: 'In week {week}, trades took place across the league.',
    ),
    'msg_tradeWindowEvent_open_title': MessageTextTemplate(
      key: 'msg_tradeWindowEvent_open_title',
      title: 'Trade Window Open',
      body:
          'The trade window has opened. From now on you can start and '
          'finalize trades in line with the rules.',
    ),
    'msg_tradeWindowEvent_deadline_title': MessageTextTemplate(
      key: 'msg_tradeWindowEvent_deadline_title',
      title: 'Trade Deadline',
      body:
          'The trade window closing deadline is approaching or has just '
          'arrived. Make sure to wrap up all active talks before the '
          'deadline.',
    ),
    'msg_lottery_title': MessageTextTemplate(
      key: 'msg_lottery_title',
      title: 'Draft Lottery Results',
      body:
          'The draft lottery has been decided. {teamName} received pick '
          'number {pickNumber}.',
    ),
    'msg_scoutReport_title': MessageTextTemplate(
      key: 'msg_scoutReport_title',
      title: 'Scout Report',
      body:
          'A new scout report is available. Report scope: {summary}. Key '
          'player being watched: {playerName}.',
    ),
    'msg_scoutReport_monthly_title': MessageTextTemplate(
      key: 'msg_scoutReport_monthly_title',
      title: 'Monthly Scout Report',
      body:
          'The scouting staff has prepared a monthly progress summary. '
          'Number of updated profiles: {count}.',
    ),
    'msg_scoutReport_event_title': MessageTextTemplate(
      key: 'msg_scoutReport_event_title',
      title: 'Event Scout Report',
      body:
          'A special scout report has appeared ahead of the draft event. '
          'It contains key information on watched prospects: {summary}.',
    ),
    'msg_combine_title': MessageTextTemplate(
      key: 'msg_combine_title',
      title: 'Combine Results',
      body:
          'Combine test results have been published. Standout prospect: '
          '{playerName}. Key result: {summary}.',
    ),
    'msg_mockDraft_title': MessageTextTemplate(
      key: 'msg_mockDraft_title',
      title: 'New Mock Draft',
      body:
          'An updated draft projection has appeared. Check the predicted '
          'picks and player movements on the boards.',
    ),
    'msg_mockDraft_initial_title': MessageTextTemplate(
      key: 'msg_mockDraft_initial_title',
      title: 'First Mock Draft',
      body:
          'The first mock draft of this cycle has been published. This is '
          'an early picture of the market and prospect rankings.',
    ),
    'msg_mockDraft_final_title': MessageTextTemplate(
      key: 'msg_mockDraft_final_title',
      title: 'Final Mock Draft',
      body:
          "This is the final projection before the draft. It's worth "
          'comparing it with your own board and scout reports.',
    ),
    'msg_draftPick_title': MessageTextTemplate(
      key: 'msg_draftPick_title',
      title: 'Draft Pick Made',
      body:
          'Pick number {pickNumber} has been made in the draft. Player '
          'selected: {playerName}, club: {teamName}.',
    ),
    'msg_draftPick_own_title': MessageTextTemplate(
      key: 'msg_draftPick_own_title',
      title: 'Your Draft Pick',
      body:
          "It's now your turn at pick number {pickNumber}. Time to decide "
          'and select a player from the available board.',
    ),
    'msg_draftPickLeague_league_title': MessageTextTemplate(
      key: 'msg_draftPickLeague_league_title',
      title: 'League Picks',
      body:
          'In round {round}, other clubs have made their picks. Summary '
          'of the key selections: {summary}.',
    ),
    'msg_draftedRightsReminder_title': MessageTextTemplate(
      key: 'msg_draftedRightsReminder_title',
      title: 'Drafted Rights Reminder',
      body:
          'You still hold the rights to {playerName}. Current roster spot '
          'count: {rosterCount}. Check whether you want to sign them now '
          'or keep the rights for later.',
    ),
    'msg_apronWarning_title': MessageTextTemplate(
      key: 'msg_apronWarning_title',
      title: 'Budget Warning',
      body:
          'The club has crossed the {thresholdName} threshold. Current '
          'payroll spending is {currentPayroll}. This may limit the '
          'roster moves available to you.',
    ),
    'msg_capUpdateTv_title': MessageTextTemplate(
      key: 'msg_capUpdateTv_title',
      title: 'Salary Cap Update',
      body:
          "A new TV revenue projection has changed the league's financial "
          'parameters. Updated cap for the {seasonLabel} season: '
          '{newCap}.',
    ),
    'msg_staffCapViolation_title': MessageTextTemplate(
      key: 'msg_staffCapViolation_title',
      title: 'Staff Cost Limit Exceeded',
      body:
          'Staff employment costs exceed the allowed limit. Current '
          'level: {currentValue}, limit: {capValue}.',
    ),
    'msg_award_title': MessageTextTemplate(
      key: 'msg_award_title',
      title: 'Season Award',
      body:
          'A new season award has been given. Winner: {playerName}, club: '
          '{teamName}.',
    ),
    'msg_award_mvp_title': MessageTextTemplate(
      key: 'msg_award_mvp_title',
      title: 'Season MVP',
      body: '{playerName} of {teamName} has won the season MVP award.',
    ),
    'msg_award_roty_title': MessageTextTemplate(
      key: 'msg_award_roty_title',
      title: 'Rookie of the Season',
      body: '{playerName} of {teamName} has been named Rookie of the Season.',
    ),
    'msg_award_dpoy_title': MessageTextTemplate(
      key: 'msg_award_dpoy_title',
      title: 'Defender of the Season',
      body:
          '{playerName} of {teamName} has won the award for best defender '
          'of the season.',
    ),
    'msg_award_coachOfYear_title': MessageTextTemplate(
      key: 'msg_award_coachOfYear_title',
      title: 'Coach of the Year',
      body:
          '{playerName}, associated with {teamName}, has received the '
          'Coach of the Year award.',
    ),
    'msg_award_topScorer_title': MessageTextTemplate(
      key: 'msg_award_topScorer_title',
      title: 'Top Scorer',
      body:
          '{playerName} of {teamName} has finished the season as top '
          'scorer.',
    ),
    'msg_award_topAssist_title': MessageTextTemplate(
      key: 'msg_award_topAssist_title',
      title: 'Assists Leader',
      body:
          '{playerName} of {teamName} recorded the most assists this '
          'season.',
    ),
    'msg_award_bestGk_title': MessageTextTemplate(
      key: 'msg_award_bestGk_title',
      title: 'Best Goalkeeper',
      body:
          "{playerName} of {teamName} has been named the season's best goalkeeper.",
    ),
    'msg_award_teamOfSeason_title': MessageTextTemplate(
      key: 'msg_award_teamOfSeason_title',
      title: 'Team of the Season',
      body: '{playerName} has been named to the Team of the Season.',
    ),
    'msg_award_champion_title': MessageTextTemplate(
      key: 'msg_award_champion_title',
      title: 'League Champion',
      body: '{teamName} has won the league championship.',
    ),
    'msg_atmosphere_title': MessageTextTemplate(
      key: 'msg_atmosphere_title',
      title: 'Team Atmosphere',
      body:
          'A change in atmosphere has been noted in the dressing room. '
          'Current status: {status}. Main reason: {reason}.',
    ),
    'msg_teamStatusChange_title': MessageTextTemplate(
      key: 'msg_teamStatusChange_title',
      title: 'Team Status Change',
      body:
          "The club's sporting or organizational status has changed. New "
          'status: {status}.',
    ),
    'msg_seasonSummary_title': MessageTextTemplate(
      key: 'msg_seasonSummary_title',
      title: 'Season Summary',
      body:
          'The {seasonLabel} season has ended. Team record: {record}. Key '
          'achievements: {summary}.',
    ),
    'msg_playoffMissed_title': MessageTextTemplate(
      key: 'msg_playoffMissed_title',
      title: 'Missed the Playoffs',
      body:
          '{teamName} did not qualify for the playoffs in the '
          '{seasonLabel} season.',
    ),
    'msg_playoffSeeding_title': MessageTextTemplate(
      key: 'msg_playoffSeeding_title',
      title: 'Playoff Seeding Set',
      body:
          'In the {conference} conference, the teams in 7th and 8th place '
          'are {seed7} and {seed8} respectively. The postseason seeding '
          'has been confirmed.',
    ),
    'msg_playInResult_title': MessageTextTemplate(
      key: 'msg_playInResult_title',
      title: 'Play-In Tournament Result',
      body:
          'In the {conference} conference, the advancement spots were '
          'secured by {seed7} and {seed8}.',
    ),
    'msg_calendar_title': MessageTextTemplate(
      key: 'msg_calendar_title',
      title: 'Calendar Reminder',
      body:
          'An upcoming event: {eventName}. Date: {eventDate}. It\'s worth '
          'preparing in advance.',
    ),
    'msg_calendar_newWeek_title': MessageTextTemplate(
      key: 'msg_calendar_newWeek_title',
      title: 'New Week',
      body: 'Week {week} of the season has begun (phase: {phase}).',
    ),
    'msg_system_title': MessageTextTemplate(
      key: 'msg_system_title',
      title: 'System Message',
      body: '{message}',
    ),
    'msg_ovrDigest_digest_title': MessageTextTemplate(
      key: 'msg_ovrDigest_digest_title',
      title: 'Weekly OVR Change Report',
      body:
          'In week {week}, {count} overall rating changes were recorded '
          'among your watched or own players. Check the summary report '
          'for details.',
    ),
  };
}
