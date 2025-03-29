import 'package:get/get.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';

extension OfferChatExtension on ChatController {
  Future<void> joinOfferChat(Offer offer) async {
    final UserController userController = Get.find<UserController>();
    final OffersController offersController = Get.find<OffersController>();

    var chat = await offersController.getChatFromOfferId(offerId: offer.id);

    // If chat doesn't exist and user is the offer creator, create a new chat
    if (chat == null && offer.userId == userController.user!.id) {
      var chatAndOfferModel = await createChatWithOfferId(offer.id);
      if (chatAndOfferModel != null) {
        Get.to(
          () => ChatPage(
            chat: chatAndOfferModel.chat,
            offer: chatAndOfferModel.offer,
            chatTitle: chatAndOfferModel.chat.offer?.name ?? "Chat",
          ),
        );
      }
      return;
    }

    // If chat exists, navigate to chat page
    if (chat != null) {
      Get.to(
        () => ChatPage(
          chat: chat,
          offer: offer,
          chatTitle: chat.offer?.name ?? "Chat",
        ),
      );
    }
  }
}
