import 'package:flutter/material.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/loading/list_loading.dart';

class ChatLoading extends StatelessWidget {
  final int count;
  final Color? color;

  const ChatLoading({
    super.key,
    this.count = 10,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListLoading(
      count: count,
      child: loadingContainer(),
    );
  }

  Widget loadingContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                width: double.infinity,
                height: 20,
                decoration: roundedContainer(radius: 2).copyWith(
                  color: color ?? Colors.grey[300],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                width: kBottomNavigationBarHeight,
                height: 10,
                decoration: roundedContainer(radius: 0).copyWith(
                  color: color ?? Colors.grey[300],
                ),
              ),
            ],
          )),
        ],
      ),
    );

    // Container(
    //   margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    //   width: double.infinity,
    //   height: 60,
    //   padding: const EdgeInsets.all(10),
    //   decoration: roundedContainer().copyWith(
    //     color: Colors.grey[300],
    //   ),
    // );
  }
}
