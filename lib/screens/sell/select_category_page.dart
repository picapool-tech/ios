import 'dart:convert';

import 'package:flutter/material.dart';
// Import flutter_svg package
import 'package:get/get.dart';
import 'package:picapool/controllers/category_controller.dart';
import 'package:picapool/utils/routes.dart';
import 'package:picapool/widgets/home/location_widget.dart';
import 'package:picapool/widgets/others/OtherPage1.dart';

class CategorySelectionPage extends StatefulWidget {
  const CategorySelectionPage({super.key});

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  CategoryController get categoryController => Get.find<CategoryController>();

  @override
  void initState() {
    categoryController.getAllCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LocationWidget(
              color: Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: StepIndicator(currentStep: 1),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(30, 20, 0, 20),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('What are you selling?',
                    style: TextStyle(fontSize: 14, fontFamily: "MontserratM"))),
          ),

          Expanded(
            child: GridView.count(
              shrinkWrap: true,
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: <Widget>[
                CategoryCard(
                  label: 'Electronics',
                  imagePath:
                      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
                  onTap: () {
                    Get.toNamed(
                      GetRoutes.sellProductsFormPage,
                      arguments: {'categoryName': 'electronics'},
                    );
                  },
                ),
                CategoryCard(
                  label: 'Clothing',
                  imagePath:
                      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
                  onTap: () {
                    Get.toNamed(GetRoutes.sellProductsFormPage,
                        arguments: {'categoryName': 'clothing'});
                  },
                ),
                CategoryCard(
                  label: 'Sports',
                  imagePath:
                      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
                  onTap: () {
                    Get.toNamed(GetRoutes.sellProductsFormPage,
                        arguments: {'categoryName': 'sports'});
                  },
                ),
                CategoryCard(
                  label: 'Books',
                  imagePath:
                      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
                  onTap: () {
                    Get.toNamed(GetRoutes.sellProductsFormPage,
                        arguments: {'categoryName': 'books'});
                  },
                ),
                CategoryCard(
                  label: 'Vehicle',
                  imagePath:
                      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
                  onTap: () {
                    Get.toNamed(GetRoutes.sellProductsFormPage,
                        arguments: {'categoryName': 'vehicle'});
                  },
                ),
                CategoryCard(
                  label: 'Furniture',
                  imagePath:
                      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
                  onTap: () {
                    Get.toNamed(GetRoutes.sellProductsFormPage,
                        arguments: {'categoryName': 'furniture'});
                  },
                ),
                CategoryCard(
                  label: 'Other',
                  imagePath:
                      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
                  onTap: () {
                    Get.toNamed(GetRoutes.sellProductsFormPage,
                        arguments: {'categoryName': 'other'});
                  },
                ),
              ],
            ),
          ),

          // GetBuilder<CategoryController>(
          //     builder: (CategoryController categoryInstance) {
          //   return categoryInstance.categoriesState == CategoriesState.loaded
          //       ? Expanded(
          //           child: GridView.builder(
          //               shrinkWrap: true,
          //               primary: true,
          //               scrollDirection: Axis.vertical,
          //               gridDelegate:
          //                   const SliverGridDelegateWithFixedCrossAxisCount(
          //                       crossAxisCount: 2),
          //               itemCount: categoryInstance.categoryList.length,
          //               itemBuilder: (context, index) {
          //                 return CategoryCard(
          //                   svgPath:
          //                       categoryInstance.categoryList[index].pic ?? "",
          //                   label:
          //                       categoryInstance.categoryList[index].name ?? "",
          //                   onTap: () => Get.toNamed(
          //                       GetRoutes.sellProductsFormPage,
          //                       arguments: {
          //                         "categoryName":
          //                             categoryInstance.categoryList[index].name
          //                       }),
          //                 );
          //               }),
          //         )
          //       : const LinearProgressIndicator();
          // }),
        
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  CategoryCard(
      {super.key,
      required this.imagePath,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffD4D4D4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 12,
                  height: 12,
                  color: Colors.amber,
                  child: Image.memory(base64Decode(imagePath))),
              const SizedBox(height: 8),
              Text(label,
                  style:
                      const TextStyle(fontSize: 14, fontFamily: "MontserratR")),
            ],
          ),
        ),
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  final int currentStep;

  StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          3,
          (index) => Container(
                width: 90,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: currentStep > index ? Colors.orange : Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
              )),
    );
  }
}
