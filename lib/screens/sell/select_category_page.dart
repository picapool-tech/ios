
import 'package:flutter/material.dart';
// Import flutter_svg package
import 'package:get/get.dart';
import 'package:picapool/controllers/category_controller.dart';
import 'package:picapool/utils/routes.dart';
import 'package:picapool/utils/svg_icon.dart';
import 'package:picapool/widgets/home/location_widget.dart';

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
          const Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0, // Makes cells square
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryCard(
                    label: categories[index].name,
                    imagePath: categories[index].imagePath,
                    onTap: () {
                      Get.toNamed(
                        GetRoutes.sellProductsFormPage,
                        arguments: {'categoryName': categories[index].name.toLowerCase()},
                      );
                    },
                  );
                },
              ),
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

  const CategoryCard({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffD4D4D4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40, // Increased size for better visibility
              height: 40, // Increased size for better visibility
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgIcon(
                imagePath,
                size: 36,
                // fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: "MontserratR",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({super.key, required this.currentStep});

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

final List<CategoryModel> categories = [
  CategoryModel(
    name: 'Electronics',
    imagePath: 'assets/icons/electronics.svg',
  ),
  CategoryModel(
    name: 'Clothing',
    imagePath: 'assets/icons/clothes.svg',
  ),
  CategoryModel(
    name: 'Sports',
    imagePath: 'assets/icons/sports-1.svg',
  ),
  CategoryModel(
    name: 'Books',
    imagePath: 'assets/icons/books-1.svg',
  ),
  CategoryModel(
    name: 'Vehicle',
    imagePath: 'assets/icons/vehicle-1.svg',
  ),
  CategoryModel(
    name: 'Furniture',
    imagePath: 'assets/icons/furniture.svg',
  ),
  CategoryModel(
    name: 'Other',
    imagePath: 'assets/icons/new.svg',
  ),
];

class CategoryModel {
  final String name;
  final String imagePath;

  CategoryModel({
    required this.name,
    required this.imagePath,
  });
}
