/// Tunable message and inbox constants from `docs/messages.md` §15.
enum TeamEventExpiryMode { endOfDay }

class MessagesBalance {
  const MessagesBalance({
    this.inboxRetentionSeasons = 2,
    this.digestMinItems = 3,
    this.maxUnreadInbox = 50,
    this.scoutReportDay = 1,
    this.tradeOfferExpiryDays = 7,
    this.teamEventExpiry = TeamEventExpiryMode.endOfDay,
    this.playerEventExpiryDaysMin = 1,
    this.playerEventExpiryDaysMax = 3,
    this.faAcceptFinalizeHours = 3,
    this.faAcceptFinalizeDays = 3,
    this.extAcceptFinalizeDays = 1,
    this.hardRejectBlockDays = 30,
  });

  final int inboxRetentionSeasons;
  final int digestMinItems;
  final int maxUnreadInbox;
  final int scoutReportDay;
  final int tradeOfferExpiryDays;
  final TeamEventExpiryMode teamEventExpiry;
  final int playerEventExpiryDaysMin;
  final int playerEventExpiryDaysMax;
  final int faAcceptFinalizeHours;
  final int faAcceptFinalizeDays;
  final int extAcceptFinalizeDays;
  final int hardRejectBlockDays;
}
