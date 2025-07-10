import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/features/user/user_controller.dart';

class VerifiedProfile extends StatefulWidget {
  final String title;
  final String description;

  const VerifiedProfile({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<VerifiedProfile> createState() => _VerifiedProfileState();
}

class _VerifiedProfileState extends State<VerifiedProfile>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<Offset> _avatarSlideAnimation;
  late Animation<double> _avatarOpacityAnimation;
  late Animation<Offset> _nameSlideAnimation;
  late Animation<double> _nameOpacityAnimation;
  late Animation<Offset> _usernameSlideAnimation;
  late Animation<double> _usernameOpacityAnimation;
  late Animation<Offset> _verifiedSlideAnimation;
  late Animation<double> _verifiedOpacityAnimation;
  late Animation<Offset> _descriptionSlideAnimation;
  late Animation<double> _descriptionOpacityAnimation;

  @override
  Widget build(BuildContext context) {
    var userController = Get.find<UserController>();
    var user = userController.user;

    return Scaffold(
      appBar: AppBar(),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar Animation - Slides up from center
                FadeTransition(
                  opacity: _avatarOpacityAnimation,
                  child: SlideTransition(
                    position: _avatarSlideAnimation,
                    child: CircleAvatar(
                      radius: Get.width * 0.2,
                      backgroundColor: Colors.grey.shade300,
                      foregroundImage: (user?.pic != null)
                          ? CachedNetworkImageProvider(
                              user!.pic!,
                              errorListener: (p0) {},
                            )
                          : const AssetImage(
                              'assets/icons/Frame 64.png',
                            ) as ImageProvider,
                    ),
                  ),
                ),

                // Name Row Animation - Slides down from center
                FadeTransition(
                  opacity: _nameOpacityAnimation,
                  child: SlideTransition(
                    position: _nameSlideAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            user?.name ?? "Unknown User",
                            style: Get.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (user?.isVerified ?? false)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Image.asset(
                              "assets/images/profile/pica_verified.png",
                              width: 28,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Username Animation - Slides down from center
                FadeTransition(
                  opacity: _usernameOpacityAnimation,
                  child: SlideTransition(
                    position: _usernameSlideAnimation,
                    child: Text(
                      "@${user?.username ?? "nousername"}",
                      style: Get.textTheme.labelLarge?.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // "You are verified" Text Animation - Slides down from center
                FadeTransition(
                  opacity: _verifiedOpacityAnimation,
                  child: SlideTransition(
                    position: _verifiedSlideAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "You are verified",
                            style: Get.textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Description Animation - Slides down from center
                FadeTransition(
                  opacity: _descriptionOpacityAnimation,
                  child: SlideTransition(
                    position: _descriptionSlideAnimation,
                    child: Text(
                      widget.description,
                      style: Get.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                PicaPrimaryButton(
                  text: "Feels Good!",
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  isLoading: false.obs,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 1400,
      ), // Increased duration for more elements
      vsync: this,
    );

    // Title animation (starts first)
    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic),
    ));

    // Avatar slide up animation
    _avatarSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5), // Start from center-bottom
      end: const Offset(0, -0.3), // Move up
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.5, curve: Curves.easeOutCubic),
    ));

    _avatarOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.4, curve: Curves.easeOut),
    ));

    // Name row slide down animation
    _nameSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3), // Start from center-top
      end: const Offset(0, 0.1), // Move down
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
    ));

    _nameOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.5, curve: Curves.easeOut),
    ));

    // Username slide down animation
    _usernameSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: const Offset(0, 0.15),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.7, curve: Curves.easeOutCubic),
    ));

    _usernameOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.6, curve: Curves.easeOut),
    ));

    // "You are verified" slide down animation
    _verifiedSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: const Offset(0, 0.2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.8, curve: Curves.easeOutCubic),
    ));

    _verifiedOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.75, curve: Curves.easeOut),
    ));

    // Description slide down animation
    _descriptionSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: const Offset(0, 0.3),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOutCubic),
    ));

    _descriptionOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 0.95, curve: Curves.easeOut),
    ));

    // Start animation
    _controller.forward();
  }
}
