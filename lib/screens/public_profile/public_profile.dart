import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/text_field_widgets.dart';
import 'package:picapool/features/assets/assets_controller.dart';
import 'package:picapool/features/auth/auth_controller.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/features/user/values/user_data_model_enum.dart';
import 'package:picapool/features/user/values/user_loading_enums.dart';
import 'package:picapool/utils/permission_util.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class PublicProfile extends StatefulWidget {
  const PublicProfile({Key? key}) : super(key: key);

  @override
  State<PublicProfile> createState() => _PublicProfileState();
}

class _PublicProfileState extends State<PublicProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _profileImage;
  bool _isUsernameValid = true; // Validation flag for username
  final _authController = Get.find<AuthController>();
  final _userController = Get.find<UserController>();
  final _assetsController = Get.find<AssetsController>();

  TextTheme get textTheme => Theme.of(context).textTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Center(
          child: SizedBox(
            width: 100,
            child: StepProgressIndicator(
              totalSteps: 2,
              currentStep: 2,
              size: 4,
              padding: 8,
              selectedColor: Colors.orange,
              unselectedColor: Colors.grey[300]!,
            ),
          ),
        ),
        actions: <Widget>[
          // Creates an invisible IconButton to balance the AppBar visually
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.transparent),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Your Public Profile',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Image.asset("assets/icons/Profile.png")
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 18,
                          child: Icon(Icons.camera_alt, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Add Profile Image',
                  style: textTheme.labelSmall,
                ),
              ),
              const SizedBox(height: 20),
              PicaOutlinedTextField(
                hintText: 'Add your username*',
                labelText: "Username",
                controller: _usernameController,
                maxLength: 16,
                // isUsername: true, // Specific for username field
              ),
              validationListWidget(),
              const SizedBox(height: 16),
              PicaOutlinedTextField(
                hintText: 'Add bio',
                controller: _bioController,
                labelText: "Bio",
                maxLength: 200,
                maxLines: 3,
              ),
              Text(
                'Users with bio receive up to 152% more pooling matches',
                style: textTheme.labelSmall,
              ),
              const SizedBox(height: 24),
              PicaPrimaryButton(
                onPressed: _isUsernameValid
                    ? () async {
                        await createUser();
                      }
                    : null,
                text: "Finish",
                isLoading: _userController.getLoadingState(
                  UserLoadingEnums.updateUser,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createUser() async {
    var storageController = Get.find<StorageController>();
    final backupUser = storageController.user.value;
    if (backupUser == null) {
      debugPrint('User is null');
      return;
    }

    var profileUrl = backupUser.pic;
    if (_profileImage != null) {
      profileUrl = await _assetsController.uploadImage(
          XFile(_profileImage!.path),
          '${backupUser.id}-${backupUser.name}-${DateTime.now().toIso8601String()}.jpg');
    }

    storageController.user.update((user) {
      if (user == null) {
        return;
      }
      user.username = _usernameController.text;
      user.bio = _bioController.text;
      user.pic = profileUrl;
    });

    var tagController = Get.find<TagController>();
    await tagController.getAllTags();
    // await authController.createUser();
    await _userController.updateUser(
      [UserField.username, UserField.bio, UserField.pic],
    );
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onUsernameChanged);
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  bool getUsernameLength() =>
      _usernameController.text.length > 3 &&
      _usernameController.text.length < 17;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      var username = _userController.user?.username ?? " ";
      if (username.contains("PIC@USERNAME") || username.length > 30) {
        debugPrint("Username : $username");
        _userController.user!.username = "";
        username = "";
      }
      debugPrint("Username outside: $username");
      setState(() {
        _usernameController.text = username;
        _bioController.text = _userController.user?.bio ?? '';
      });
      _usernameController.addListener(_onUsernameChanged);
    });
  }

  textWithCheckIcon(String text, bool isValid) {
    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.close,
            color: isValid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.grey,
              fontSize: 12,
              fontFamily: 'MontserratR',
            ),
          ),
        ],
      ),
    );
  }

  validationListWidget() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textWithCheckIcon(
            "Username should be between 4-16 characters",
            getUsernameLength(),
          ),
          textWithCheckIcon(
            "Should not contains any spaces",
            !_usernameController.text.contains(" "),
          ),
          textWithCheckIcon(
            "No special characters other than underscore",
            RegExp(r'^[A-Za-z0-9_]+$').hasMatch(_usernameController.text),
          ),
        ],
      ),
    );
  }

  void _onUsernameChanged() {
    setState(() {
      _isUsernameValid = _usernameController.text.isNotEmpty &&
          RegExp(r'^[A-Za-z]{1}[A-Za-z0-9_]{3,16}$')
              .hasMatch(_usernameController.text);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    var permission = PermissionUtil();
    if (source == ImageSource.gallery &&
        !await permission.isPhotoPermissionGranted()) {
      await permission.requestPhotoPermission();
      return;
    }

    if (source == ImageSource.camera &&
        !await permission.isCameraPermissionGranted()) {
      await permission.requestCameraPermission();
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 10,
    );
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _profileImage = File(croppedFile.path);
        });
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
