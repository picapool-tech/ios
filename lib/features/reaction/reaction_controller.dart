import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:picapool/core/reactive_loading.dart';
import 'package:picapool/features/reaction/reaction_api.dart';
import 'package:picapool/features/reaction/values/reaction_loading_enums.dart';
import 'package:picapool/models/message_reaction_model.dart';

class ReactionController extends GetxController
    with ReactiveLoading<ReactionLoadingEnums> {
  final ReactionApi _reactionApi = ReactionApi();
  final RxList<MessageReactionModel> _reactions = <MessageReactionModel>[].obs;

  List<MessageReactionModel> get reactions => _reactions.toList();

  Future<List<MessageReactionModel>> getReactionsByMessageId(
      int messageId) async {
    try {
      startLoading(ReactionLoadingEnums.getReactions);
      update();
      var response = await _reactionApi.getMessageReactions(messageId);
      return response.fold(
        (error) {
          stopLoading(ReactionLoadingEnums.getReactions);
          debugPrint("Error fetching reactions: ${error.message}");
          return [];
        },
        (data) {
          // _reactions.assignAll(data);
          debugPrint("Fetched ${data.length} reactions");
          stopLoading(ReactionLoadingEnums.getReactions);
          return data;
        },
      );
    } catch (e) {
      stopLoading(ReactionLoadingEnums.getReactions);
      debugPrint("Exception fetching reactions: $e");
      return [];
    } finally {
      update();
    }
  }

  @override
  onInit() {
    super.onInit();
    initializeLoadingStates(ReactionLoadingEnums.values);
  }
}
