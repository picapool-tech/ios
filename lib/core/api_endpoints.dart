class APIEndpoints {
  static const String getUserChats = "/user/chats";
  static const String getNearestUsers = "/user/nearest";
  static const String updateUser = "/user/update";
  static const String createOffer = "/offer";
  static const String createChat = "/chat";
  static const String searchOffer = "/offer/search";
  static const String searchPartner = "/partner/search";
  static const String sendFeedback = "/feedback";
  static const String getAllOffers = "/offer/all";
  static const String getAllTags = "/tag/all";
  static const String getAllProducts = "/product";
  static const String searchProducts = "/product/search";
  static const String createProduct = "/product";
  static const String updateProduct = "/product/update";
  static const String userLogin = "/auth/login/User";
  static const String updateAccessToken = "/auth/accessToken";
  static const String getOtp = "/otp";
  static const String identityVerificationOtp = "/otp/send-verification-otp";
  static const String identityVerificationOtpVerify = "/otp/verify-user";

  static const String updateAuth = "/auth/update";
  static String deleteOfferDetails(int id) => "/offer/$id";
  static String getAllMessagesOfChat(int chatId) => "/chat/$chatId/messages";
  // user endpoints
  static String getAllUserCreatedOffer(int id) => "/user/$id/offers";
  static String getAllUsersInChat(int chatId) => "/chat/$chatId/users";
  static String getChatById(int id) => "/chat/$id";
  static String getChatFromLiveOfferId(int liveOfferId) =>
      "/chat/liveOffer/$liveOfferId";
  static String getChatFromOfferId(int offerId) => "/chat/offer/$offerId";
  static String getOfferDetails(int id) => "/offer/$id";
  static String getOffersByTagId(int tagId) => "/offer/tag/$tagId";
  static String getOffersForUser(int userId) => "/user/$userId/alerts";
  static String getPartnerById({
    required int id,
    required bool products,
    required bool offers,
  }) =>
      "/partner/$id?products=$products&offers=$offers";
  static String getReadMessageInfo(int messageId) =>
      "/message/$messageId/reads";
  static String getTagById(int tagId) => "/tag/$tagId";
  static String getUser(int id) => "/user/$id";
  // static String get

  static String updateOfferDetails(int id) => "/offer/$id";

  static String verifyOtp({required String phoneNumber, required String otp}) =>
      "/otp/verify?otp=$otp&mobile=$phoneNumber";
}
