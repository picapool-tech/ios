import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/functions/color_function.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/models/live_offer_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/public_chat/widgets/chat_media.dart';
import 'package:picapool/screens/public_chat/widgets/chat_members.dart';
import 'package:picapool/utils/theme.dart';

class ChatInfoImpl extends StatefulWidget {
  final Offer? offer;
  final int chatId;
  final LiveOffer? liveOffer;
  final String chatTitle;
  const ChatInfoImpl({
    super.key,
    this.offer,
    required this.chatId,
    required this.chatTitle,
    this.liveOffer,
  });

  @override
  State<ChatInfoImpl> createState() => _ChatInfoImplState();
}

class _ChatInfoImplState extends State<ChatInfoImpl>
    with SingleTickerProviderStateMixin {
  final ChatController _chatController = Get.find<ChatController>();
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  double _titlePaddingLeft = 24.0;

  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  late Color color = getColorFromString(widget.chatTitle);

  bool get hasImage => (widget.offer != null &&
      widget.offer!.images.isNotEmpty &&
      widget.offer!.images.first.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: (hasImage) ? 200.0 : 150,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.currentTheme.colorScheme.secondary,
            elevation: 0,
            systemOverlayStyle: uiOverlayStyle(
              context,
              brightness: Brightness.dark,
            ),
            leading: const BackButton(
              color: Colors.white,
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if ((widget.chatTitle.length) > 10)
                    Text(
                      widget.chatTitle.replaceFirst("- FROM BRANDS", ""),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black45,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      widget.chatTitle,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black45,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  Obx(
                    () => Text(
                      "${_chatController.usersInChat.length} users in chat",
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[200],
                      ),
                    ),
                  )
                ],
              ),
              centerTitle: false,
              collapseMode: CollapseMode.pin,
              titlePadding: EdgeInsets.only(
                bottom: _titlePaddingLeft <= 50 ? 16 : 8,
                left: _titlePaddingLeft,
              ),
              background: hasImage
                  ? GestureDetector(
                      onTap: () => _tabController.animateTo(1),
                      child: CachedNetworkImage(
                        imageUrl: widget.offer!.images.first,
                        fit: BoxFit.cover,
                      ),
                    )
                  : null,
            ),
          ),
          if (widget.offer != null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16, top: 16, bottom: 6),
                child: Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.currentTheme.colorScheme.secondary,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.offer?.desc ?? "No description",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 0.0,
                vertical: 10,
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.currentTheme.colorScheme.secondary,
                labelColor: AppTheme.currentTheme.colorScheme.secondary,
                unselectedLabelColor: Colors.grey,
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                tabs: const [
                  Tab(
                    child: Text(
                      "Members",
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Media",
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Members tab
                ChatMembersWidget(creatorId: widget.offer?.userId),
                // Media tab
                ChatMedia(images: widget.offer?.images),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.removeListener(_updateTitlePadding);
    _scrollController.dispose();
    super.dispose();
  }

  SliverToBoxAdapter heading(String heading) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          heading,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatController.getAllUsersInChat(widget.chatId);
    });

    // Add scroll listener to update title padding
    _scrollController.addListener(_updateTitlePadding);
  }

  void _updateTitlePadding() {
    // Calculate left padding based on scroll position
    // From 24 when fully expanded to 60 when collapsed
    const double expandedHeight = 200.0;
    const double minPadding = 24.0;
    const double maxPadding = 60.0;
    final double scrollOffset = _scrollController.offset;

    // Calculate a ratio between 0.0 and 1.0 based on scroll position
    final double ratio =
        (scrollOffset / (expandedHeight - kToolbarHeight)).clamp(0.0, 1.0);

    // Interpolate between min and max padding
    final double paddingValue = minPadding + (maxPadding - minPadding) * ratio;

    setState(() {
      _titlePaddingLeft = paddingValue;
    });
  }
}
