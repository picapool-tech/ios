import 'package:fpdart/fpdart.dart';
import 'package:picapool/core/api_impl.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/message_reaction_model.dart';
import 'package:picapool/models/response_model.dart';

class ReactionApi with PicapoolApiClass {
  FutureEither<List<MessageReactionModel>> getMessageReactions(
      int messageId) async {
    final response = await api.makeRequest(
      enpoint: APIEndpoints.getMessageReactions(messageId),
      method: RequestMethod.getRequest,
    );

    return response.fold(
      (error) => left(error),
      (data) async {
        List<MessageReactionModel> reactions = await data
            .parseDataList<MessageReactionModel>(MessageReactionModel.fromJson);
        return right(reactions);
      },
    );
  }
}
