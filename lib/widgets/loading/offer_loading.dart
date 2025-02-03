import 'package:flutter/material.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/loading/list_loading.dart';

class OfferLoading extends StatelessWidget {
  final int count;

  const OfferLoading({
    super.key,
    this.count = 5,
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.all(10),
      decoration: roundedContainer().copyWith(
        color: Colors.grey[300],
      ),
    );
  }
}
