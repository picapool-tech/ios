import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/functions/color_function.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/utils/theme.dart';

class ChatInfoImpl extends StatefulWidget {
  final Offer? offer;
  final int chatId;
  const ChatInfoImpl({
    super.key,
    this.offer,
    required this.chatId,
  });

  @override
  State<ChatInfoImpl> createState() => _ChatInfoImplState();
}

class _ChatInfoImplState extends State<ChatInfoImpl> {
  final ChatController _chatController = Get.find<ChatController>();
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  double _titlePaddingLeft = 24.0;

  // Sample images for demonstration - replace with your actual images
  final List<String> imageUrls = [
    'https://picsum.photos/800/400?random=1',
    'https://picsum.photos/800/400?random=2',
    'https://picsum.photos/800/400?random=3',
    'https://picsum.photos/800/400?random=4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.currentTheme.colorScheme.secondary,
            elevation: 0,
            automaticallyImplyLeading: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.offer?.name ?? "Chat Info",
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              centerTitle: false,
              collapseMode: CollapseMode.pin,
              titlePadding: EdgeInsets.only(
                bottom: 16,
                left: _titlePaddingLeft,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    itemCount: imageUrls.length,
                    physics: const PageScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Optional: Add behavior when tapping an image
                        },
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 3,
                      child: LinearProgressIndicator(
                        value: (_currentPage /
                            (imageUrls.length - 1 > 0
                                ? imageUrls.length - 1
                                : 1)),
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.currentTheme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16, top: 16, bottom: 6),
              child: Text(
                "Description",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: getColorFromString(widget.offer?.name ?? "Chat Info"),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.offer?.desc ?? "No EMpty",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16, top: 16, bottom: 6),
              child: Text(
                "Participants",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: getColorFromString(widget.offer?.name ?? "Chat Info"),
                ),
              ),
            ),
          ),
          Obx(() {
            if (_chatController.usersInChat.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: _chatController.usersInChat.values
                                  .elementAt(index)
                                  .pic !=
                              null
                          ? NetworkImage(_chatController.usersInChat.values
                              .elementAt(index)
                              .pic!)
                          : null,
                      child: _chatController.usersInChat.values
                                  .elementAt(index)
                                  .pic ==
                              null
                          ? Text(_chatController.usersInChat.values
                                  .elementAt(index)
                                  .username
                                  ?.substring(0, 1)
                                  .toUpperCase() ??
                              "")
                          : null,
                    ),
                    title: Text(_chatController.usersInChat.values
                            .elementAt(index)
                            .username ??
                        ""),
                  ),
                  childCount: _chatController.usersInChat.length,
                ),
              );
            }
          }),
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
    final double scrollOffset = _scrollController.offset;
    final double paddingValue =
        24.0 + (36.0 * (scrollOffset / expandedHeight)).clamp(0.0, 1.0);

    setState(() {
      _titlePaddingLeft = paddingValue;
    });
  }
}
