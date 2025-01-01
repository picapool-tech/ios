import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:picapool/controllers/brand_controller.dart';
import 'package:picapool/screens/location_fetch_screen.dart';
import 'package:picapool/utils/svg_icon.dart';
import 'package:picapool/screens/sell/select_category_page.dart';
import 'package:picapool/widgets/brands/brand_grid.dart';

class BrandListsPage extends StatefulWidget {
  const BrandListsPage({super.key});

  @override
  State<BrandListsPage> createState() => BrandListsPageState();
}

class BrandListsPageState extends State<BrandListsPage> {
  BrandController get brandController => Get.find();

  @override
  void initState() {
    brandController.getAllBrands();
    super.initState();
  }

  //TODO: Implement location services
  String currentLocation = "6th st, Connaught place, New Delhi, India";

  void _updateLocation(String location) {
    setState(() {
      currentLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // bottomNavigationBar: NewBottomBarBrand(),
      body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GetBuilder<BrandController>(
              builder: (BrandController brandInstance) {
            return Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    const Row(children: <Widget>[
                      Expanded(
                          child: Divider(
                        indent: 50,
                        color: Color(0xffFF8D41),
                      )),
                      Text(
                        "  Brands near you  ",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "MontserratM",
                            fontSize: 14),
                      ),
                      Expanded(
                          child: Divider(
                        endIndent: 50,
                        color: Color(0xffFF8D41),
                      )),
                    ]),
                    const SizedBox(height: 20),
                    Expanded(child: BrandGrid())
                  ],
                ),
              ],
            );
          })),
    );
  }
}
