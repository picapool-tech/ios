import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picapool/utils/theme.dart';

class ProductTable extends StatefulWidget {
  final Map<String, dynamic> data;
  final List<String>? priorityFields; // Optional list of fields to show first

  const ProductTable({
    super.key,
    required this.data,
    this.priorityFields,
  });

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable>
    with TickerProviderStateMixin {
  late List<String> allKeys;
  // bool _isExpanded = false;
  // int get initialFieldCount => _expanded
  //     ? allKeys.length
  //     : (widget.priorityFields?.length ?? min(2, allKeys.length));

  // bool get showExpandButton => allKeys.length > initialFieldCount && !_expanded;

  @override
  Widget build(BuildContext context) {
    // Create the table rows from data
    List<TableRow> allRows = [];

    // Add all rows up to initialFieldCount or all if expanded
    // for (int i = 0;
    //     i < ((_expanded) ? allKeys.length : initialFieldCount);
    //     i++) {
    //   if (i < allKeys.length) {
    //     final key = allKeys[i];

    //     allRows.add(
    //         _buildRow(_formatKey(key), _formatValue(key, widget.data[key])));
    //   }
    // }
    for (int i = 0; i < allKeys.length; i++) {
      if (i < allKeys.length) {
        final key = allKeys[i];

        allRows.add(
            _buildRow(_formatKey(key), _formatValue(key, widget.data[key])));
      }
    }

    return Table(
      border: TableBorder.all(
        borderRadius: BorderRadius.circular(6),
        color: AppTheme.currentTheme.disabledColor,
      ),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: allRows,
    );
    // Stack(
    //   children: [
    //     Column(
    //       children: [
    //         if (showExpandButton) const SizedBox(height: 30),
    //       ],
    //     ),
    //     if (showExpandButton)
    //       Positioned(
    //         left: 0,
    //         right: 0,
    //         bottom: 20,
    //         child: InkWell(
    //           onTap: () {
    //             setState(() {
    //               _expanded = !_expanded;
    //             });
    //           },
    //           child: Container(
    //             height: 30,
    //             decoration: BoxDecoration(
    //               gradient: LinearGradient(
    //                 begin: Alignment.topCenter,
    //                 end: Alignment.bottomCenter,
    //                 colors: [
    //                   Colors.white.withOpacity(0.2),
    //                   Colors.white,
    //                   Colors.white,
    //                 ],
    //                 stops: const [0, 0.4, 1.0],
    //               ),
    //             ),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               children: [
    //                 Text(
    //                   _expanded ? 'Show Less' : 'Show More',
    //                   style: TextStyle(
    //                     color: AppTheme.currentTheme.colorScheme.secondary,
    //                     fontWeight: FontWeight.bold,
    //                   ),
    //                 ),
    //                 Icon(
    //                   _expanded
    //                       ? Icons.keyboard_arrow_up
    //                       : Icons.keyboard_arrow_down,
    //                   color: AppTheme.currentTheme.colorScheme.secondary,
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //   ],
    // );
  }

  @override
  void didUpdateWidget(ProductTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the data or priority fields changed, re-initialize the keys
    if (widget.data != oldWidget.data ||
        widget.priorityFields != oldWidget.priorityFields) {
      _initializeAndSortKeys();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAndSortKeys();
  }

  TableRow _buildRow(String key, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value),
        ),
      ],
    );
  }

  // Format keys to be more readable
  String _formatKey(String key) {
    // Split by underscores and then insert spaces at camelCase boundaries

    final words = key.split('_').expand((part) {
      final camelRegex = RegExp(r'(?<=[a-z])(?=[A-Z])');
      return part.split(camelRegex);
    }).toList();
    return words
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  // Format values based on their type
  String _formatValue(String key, dynamic value) {
    if (value == null) return 'N/A';

    // Format price with currency symbol
    if (key == 'price' && value is num) {
      return '\$${value.toStringAsFixed(2)}';
    }

    // Format dates
    if (value is DateTime) {
      return DateFormat('MMM d, yyyy').format(value);
    }

    // Convert bool to Yes/No
    if (value is bool) {
      return value ? 'Yes' : 'No';
    }

    return value.toString();
  }

  void _initializeAndSortKeys() {
    // Get all keys from data
    allKeys = widget.data.keys.toList();

    // Sort keys to prioritize certain fields if specified
    if (widget.priorityFields != null) {
      allKeys.sort((a, b) {
        final aIndex = widget.priorityFields!.indexOf(a);
        final bIndex = widget.priorityFields!.indexOf(b);

        // If both keys are in priorityFields, sort by their order
        if (aIndex >= 0 && bIndex >= 0) return aIndex - bIndex;
        // If only a is in priorityFields, it comes first
        if (aIndex >= 0) return -1;
        // If only b is in priorityFields, it comes first
        if (bIndex >= 0) return 1;
        // If neither is in priorityFields, keep original order
        return 0;
      });
    }
  }
}
