class APIEndpoints {
  static String getAllUserCreatedOffer(int id) => "/user/$id/offers";
  static String getChatFromOfferId(int offerId) => "/chat/offer/$offerId";
  static String getAllMessagesOfChat(int chatId) => "/chat/$chatId/messages";
  static String getAllUsersInChat(int chatId) => "/chat/$chatId/users";
  static String getChatFromLiveOfferId(int liveOfferId) =>
      "/chat/liveOffer/$liveOfferId";

  static const String getUserChats = "/user/chats";
  static const String getNearestUsers = "/user/nearest";

  static const String createOffer = "/offer";

  static const String createChat = "/chat";
}
