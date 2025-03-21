import 'package:flutter/material.dart';
import 'package:picapool/core/shimmer.dart';
import 'package:picapool/utils/theme.dart';

class LocationLoading extends StatelessWidget {
  const LocationLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.1),
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      highlightColor: Colors.grey[50]!,
      direction: ShimmerDirection.ltr,
      child: locationLoadingWidget(context),
    );
  }

  Widget locationLoadingWidget(BuildContext context) {
    return Row(
      children: [
        Container(
          alignment: Alignment.topLeft,
          width: MediaQuery.sizeOf(context).width * 0.75,
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.25,
                          height: 20,
                          decoration: roundedContainer().copyWith(
                            color: Colors.grey[300],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.35,
                      height: 20,
                      decoration: roundedContainer().copyWith(
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
