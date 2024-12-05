import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picapool/functions/chats/chat_controller.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/screens/chats/archive_page.dart';
import 'package:picapool/utils/svg_icon.dart';

class MyChatsPage extends StatefulWidget {
  final List<Map<String, dynamic>>? unarchivedChats;

  const MyChatsPage({super.key, this.unarchivedChats});

  @override
  _MyChatsPageState createState() => _MyChatsPageState();
}

class _MyChatsPageState extends State<MyChatsPage> {
  final List<Map<String, dynamic>> chats = [
    {
      'title': 'LEVI sale',
      'subtitle': 'You: Hi, who all are willing to pool for t...',
      'time': '2:20 PM',
      'image': 'assets/icons/levi.png',
      'muted': false,
    },
    {
      'title': 'KFC offer',
      'subtitle': 'Pranav: I won\'t be able to pay today...',
      'time': '2:40 PM',
      'image': 'assets/icons/levi.png',
      'muted': false,
    },
    // Add more chats as needed
  ];

  List<int> selectedIndexes = []; // Track selected items
  List<Map<String, dynamic>> archivedChats = []; // Store archived items
  String selectedCategory = 'All Offers';

  final ChatController chatController = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();
    // If there are unarchived chats, add them back to the chats list
    if (widget.unarchivedChats != null) {
      chats.addAll(widget.unarchivedChats!);
    }
    chatController.getAllChats();
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () async {
                // Navigate to the Archived page and wait for unarchived chats
                final unarchivedChats = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArchivedPage(
                      archivedChats: archivedChats,
                    ),
                  ),
                );

                // If there are unarchived chats, add them back to the chats list
                if (unarchivedChats != null) {
                  setState(() {
                    chats.addAll(unarchivedChats);
                  });
                }
              },
              child: const Row(
                children: [
                  ImageIcon(AssetImage('assets/icons/archive.png'),
                      size: 24, color: Color(0xffFFFFFF)),
                  SizedBox(width: 10),
                  Text("Archived",
                      style: TextStyle(
                        fontFamily: "MontserratM",
                        fontSize: 14,
                        color: Color(0xffFFFFFF),
                      )),
                ],
              ),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: const Color(0xff02005D),
      ),
      body: Column(
        children: [
          // Search Bar remains unchanged
          Container(
              height: 63,
              color: const Color(0xff02005D),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xff797979), width: 2),
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
          selectedIndexes.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16),
                  color: Colors.white, // Set background to white
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() {
                          selectedIndexes.clear(); // Clear selection
                        }),
                        child: const ImageIcon(
                          AssetImage('assets/icons/back_arrow.png'),
                          color: Color(0xffFF8D41),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '${selectedIndexes.length}',
                          style: const TextStyle(
                            fontFamily: "MontserratM",
                            fontSize: 20,
                            color: Color(0xff000000), // Change text color
                          ),
                        ),
                      ),
                      const Spacer(), // Align actions to the right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: InkWell(
                              onTap: () {
                                // Handle delete action
                              },
                              child: const SvgIcon(
                                "assets/icons/trash.svg",
                                size: 24,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: InkWell(
                              onTap: () {
                                // Archive selected chats
                                setState(() {
                                  selectedIndexes.sort();
                                  for (var index in selectedIndexes.reversed) {
                                    archivedChats.add(chats[index]);
                                    chats.removeAt(index);
                                  }
                                  selectedIndexes.clear();
                                });

                                // Navigate to the Archived page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArchivedPage(
                                        archivedChats: archivedChats),
                                  ),
                                );
                              },
                              child: const ImageIcon(
                                AssetImage('assets/icons/receive-square.png'),
                                color: Color(0xff000000),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: InkWell(
                              onTap: () {
                                // Handle mute action - toggle mute state
                                setState(() {
                                  for (var index in selectedIndexes) {
                                    chats[index]['muted'] =
                                        !(chats[index]['muted'] as bool);
                                  }
                                  selectedIndexes.clear();
                                });
                              },
                              child: const ImageIcon(
                                AssetImage('assets/icons/Group 511.png'),
                                color: Color(0xff000000),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  color: const Color(0xff02005D),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                          label: 'Sports',
                          selected: selectedCategory == 'Sports',
                          onTap: () {
                            setState(() {
                              selectedCategory = 'Sports';
                            });
                          },
                        ),
                        // Add more categories if needed
                      ],
                    ),
                  ),
                ),
          // Chat list
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: GetBuilder<ChatController>(builder: (controller) {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.isNotEmpty) {
                  return Center(child: Text(controller.errorMessage.value));
                }

                if (controller.chats.isEmpty) {
                  return const Center(child: Text('No chats found'));
                }

                return chatList(controller.chats);
              }),
            ),
          ),
        ],
      ),
    );
  }

  ListView chatList(List<Chat> chatList) {
    return ListView.builder(
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        bool isSelected = selectedIndexes.contains(index);
        var chat = chatList[index];
        return GestureDetector(
          onLongPress: () {
            setState(() {
              if (!selectedIndexes.contains(index)) {
                selectedIndexes.add(index);
              }
            });
          },
          onTap: () {
            setState(() {
              if (selectedIndexes.isNotEmpty) {
                if (isSelected) {
                  selectedIndexes.remove(index);
                } else {
                  selectedIndexes.add(index);
                }
              }
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
                      image: DecorationImage(
                        image: AssetImage(chats[0]['image']!),
                        fit: BoxFit.cover,
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
                  Text(
                    chats[0]['title']!,
                    style: const TextStyle(
                      fontFamily: "MontserratM",
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    chats[0]['time']!,
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
                  Expanded(
                    child: Text(
                      chats[0]['subtitle']!,
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
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: ImageIcon(
                      AssetImage('assets/icons/Group 511.png'),
                      size: 15,
                      color: Color(0xff000000),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
