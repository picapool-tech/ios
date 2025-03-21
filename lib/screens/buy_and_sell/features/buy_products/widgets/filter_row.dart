import 'package:flutter/widgets.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/filter_row_item.dart';
import 'package:picapool/screens/buy_and_sell/values/filter_data.dart';

class FilterRow extends StatefulWidget {
  final void Function(FilterDataEnum selectedFilter) onSelected;

  const FilterRow({
    super.key,
    required this.onSelected,
  });

  @override
  State<FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<FilterRow> {
  FilterDataEnum? selected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          FilterDataEnum.values.length,
          (index) {
            var filterData = FilterDataEnum.values[index];
            return FilterRowItem(
              filterData: filterData,
              isSelected: selected != null ? selected == filterData : false,
              onClick: (selectedRow) {
                widget.onSelected(selectedRow);
                setState(() {
                  selected = selectedRow;
                });
              },
              isFirst: index == 0,
            );
          },
          growable: false,
        ),
      ),
    );
  }
}
