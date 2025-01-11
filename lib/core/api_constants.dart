class APIEndpoints {
  static String getAllUserCreatedOffer(int id) => "/user/$id/offers";
  static String getChatFromOfferId(int offerId) => "/chat/offer/$offerId";

  static const String getUserChats = "/user/chats";
  static const String getNearestUsers = "/user/nearest";
}
