import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/image_with_top_widgets.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/utils/theme.dart';

class LivePoolingListItem extends StatelessWidget {
  const LivePoolingListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: AppTheme.currentTheme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageWithTopWidgets(
                imageUrl: "https://i.sstatic.net/eMW7A.jpg",
                timeSinceAgo: DateTimeHelper.timeAgoSince(
                  DateTime.now().toIso8601String(),
                ),
                isSold: false,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "Sharbati Wheat Fresh from Farms",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(
                height: 4,
              ),
              RichText(
                text: TextSpan(
                  text: '₹ 180/kg ',
                  style: const TextStyle(
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  children: [
                    // if (product.offerPrice != null)
                    TextSpan(
                      text: "₹ 250/kg",
                      style: Get.textTheme.titleSmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      spacing: 10,
                      children: [
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: 0.7,
                                  strokeWidth: 2,
                                  backgroundColor: AppTheme
                                      .currentTheme.colorScheme.secondary
                                      .lighten(76),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.currentTheme.colorScheme.secondary
                                        .lighten(60)
                                        .darken(),
                                  ),
                                  constraints:
                                      BoxConstraints.tight(Size(20, 20)),
                                ),
                                Text(
                                  "15",
                                  style: Get.textTheme.labelSmall?.copyWith(
                                    color: AppTheme
                                        .currentTheme.colorScheme.secondary
                                        .lighten(50),
                                  ),
                                )
                              ],
                            ),
                            Text(
                              "D",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: 0.7,
                                  strokeWidth: 2,
                                  backgroundColor: AppTheme
                                      .currentTheme.colorScheme.secondary
                                      .lighten(76),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.currentTheme.colorScheme.secondary
                                        .lighten(60)
                                        .darken(),
                                  ),
                                  constraints:
                                      BoxConstraints.tight(Size(20, 20)),
                                ),
                                Text(
                                  "15",
                                  style: Get.textTheme.labelSmall?.copyWith(
                                    color: AppTheme
                                        .currentTheme.colorScheme.secondary
                                        .lighten(50),
                                  ),
                                )
                              ],
                            ),
                            Text(
                              "D",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: 0.7,
                                  strokeWidth: 2,
                                  backgroundColor: AppTheme
                                      .currentTheme.colorScheme.secondary
                                      .lighten(76),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.currentTheme.colorScheme.secondary
                                        .lighten(60)
                                        .darken(),
                                  ),
                                  constraints:
                                      BoxConstraints.tight(Size(20, 20)),
                                ),
                                Text(
                                  "15",
                                  style: Get.textTheme.labelSmall?.copyWith(
                                    color: AppTheme
                                        .currentTheme.colorScheme.secondary
                                        .lighten(50),
                                  ),
                                )
                              ],
                            ),
                            Text(
                              "D",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PicaPrimaryButton(
                      text: "Join",
                      onPressed: () {},
                      isLoading: false.obs,
                      isSmall: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
