import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picapool/utils/svg_icon.dart';

class ArchivedPage extends StatefulWidget {
  final List<Map<String, dynamic>> archivedChats;

  const ArchivedPage({super.key, required this.archivedChats});

  @override
  _ArchivedPageState createState() => _ArchivedPageState();
}

class _ArchivedPageState extends State<ArchivedPage> {
  List<int> selectedIndexes = []; // Track selected items
  String selectedCategory = 'All Offers';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Archived',
          style: TextStyle(
            fontFamily: "MontserratM",
            fontSize: 24,
            color: Color(0xff000000),
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Search Bar UI
          Container(
              height: 63,
              color: const Color(0xffFFFFFF),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                              color: const Color(0xff313131),
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
          // Conditionally show either action bar or category buttons
          selectedIndexes.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
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
                                List<Map<String, dynamic>> unarchivedChats = [];
                                setState(() {
                                  selectedIndexes.sort();
                                  for (var index in selectedIndexes.reversed) {
                                    unarchivedChats
                                        .add(widget.archivedChats[index]);
                                    widget.archivedChats.removeAt(index);
                                  }
                                  selectedIndexes.clear();
                                });

                                // Pass the unarchived chats back to the MyChatsPage
                                Navigator.pop(context, unarchivedChats);
                              },
                              child: const ImageIcon(
                                AssetImage('assets/icons/unarchive.png'),
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
                                    widget.archivedChats[index]['muted'] =
                                        !(widget.archivedChats[index]['muted']
                                            as bool);
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
                  color: const Color(0xffFFFFFF),
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
          // Archived chat list
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: ListView.builder(
                itemCount: widget.archivedChats.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedIndexes.contains(index);
                  bool isMuted = widget.archivedChats[index]['muted'] as bool;
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
                      color:
                          isSelected ? const Color(0xffFFEBDF) : Colors.transparent,
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
                                  image: AssetImage(
                                      widget.archivedChats[index]['image']!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: Color(0xffFF8D41)),
                          ],
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.archivedChats[index]['title']!,
                              style: const TextStyle(
                                fontFamily: "MontserratM",
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              widget.archivedChats[index]['time']!,
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
                                widget.archivedChats[index]['subtitle']!,
                                style: const TextStyle(
                                  fontFamily: "MontserratM",
                                  fontSize: 14,
                                  color: Color(0xff434343),
                                ),
                                overflow: TextOverflow
                                    .ellipsis, // Truncate with ellipsis
                              ),
                            ),
                            if (isMuted)
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final bool selected;
  final String image;
  final VoidCallback onTap;

  const CategoryButton({super.key, 
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
