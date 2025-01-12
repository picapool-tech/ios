import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picapool/functions/chats/chat_api.dart';
import 'package:picapool/functions/chats/chat_controller.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/screens/Public%20Chat/chatPage.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/utils/svg_icon.dart';

class MyChatsPage extends StatefulWidget {
  final List<Map<String, dynamic>>? unarchivedChats;

  const MyChatsPage({super.key, this.unarchivedChats});

  @override
  _MyChatsPageState createState() => _MyChatsPageState();
}

class _MyChatsPageState extends State<MyChatsPage> {
  List<int> selectedIndexes = []; // Track selected items
  List<Map<String, dynamic>> archivedChats = []; // Store archived items
  String selectedCategory = 'All Offers';

  final ChatController chatController = Get.find<ChatController>();
  final UserController _userController = Get.find<UserController>();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // If there are unarchived chats, add them back to the chats list
    // if (widget.unarchivedChats != null) {
    //   chats.addAll(widget.unarchivedChats!);
    // }
    if (_userController.user.value != null) {
      chatController.getAllChats();
    }
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      // _filteredChats = chatController.chats
      //     .where((chat) => chat.title.contains(_searchController.text))
      //     .toList();
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff02005D),
      appBar: AppBar(
        title: const Text(
          'My Chats',
          style: TextStyle(
            fontFamily: "MontserratM",
            fontSize: 24,
            color: Color(0xffFFFFFF),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: const [
          // Padding(
          //   padding: const EdgeInsets.only(right: 20),
          //   child: InkWell(
          //     onTap: () async {
          //       // Navigate to the Archived page and wait for unarchived chats
          //       final unarchivedChats = await Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => ArchivedPage(
          //             archivedChats: archivedChats,
          //           ),
          //         ),
          //       );

          //       // If there are unarchived chats, add them back to the chats list
          //       if (unarchivedChats != null) {
          //         setState(() {
          //           chats.addAll(unarchivedChats);
          //         });
          //       }
          //     },
          //     child: const Row(
          //       children: [
          //         ImageIcon(AssetImage('assets/icons/archive.png'),
          //             size: 24, color: Color(0xffFFFFFF)),
          //         SizedBox(width: 10),
          //         Text("Archived",
          //             style: TextStyle(
          //               fontFamily: "MontserratM",
          //               fontSize: 14,
          //               color: Color(0xffFFFFFF),
          //             )),
          //       ],
          //     ),
          //   ),
          // ),
        ],
        elevation: 0,
        backgroundColor: const Color(0xff02005D),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          await chatController.getAllChats();
        },
        child: Column(
          children: [
            // Search Bar remains unchanged
            Container(
                height: 63,
                color: const Color(0xff02005D),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xff797979), width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                      child: SearchBar(
                        elevation: WidgetStateProperty.resolveWith<double>(
                            (Set<WidgetState> states) => 0.0),
                        hintText: "Search",
                        controller: _searchController,
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) =>
                              const Color(0xff9A9A9A).withOpacity(0.2),
                        ),
                        hintStyle: WidgetStateProperty.resolveWith<TextStyle?>(
                          (Set<WidgetState> states) {
                            return GoogleFonts.montserrat(
                                color: const Color(0xffFFFFFF),
                                fontSize: 14,
                                fontWeight: FontWeight.w300);
                          },
                        ),
                        textStyle: WidgetStateProperty.resolveWith<TextStyle?>(
                          (Set<WidgetState> states) {
                            return GoogleFonts.montserrat(
                                color: const Color(0xffFFFFFF),
                                fontSize: 14,
                                fontWeight: FontWeight.w300);
                          },
                        ),
                        leading: const Padding(
                          padding: EdgeInsets.fromLTRB(9, 0, 4, 0),
                          child: SvgIcon(
                            "assets/icons/search.svg",
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 10),
            // Conditionally show either action bar or category buttons
            // selectedIndexes.isNotEmpty
            //     ? Container(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 16.0, vertical: 16),
            //         color: Colors.white, // Set background to white
            //         child: Row(
            //           children: [
            //             InkWell(
            //               onTap: () => setState(() {
            //                 selectedIndexes.clear(); // Clear selection
            //               }),
            //               child: const ImageIcon(
            //                 AssetImage('assets/icons/back_arrow.png'),
            //                 color: Color(0xffFF8D41),
            //               ),
            //             ),
            //             Padding(
            //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
            //               child: Text(
            //                 '${selectedIndexes.length}',
            //                 style: const TextStyle(
            //                   fontFamily: "MontserratM",
            //                   fontSize: 20,
            //                   color: Color(0xff000000), // Change text color
            //                 ),
            //               ),
            //             ),
            //             const Spacer(), // Align actions to the right
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceAround,
            //               children: [
            //                 Padding(
            //                   padding: const EdgeInsets.only(right: 20),
            //                   child: InkWell(
            //                     onTap: () {
            //                       // Handle delete action
            //                     },
            //                     child: const SvgIcon(
            //                       "assets/icons/trash.svg",
            //                       size: 24,
            //                     ),
            //                   ),
            //                 ),
            //                 Padding(
            //                   padding: const EdgeInsets.only(right: 20),
            //                   child: InkWell(
            //                     onTap: () {
            //                       // Archive selected chats
            //                       setState(() {
            //                         selectedIndexes.sort();
            //                         for (var index in selectedIndexes.reversed) {
            //                           archivedChats.add(chats[index]);
            //                           chats.removeAt(index);
            //                         }
            //                         selectedIndexes.clear();
            //                       });

            //                       // Navigate to the Archived page
            //                       Navigator.push(
            //                         context,
            //                         MaterialPageRoute(
            //                           builder: (context) => ArchivedPage(
            //                               archivedChats: archivedChats),
            //                         ),
            //                       );
            //                     },
            //                     child: const ImageIcon(
            //                       AssetImage('assets/icons/receive-square.png'),
            //                       color: Color(0xff000000),
            //                     ),
            //                   ),
            //                 ),
            //                 Padding(
            //                   padding: const EdgeInsets.only(right: 20),
            //                   child: InkWell(
            //                     onTap: () {
            //                       // Handle mute action - toggle mute state
            //                       setState(() {
            //                         for (var index in selectedIndexes) {
            //                           chats[index]['muted'] =
            //                               !(chats[index]['muted'] as bool);
            //                         }
            //                         selectedIndexes.clear();
            //                       });
            //                     },
            //                     child: const ImageIcon(
            //                       AssetImage('assets/icons/Group 511.png'),
            //                       color: Color(0xff000000),
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       )
            //     :

            // TODO: NEED TO REIMPLEMENT IT AFTER BUY SELL OR OFFER LIST GOES > 100
            // Container(
            //   padding: const EdgeInsets.symmetric(vertical: 8.0),
            //   color: const Color(0xff02005D),
            //   child: SingleChildScrollView(
            //     scrollDirection: Axis.horizontal,
            //     child: Row(
            //       children: [
            //         CategoryButton(
            //           image: 'assets/icons/all.png',
            //           label: 'All Offers',
            //           selected: selectedCategory == 'All Offers',
            //           onTap: () {
            //             setState(() {
            //               selectedCategory = 'All Offers';
            //             });
            //           },
            //         ),
            //         CategoryButton(
            //           image: 'assets/icons/food.png',
            //           label: 'Food',
            //           selected: selectedCategory == 'Food',
            //           onTap: () {
            //             setState(() {
            //               selectedCategory = 'Food';
            //             });
            //           },
            //         ),
            //         CategoryButton(
            //           image: 'assets/icons/tshirt.png',
            //           label: 'Apparel',
            //           selected: selectedCategory == 'Apparel',
            //           onTap: () {
            //             setState(() {
            //               selectedCategory = 'Apparel';
            //             });
            //           },
            //         ),
            //         CategoryButton(
            //           image: 'assets/icons/Bell.png',
            //           label: 'Entertainment',
            //           selected: selectedCategory == 'Entertainment',
            //           onTap: () {
            //             setState(() {
            //               selectedCategory = 'Entertainment';
            //             });
            //           },
            //         ),
            //         CategoryButton(
            //           image: 'assets/icons/ball.png',
            //           label: 'Sports',
            //           selected: selectedCategory == 'Sports',
            //           onTap: () {
            //             setState(() {
            //               selectedCategory = 'Sports';
            //             });
            //           },
            //         ),
            //         CategoryButton(
            //           image: 'assets/icons/ball.png',
            //           label: 'Medicine',
            //           selected: selectedCategory == 'Medicine',
            //           onTap: () {
            //             setState(() {
            //               selectedCategory = 'Medicine';
            //             });
            //           },
            //         ),
            //         CategoryButton(
            //           image: 'assets/icons/Frame 59.png',
            //           label: 'Electronics',
            //           selected: selectedCategory == 'Electronics',
            //           onTap: () {
            //             setState(() {
            //               selectedCategory = 'Electronics';
            //             });
            //           },
            //         ),
            //         CategoryButton(
            //           image: 'assets/icons/ball.png',
            //           label: 'Music',
            //           selected: selectedCategory == 'Music',
            //           onTap: () {
            //             setState(() {
            //               selectedCategory = 'Music';
            //             });
            //           },
            //         ),
            //         // Add more categories if needed
            //       ],
            //     ),
            //   ),
            // ),

            // Chat list
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: (_userController.user.value != null)
                    ? GetBuilder<ChatController>(builder: (controller) {
                        if (chatController.chats.isEmpty &&
                            chatController.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (chatController.chats.isEmpty) {
                          return const Center(child: Text('No chats found'));
                        }

                        var filteredChats = controller.chats.where((model) {
                          var offername =
                              model.offer?.name ?? model.liveOffer?.from ?? "";
                          var searchList =
                              _searchQuery.toLowerCase().split(" ");
                          for (var element in searchList) {
                            if (offername.toLowerCase().contains(element)) {
                              return true;
                            }
                          }
                          return false;
                        }).toList();
                        return chatList(filteredChats);
                      })
                    : const Center(
                        child: Text(
                          "You don't have an account to show chats",
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool hasImage(ChatAndOfferModel chat) {
    if (chat.offer != null) {
      var offer = chat.offer;
      if (offer!.images.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else if (chat.liveOffer != null) {
      return true;
    } else {
      return false;
    }
  }

  ImageProvider _handleImage(ChatAndOfferModel chat) {
    if (chat.offer != null) {
      var offer = chat.offer;
      if (offer!.images.isNotEmpty) {
        return CachedNetworkImageProvider(offer.images.first);
      } else {
        return const AssetImage("assets/icons/Frame 64.png");
      }
    } else if (chat.liveOffer != null) {
      return const AssetImage("assets/images/share_a_cab.png");
    } else {
      return const AssetImage("assets/icons/Frame 64.png");
    }
  }

  String getChatTitle(ChatAndOfferModel chat) {
    return chat.offer?.name.replaceAll("- FROM BRANDS", "") ??
        chat.liveOffer?.from ??
        "No Title";
  }

  ListView chatList(List<ChatAndOfferModel> chats) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        bool isSelected = selectedIndexes.contains(index);
        var chat = chats[index];
        return GestureDetector(
          onLongPress: () {
            // setState(() {
            //   if (!selectedIndexes.contains(index)) {
            //     selectedIndexes.add(index);
            //   }
            // });
          },
          onTap: () {
            setState(() {
              Get.to(() => ChatPage(
                    chat: chat.chat,
                    offer: chat.offer,
                    chatTitle: chat.liveOffer?.to ?? chat.offer?.name ?? "Chat",
                  ))?.then(
                (onValue) {
                  chatController.getAllChats();
                  debugPrint('ChatPage closed:');
                },
              );
              // if (selectedIndexes.isNotEmpty) {
              //   if (isSelected) {
              //     selectedIndexes.remove(index);
              //   } else {
              //     selectedIndexes.add(index);
              //   }
              // }
            });
          },
          child: Container(
            color: isSelected ? const Color(0xffFFEBDF) : Colors.transparent,
            child: ListTile(
              leading: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: (hasImage(chat))
                          ? DecorationImage(
                              image: _handleImage(chat),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: hasImage(chat) ? null : const Color(0xffFFEBDF),
                    ),
                    child: hasImage(chat)
                        ? null
                        : Center(
                            child: Text(
                              getChatTitle(chat).characters.first.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: "MontserratM",
                                fontSize: 20,
                                color: Color(0xffFF8D41),
                              ),
                            ),
                          ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Color(0xffFF8D41)),
                ],
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // todo : change the title to chat.title
                  Expanded(
                    child: Hero(
                      tag: chat.chat.id,
                      child: Text(
                        getChatTitle(chat),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: "MontserratM",
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    DateTimeHelper.timeAgoSince(
                      chat.chat.updatedAt.toIso8601String(),
                    ),
                    style: const TextStyle(
                      fontFamily: "MontserratM",
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  if (chat.chat.messages != null)
                    Expanded(
                      child: Text(
                        _getLastMessage(chat.chat.messages!),
                        style: const TextStyle(
                          fontFamily: "MontserratM",
                          fontSize: 14,
                          color: Color(0xff434343),
                        ),
                        overflow: TextOverflow
                            .ellipsis, // Truncate with ellipsis if long
                      ),
                    ),
                  // if (chat)
                  // const Padding(
                  //   padding: EdgeInsets.only(left: 8.0),
                  //   child: ImageIcon(
                  //     AssetImage('assets/icons/Group 511.png'),
                  //     size: 15,
                  //     color: Color(0xff000000),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLastMessage(List<LastMessageModel>? list) {
    if (list == null) {
      return "";
    }

    if (list.isEmpty) {
      return "";
    }

    return list.last.content;
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
