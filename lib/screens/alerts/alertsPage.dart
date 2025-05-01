import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/screens/alerts/widgets/category_button.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/widgets/loading/offer_loading.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({
    super.key,
  });

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  int selectedCategory = 0;
  List<bool> expandedStates = [];
  List<bool> expandedTagStates = [];

  final ScrollController _tagsScrollController = ScrollController();

  final OffersController _offers = Get.find<OffersController>();
  final ChatController _chatController = Get.find<ChatController>();
  final UserController _userController = Get.find<UserController>();
  final TagController _tagController = Get.find<TagController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alerts1',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        systemOverlayStyle: uiOverlayStyle(
          context,
          brightness: Brightness.dark,
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xff02005D),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kBottomNavigationBarHeight),
          child: SingleChildScrollView(
            controller: _tagsScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              CategoryButton(
                image: "",
                assetImage: 'assets/icons/all.png',
                label: 'All Offers',
                selected: selectedCategory == 0,
                onTap: () {
                  setState(() {
                    selectedCategory = 0;
                    expandedTagStates = [];
                    _offers.getOffersForUser();
                  });
                },
              ),
              ...List.generate(_tagController.tags.length, (index) {
                var tag = _tagController.tags[index];
                return CategoryButton(
                  image: tag.icon,
                  label: tag.tag,
                  selected: selectedCategory == index + 1,
                  onTap: () {
                    setState(() {
                      selectedCategory = index + 1;
                      expandedTagStates = [];
                      _offers.getOffersByTagId(selectedCategory);
                    });
                  },
                );
              }),
            ]),
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          if (selectedCategory == 0) {
            await _offers.getOffersForUser();
          } else {
            await _offers.getOffersByTagId(selectedCategory);
          }
        },
        child: Column(
          children: [
            Obx(() {
              if (selectedCategory == 0) {
                if (_offers.offers.isNotEmpty && _offers.isLoading.value) {
                  return const LinearProgressIndicator();
                }
              }

              var isValid =
                  _offers.offersByTagId[selectedCategory]?.isNotEmpty ?? false;
              if (_offers.isLoading.value && isValid) {
                return const LinearProgressIndicator();
              }

              return const SizedBox.shrink();
            }),

            // Alert List
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 8),
                child: (_userController.user != null)
                    ? GetBuilder<OffersController>(
                        builder: (controller) {
                          switch (selectedCategory) {
                            case 0:
                              if (controller.offers.isEmpty &&
                                  controller.isLoading.value) {
                                return const OfferLoading();
                              }

                              if (controller.offers.isEmpty) {
                                return const Center(
                                  child: Text("No offers"),
                                );
                              } else {
                                if (expandedStates.length !=
                                    controller.offers.length) {
                                  expandedStates = List<bool>.filled(
                                    controller.offers.length,
                                    false,
                                  );
                                }

                                return showOfferList(controller.offers);
                              }
                            default:
                              var offerByTagId =
                                  controller.offersByTagId[selectedCategory];
                              if (offerByTagId == null) {
                                return const Center(
                                  child: Text("No offers"),
                                );
                              }
                              if (offerByTagId.isEmpty &&
                                  controller.isLoading.value) {
                                return const OfferLoading();
                              }

                              if (offerByTagId.isEmpty) {
                                return const Center(
                                  child: Text("No offers"),
                                );
                              } else {
                                if (expandedTagStates.length !=
                                    offerByTagId.length) {
                                  expandedTagStates = List<bool>.filled(
                                    offerByTagId.length,
                                    false,
                                  );
                                }

                                return showOfferList(offerByTagId);
                              }
                          }
                        },
                      )
                    : const Center(
                        child: Text(
                          "You don't have an account to show alerts",
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Tag?>? getTagById(int? tagId) async {
    if (tagId == null) return null;
    return _tagController.getTagFromCacheOrNetwork(tagId);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      Tag? tag;
      tag = _tagController.getTagsByTagName("Ask") ??
          _tagController.getTagsByTagName("Req");

      if (tag == null) {
        debugPrint("Tag is null on alertsPage");
        return;
      }
      var tagsIndex =
          _tagController.tags.indexWhere((tagN) => tagN.id == tag!.id);
      setState(() {
        setState(() {
          selectedCategory = tagsIndex + 1;
          _offers.getOffersByTagId(tag!.id);
        });
      });
    });
  }

  Widget listItem({
    required Offer offer,
    required Function()? onTap,
    bool isExpanded = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,

          height: isExpanded ? 140 : 120, // Adjust the height to fit content
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: isExpanded
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Collapsed state: Only show title, category, and time
                      if (!isExpanded) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    offer.name.replaceAll("- FROM BRANDS", ""),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: "MontserratM"),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateTimeHelper.timeAgoSince(
                                    offer.createdAt.toIso8601String(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: "MontserratM",
                                    color: Color(0xff7B7B7B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            if (offer.tags != null && offer.tags!.isNotEmpty)
                              Row(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: offer.tags!.first.icon,
                                    width: 15,
                                    height: 15,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      offer.tags!.first.tag,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: "MontserratM",
                                        color: Color(0xff7B7B7B),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                offer.desc,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        const Spacer(),
                      ]

                      // Expanded state: Show additional information
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              offer.desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: "MontserratM",
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // if need to check expiry
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 18, color: Colors.orange),
                                const SizedBox(width: 5),
                                Text(
                                  "Expires in ${DateTimeHelper.formatDateTimeExpiry(offer.expiryAt)}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: "MontserratM",
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 5),
                            // if (alerts[0]['distance'] != null)
                            //   Row(
                            //     children: [
                            //       const Icon(Icons.location_on,
                            //           size: 18, color: Colors.orange),
                            //       const SizedBox(width: 5),
                            //       Text(
                            //         alerts[0]['distance'] ?? '',
                            //         style: const TextStyle(
                            //           fontSize: 14,
                            //           fontFamily: "MontserratM",
                            //           color: Colors.black,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // const SizedBox(height: 5),
                            // if (offer.chats != null)
                            //   Row(
                            //     children: [
                            //       const Icon(Icons.group,
                            //           size: 18, color: Colors.orange),
                            //       const SizedBox(width: 5),
                            //       Text(
                            //         alerts[0]['people_in_chat'] ?? '',
                            //         style: const TextStyle(
                            //           fontSize: 14,
                            //           fontFamily: "MontserratM",
                            //           color: Colors.black,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                debugPrint("${offer.toJson()}");
                                _joinChat(offer);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffFF8D41),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Join Chat',
                                style: TextStyle(
                                  fontFamily: "MontserratM",
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (!isExpanded)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/icons/clock.png',
                                  width: 15,
                                  height: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  DateTimeHelper.formatDateTimeExpiry(
                                    offer.expiryAt,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: "MontserratM",
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                    isExpanded ? "Hide Details" : "See Details",
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                const SizedBox(width: 2),
                                Icon(
                                  isExpanded
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  size: 15,
                                  color: const Color(0xffFF8D41),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: (offer.images.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: offer.images.first,
                          fit: BoxFit.cover,
                          errorWidget: (context, error, ob) => Image.asset(
                            "assets/icons/alert_image.png",
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          "assets/images/request_vicinity.png",
                          fit: BoxFit.cover,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListView showOfferList(List<Offer> offers) {
    debugPrint("${_offers.offers.firstOrNull?.toJson()}");
    return ListView.builder(
      itemCount: offers.length,
      itemBuilder: (context, index) {
        var offer = offers[index];
        if (expandedStates.length != offers.length) {
          expandedStates = List<bool>.filled(offers.length, false);
        }
        return
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            listItem(
          offer: offer,
          onTap: () {
            setState(() {
              debugPrint('Tapped on $index');
              expandedStates[index] = !expandedStates[index];
            });
          },
          isExpanded: expandedStates[index],
        );
      },
    );
  }

  void _joinChat(Offer offer) async {
    var chat = await _offers.getChatFromOfferId(offerId: offer.id);
    debugPrint("INSIDE ALERT PAGE : ${offer.userId}");
    if (chat == null && offer.userId == _userController.user!.id) {
      debugPrint("Here is in the chat");
      var chatAndOfferModel =
          await _chatController.createChatWithOfferId(offer.id);
      if (chatAndOfferModel != null) {
        Get.to(() => ChatPage(
              chat: chatAndOfferModel.chat,
              offer: chatAndOfferModel.offer,
              chatTitle: chatAndOfferModel.chat.offer?.name ?? "Chat",
            ));
      }

      return;
    }

    if (chat == null) {
      return;
    }

    Get.to(() => ChatPage(
          chat: chat,
          offer: offer,
          chatTitle: chat.offer?.name ?? "Chat",
        ));
  }
}
