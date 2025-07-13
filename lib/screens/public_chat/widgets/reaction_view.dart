import 'package:flutter/material.dart';

class ReactionView extends StatelessWidget {
  final String reaction;
  final int count;
  final bool showCount;
  const ReactionView({
    super.key,
    required this.reaction,
    required this.count,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            reaction,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          if (count > 1 && showCount) ...[
            SizedBox(width: 2),
            Text(
              "$count",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}
