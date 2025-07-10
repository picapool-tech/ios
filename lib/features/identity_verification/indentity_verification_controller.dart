import 'package:get/get.dart';
import 'package:picapool/core/reactive_loading.dart';
import 'package:picapool/features/identity_verification/enum/identity_loading_enum.dart';
import 'package:picapool/features/identity_verification/identity_verification_Api.dart';
import 'package:picapool/features/user/user_controller.dart';

class IndentityVerificationController extends GetxController
    with ReactiveLoading<IdentityLoadingEnum> {
  final IdentityVerificationApi _identityVerificationApi =
      IdentityVerificationApi();

  final UserController _userController = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    initializeLoadingStates(IdentityLoadingEnum.values);
  }

  Future<(bool, String)> sendVerificationCode({
    required String email,
  }) async {
    startLoading(IdentityLoadingEnum.sendVerificationCode);
    final result = await _identityVerificationApi.sendVerificaitionOtp(
      userId: _userController.user!.id,
      email: email,
    );

    return result.fold(
      (error) {
        stopLoading(IdentityLoadingEnum.sendVerificationCode);
        print('Error sending verification code: $error');
        return (false, error.message); // Simulate failure
      },
      (responseModel) {
        stopLoading(IdentityLoadingEnum.sendVerificationCode);
        // Handle success, e.g., show a success message
        print('Verification code sent successfully: ${responseModel.data}');
        return (responseModel.success, ""); // Simulate success
      },
    );
  }

  Future<(bool, String)> verifyOtp({
    required String otp,
  }) async {
    startLoading(IdentityLoadingEnum.verifyCode);
    final result = await _identityVerificationApi.verifyOtp(
      userId: _userController.user!.id,
      otp: otp,
    );

    return result.fold(
      (error) {
        stopLoading(IdentityLoadingEnum.verifyCode);
        print('Error verifying OTP: $error');
        return (false, error.message); // Simulate failure
      },
      (responseModel) {
        stopLoading(IdentityLoadingEnum.verifyCode);
        // Handle success, e.g., show a success message
        print('OTP verified successfully: ${responseModel.data}');
        _userController.setUser(
          _userController.user!.copyWith(
            isVerified: true,
          ),
        );
        return (
          responseModel.success,
          responseModel.message
        ); // Simulate success
      },
    );
  }
}
