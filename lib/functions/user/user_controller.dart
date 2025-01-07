import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/auth/auth_api.dart';
import 'package:picapool/functions/storage/storage_controller.dart';
import 'package:picapool/functions/user/user_api.dart';
import 'package:picapool/models/user_model.dart';

class UserController extends GetxController {
  final UserApi _userApi = UserApi();
  final StorageController _storageController = Get.find<StorageController>();

  Rx<bool> isLoading = false.obs;
  var user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    user.value =
        _storageController.user.value ??= await _storageController.loadUser();
    update();
  }

  Future<bool> updateUser(Map<String, dynamic> updateValues) async {
    isLoading.value = true;
    update();

    if (user.value == null || user.value?.id == null) {
      return false;
    }

    try {
      var accessToken = await _storageController.getAccessToken();
      final result = await _userApi.updateUser(
        updateValues,
        accessToken!,
      );

      isLoading.value = false;
      update();
      return result.fold(
        (fail) {
          showErrorDialog(fail.message);
          return false;
        },
        (updatedUser) async {
          user.value!.update(updateValues);
          _storageController.saveUser(user.value!);
          update();
          return true;
        },
      );
    } catch (e) {
      debugPrint('Update User Error: $e');
      showErrorDialog(
        'Failed to update user. Please try again.',
      );
      return false;
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<User?> getUser(
    int id, {
    String? accessToken,
  }) async {
    isLoading.value = true;
    update();

    final at = await _storageController.getAccessToken();

    final result =
        await _userApi.getUser(userId: id, accessToken: accessToken ?? at!);

    isLoading.value = false;
    update();

    return await result.fold(
      (fail) async {
        showErrorDialog(fail.message);
        return null;
      },
      (user) async {
        var auth = user.auth;
        var savedAuth = await _storageController.loadAuth();
        if (auth != null && savedAuth != null) {
          savedAuth.update(auth.toJson());
          await _storageController.saveAuth(savedAuth);
        }
        return user;
      },
    );
  }

  void showErrorDialog(String errorMessage) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: const Text("Error"),
        content: Text(errorMessage),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
