import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picapool/functions/auth/auth_controller.dart';
import 'package:picapool/functions/chats/chat_controller.dart';
import 'package:picapool/functions/offers/offers_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/Public%20Chat/chatPage.dart';
import 'package:picapool/screens/Public%20Chat/publicChatScreen.dart';
import 'package:picapool/utils/date_time_helper.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  _AlertsPageState createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String selectedCategory = 'All Offers';
  List<bool> expandedStates = [];

  final OffersController _offers = Get.find<OffersController>();
  final ChatController _chatController = Get.find<ChatController>();
  final AuthController _authController = Get.find<AuthController>();
  List<Offer> offers = [];

  @override
  void initState() {
    super.initState();

    if (_authController.user.value != null) {
      _offers.fetchOffers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff02005D),
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Alerts',
            style: TextStyle(
              fontFamily: "MontserratM",
              fontSize: 24,
              color: Color(0xffFFFFFF),
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xff02005D),
      ),
      body: Column(
        children: [
          // Category Buttons
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            color: const Color(0xff02005D),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    CategoryButton(
                      image: 'assets/icons/all.png',
                      label: 'All Offers',
                      selected: selectedCategory == 'All Offers',
                      onTap: () {
                        setState(() {
                          selectedCategory = 'All Offers';
                        });
                      },
                    ),
                    CategoryButton(
                      image: 'assets/icons/food.png',
                      label: 'Food',
                      selected: selectedCategory == 'Food',
                      onTap: () {
                        setState(() {
                          selectedCategory = 'Food';
                        });
                      },
                    ),
                    CategoryButton(
                      image: 'assets/icons/tshirt.png',
                      label: 'Apparel',
                      selected: selectedCategory == 'Apparel',
                      onTap: () {
                        setState(() {
                          selectedCategory = 'Apparel';
                        });
                      },
                    ),
                    CategoryButton(
                      image: 'assets/icons/Bell.png',
                      label: 'Entertainment',
                      selected: selectedCategory == 'Entertainment',
                      onTap: () {
                        setState(() {
                          selectedCategory = 'Entertainment';
                        });
                      },
                    ),
                    CategoryButton(
                      image: 'assets/icons/ball.png',
                      label: 'Sports',
                      selected: selectedCategory == 'Sports',
                      onTap: () {
                        setState(() {
                          selectedCategory = 'Sports';
                        });
                      },
                    ),
                    CategoryButton(
                      image: 'assets/icons/ball.png',
                      label: 'Medicine',
                      selected: selectedCategory == 'Medicine',
                      onTap: () {
                        setState(() {
                          selectedCategory = 'Medicine';
                        });
                      },
                    ),
                    CategoryButton(
                      image: 'assets/icons/Frame 59.png',
                      label: 'Electronics',
                      selected: selectedCategory == 'Electronics',
                      onTap: () {
                        setState(() {
                          selectedCategory = 'Electronics';
                        });
                      },
                    ),
                    CategoryButton(
                      image: 'assets/icons/ball.png',
                      label: 'Music',
                      selected: selectedCategory == 'Music',
                      onTap: () {
                        setState(() {
                          selectedCategory = 'Music';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Alert List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: (_authController.user.value != null)
                      ? GetBuilder<OffersController>(builder: (controller) {
                          if (controller.offers.isEmpty &&
                              controller.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
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

                            return showOfferList();
                          }
                        })
                      : const Center(
                          child: Text(
                            "You don't have an account to show chats",
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                                    offer.name,
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
                                      offer.createdAt.toIso8601String()),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: "MontserratM",
                                    color: Color(0xff7B7B7B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/icons/tshirt.png',
                                  width: 15,
                                  height: 15,
                                ),
                                const SizedBox(width: 2),
                                const Text(
                                  'Category here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "MontserratM",
                                    color: Color(0xff7B7B7B),
                                  ),
                                ),
                              ],
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
                                const SizedBox(width: 2),
                                Text(
                                  DateTimeHelper.formatDateTimeExpiry(
                                    offer.expiryAt,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: "MontserratM",
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 55.0),
                              child: Row(
                                children: [
                                  Text(
                                    isExpanded ? "Hide Details" : "See Details",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: "MontserratM",
                                    ),
                                  ),
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
                          "assets/images/harrypotter.jpg",
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

  ListView showOfferList() {
    debugPrint("${_offers.offers.first.toJson()}");
    return ListView.builder(
      itemCount: _offers.offers.length,
      itemBuilder: (context, index) {
        var offer = _offers.offers[index];
        return listItem(
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
    var authController = Get.find<AuthController>();
    debugPrint("INSIDE ALERT PAGE : ${offer.userId}");
    if (chat == null && offer.userId == authController.auth.value?.user?.id) {
      debugPrint("Here is in the chat");
      var chatAndOfferModel =
          await _chatController.createChatWithOfferId(offer.id);
      if (chatAndOfferModel != null) {
        Get.to(() => ChatPage(
              chat: chatAndOfferModel.chat,
              offer: chatAndOfferModel.offer,
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
        ));
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final bool selected;
  final String image;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.label,
    required this.image,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: selected ? Colors.white : Colors.black,
          backgroundColor: selected ? const Color(0xffFF8D41) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        onPressed: onTap,
        icon: Image.asset(image, width: 20, height: 20),
        label: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
