/// Tunable message and inbox constants from `docs/messages.md` §15.
class MessagesBalance {
  const MessagesBalance({
    this.inboxRetentionSeasons = 2,
    this.digestMinItems = 3,
    this.maxUnreadInbox = 50,
    this.maxInboxMessages = 200,
    this.maxArchiveMessages = 200,
    this.tradeOfferExpiryDays = 7,
    this.tradeDecisionExpiryDays = 1,
  });

  final int inboxRetentionSeasons;
  final int digestMinItems;
  final int maxUnreadInbox;
  final int maxInboxMessages;
  final int maxArchiveMessages;
  final int tradeOfferExpiryDays;
  final int tradeDecisionExpiryDays;
}
