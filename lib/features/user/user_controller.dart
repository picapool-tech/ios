import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picapool/core/reactive_loading.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/user/user_api.dart';
import 'package:picapool/features/user/values/user_data_model_enum.dart';
import 'package:picapool/features/user/values/user_loading_enums.dart';
import 'package:picapool/models/near_user_model.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/models/user_model.dart';

class UserController extends GetxController
    with ReactiveLoading<UserLoadingEnums> {
  final UserApi _userApi = UserApi();
  final StorageController _storageController = Get.find<StorageController>();

  Rx<bool> isLoading = false.obs;
  var tagList = Rx<List<Tag>?>(null);
  User? get user => _storageController.user.value;

  void clear() {
    update();
  }

  Future<List<NearUserModel>?> getNearestUsers({
    required LatLng currentPosition,
    required double radius,
  }) async {
    isLoading.value = true;
    update();

    final result = await _userApi.getNearestUsers(
      userId: user!.id,
      currentPosition: currentPosition,
      radius: radius,
    );

    isLoading.value = false;
    update();

    return await result.fold(
      (error) {
        showErrorDialog(error.message);
        return null;
      },
      (users) {
        return users;
      },
    );
  }

  Future<User?> getUser(
    int id, {
    String? accessToken,
  }) async {
    isLoading.value = true;
    update();

    final result = await _userApi.getUser(userId: id);

    isLoading.value = false;
    update();

    return await result.fold(
      (fail) async {
        showErrorDialog(fail.message);
        return null;
      },
      (userReceived) async {
        var auth = userReceived.auth;
        var savedAuth = await _storageController.loadAuth();
        if (auth != null && savedAuth != null) {
          savedAuth.update(auth.toJson());
          await _storageController.saveAuth(savedAuth);
        }

        if (user?.id == id) {
          await _storageController.saveUser(userReceived);
        }

        return userReceived;
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  void setUser(User user) {
    _storageController.user.value = user;
    _storageController.saveUser(user);
    update();
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

  Future<bool> updateUser(
    List<UserField> updateFields, {
    User? previousUser,
    MapEntry<String, dynamic> Function(UserField)? customExecution,
  }) async {
    isLoading.value = true;
    startLoading(UserLoadingEnums.updateUser);
    update();

    debugPrint(
        'updateUser called with fields: ${updateFields.map((f) => f.toString()).join(', ')}');

    if (user == null || user?.id == null) {
      debugPrint('updateUser failed: user is null or has no ID');
      return false;
    }

    try {
      var updateValues = user!.toUpdateJson(
        includeFields: updateFields,
        customExecution: customExecution,
      );

      if (updateValues.isEmpty) {
        debugPrint("no values to update");
        return false;
      }

      debugPrint('updateUser values: $updateValues');

      final result = await _userApi.updateUser(
        updateValues: updateValues,
      );

      isLoading.value = false;
      update();
      return result.fold(
        (fail) {
          debugPrint('updateUser API error: ${fail.message}');
          if (fail.showError) {
            showErrorDialog(fail.message);
          }
          if (previousUser != null) {
            _storageController.saveUser(previousUser);
          }
          return false;
        },
        (updatedUser) async {
          debugPrint('updateUser success for user ID: ${user!.id}');
          _storageController.saveUser(user!);
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
      stopLoading(UserLoadingEnums.updateUser);
      update();
      debugPrint('updateUser operation completed');
    }
  }

  Future<void> _initializeUser() async {
    _storageController.user.value ?? await _storageController.loadUser();
    if (user != null) {
      var userUpdated = await getUser(
        user!.id,
      );
      if (userUpdated != null) {
        user!.update(userUpdated.toJson());
        setUser(user!);
      } else {
        debugPrint("Failed to load user data");
      }
    }

    update();
  }
}
