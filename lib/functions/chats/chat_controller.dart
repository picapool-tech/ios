import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/chats/chat_api.dart';
import 'package:picapool/models/chat_model.dart';

class ChatController extends GetxController {
  final ChatApi _chatApi = ChatApi();
  final AuthController _authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var chats = <Chat>[].obs;

  Future<void> getAllChats() async {
    isLoading.value = true;
    errorMessage.value = '';
    update();

    var accessToken = _authController.auth.value!.accessToken;

    final result = await _chatApi.getChats(accessToken: accessToken!);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message,
            snackPosition: SnackPosition.TOP);
      },
      (chatsList) {
        chats.value = chatsList;
      },
    );

    isLoading.value = false;
    update();
  }
}
