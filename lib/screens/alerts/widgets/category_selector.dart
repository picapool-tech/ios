import 'package:flutter/material.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/screens/alerts/widgets/category_button.dart';

class CategorySelector extends StatelessWidget {
  final ScrollController scrollController;
  final int selectedCategory;
  final List<Tag> tags;
  final Function(int) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.scrollController,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All Offers category
          CategoryButton(
            image: "",
            assetImage: 'assets/icons/all.png',
            label: 'All Offers',
            selected: selectedCategory == 0,
            onTap: () => onCategorySelected(0),
          ),
          // Tag-based categories
          ...List.generate(
            tags.length,
            (index) {
              var tag = tags[index];
              return CategoryButton(
                image: tag.icon,
                label: tag.tag,
                selected: selectedCategory == index + 1,
                onTap: () => onCategorySelected(index + 1),
              );
            },
          ),
        ],
      ),
    );
  }
}