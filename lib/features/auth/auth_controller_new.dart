import 'package:get/get.dart';
import 'package:picapool/core/reactive_loading.dart';
import 'package:picapool/features/auth/auth_api.dart';
import 'package:picapool/features/auth/values/enums.dart';
import 'package:picapool/features/storage/storage_controller.dart';

class AuthController extends GetxController
    with ReactiveLoading<AuthLoadingEnum> {
  final AuthApi _authApi = AuthApi();
  final StorageController _storageController = Get.find<StorageController>();

}