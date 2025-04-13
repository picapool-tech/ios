import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/functions/color_function.dart';
import 'package:picapool/common/widgets/marquee_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor:
                AppTheme.currentTheme.colorScheme.secondary.withAlpha(200),
            elevation: 0,
            automaticallyImplyLeading: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => _chatController.usersInChat.isNotEmpty
                        ? IntrinsicHeight(
                            child: Marquee(
                              blankSpace: 20,
                              text: widget.offer?.name
                                      .replaceFirst("- FROM BRANDS", "") ??
                                  "Chat Info",
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
                          )
                        : Text(
                            widget.offer?.name ?? "Chat Info",
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
                    itemCount: widget.offer?.images.length ?? 0,
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
                          widget.offer!.images[index],
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
                            (widget.offer!.images.length - 1 > 0
                                ? widget.offer!.images.length - 1
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
                  color: getColorFromString(widget.offer?.name ?? "Chat Info")
                      .darken(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.offer?.desc ?? "No Empty",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TabBar(
                      tabs: const [
                        Tab(text: "Members"),
                        Tab(text: "Info"),
                      ],
                      labelColor: AppTheme.currentTheme.colorScheme.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppTheme.currentTheme.colorScheme.primary,
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                    ),
                    SizedBox(
                      height: 300,
                      child: TabBarView(
                        children: [
                          // Members tab
                          Obx(
                            () {
                              return Container(
                                child: ListView.builder(
                                  itemCount: _chatController.usersInChat.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: _chatController
                                                    .usersInChat.values
                                                    .elementAt(index)
                                                    .pic !=
                                                null
                                            ? NetworkImage(_chatController
                                                .usersInChat.values
                                                .elementAt(index)
                                                .pic!)
                                            : null,
                                        child: _chatController
                                                    .usersInChat.values
                                                    .elementAt(index)
                                                    .pic ==
                                                null
                                            ? Text(_chatController
                                                    .usersInChat.values
                                                    .elementAt(index)
                                                    .username
                                                    ?.substring(0, 1)
                                                    .toUpperCase() ??
                                                "")
                                            : null,
                                      ),
                                      title: Text(_chatController
                                              .usersInChat.values
                                              .elementAt(index)
                                              .username ??
                                          ""),
                                      trailing: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppTheme
                                              .currentTheme.colorScheme.primary
                                              .withAlpha(50),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "Admin",
                                          style: TextStyle(
                                            color: AppTheme.currentTheme
                                                .colorScheme.primary,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          // Media tab
                          GridView.builder(
                            padding: const EdgeInsets.all(8.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemCount: widget.offer?.images.length ?? 0,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return widget.offer?.images != null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              widget.offer!.images[index]),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    )
                                  : Container();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
