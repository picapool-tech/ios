import 'package:flutter/material.dart';

class EmptyStates extends StatelessWidget {
  final String? customMessage;
  const EmptyStates({
    super.key,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/buy_and_sell/empty_state.png",
            width: MediaQuery.sizeOf(context).width * 0.5,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            customMessage ?? "No products nearby",
          )
        ],
      ),
    );
  }
}
