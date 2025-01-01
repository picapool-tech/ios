import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picapool/screens/location_fetch_screen.dart';
import 'package:picapool/utils/svg_icon.dart';
import 'package:picapool/widgets/home/location_widget.dart';

class ExploreWidget extends StatefulWidget {
  const ExploreWidget({
    super.key,
    required this.onSearch,
  });

  final void Function(String query) onSearch;

  @override
  State<ExploreWidget> createState() => _ExploreWidgetState();
}

bool isDark = false;

class _ExploreWidgetState extends State<ExploreWidget> {
  String currentLocation = "6th st, Connaught place, New Delhi, India";
  void _updateLocation(String location) {
    setState(() {
      currentLocation = location;
    });
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      // color: const Color(0xff02005D),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SvgPicture.asset(
            "assets/images/background.svg",
            width: size.width,
            height: size.width * 0.5,
            allowDrawingOutsideViewBox: true,
            fit: BoxFit.fill,
          ),
          SafeArea(
            child: Container(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LocationScreen(),
                            ),
                          );
                          if (result != null) {
                            _updateLocation(result);
                          }
                        },
                        child: const LocationWidget(),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                          child: SearchBar(
                            elevation: WidgetStateProperty.resolveWith<double>(
                                (Set<WidgetState> states) => 0.0),
                            hintText: "Find Offers and Brands",
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) =>
                                  const Color(0xff9A9A9A).withOpacity(0.2),
                            ),
                            onChanged: widget.onSearch,
                            controller: _searchController,
                            hintStyle:
                                WidgetStateProperty.resolveWith<TextStyle?>(
                              (Set<WidgetState> states) {
                                return GoogleFonts.montserrat(
                                    color: const Color(0xffFFFFFF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300);
                              },
                            ),
                            textStyle:
                                WidgetStateProperty.resolveWith<TextStyle?>(
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
                            trailing: (_searchController.text.isNotEmpty)
                                ? Iterable.generate(1, (index) {
                                    return IconButton(
                                      onPressed: () {
                                        // setState(() {
                                        widget.onSearch("");
                                        _searchController.clear();
                                        // });
                                      },
                                      icon: const SvgIcon(
                                        "assets/icons/cross_icon.svg",
                                        size: 24,
                                      ),
                                    );
                                  }).toList()
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
