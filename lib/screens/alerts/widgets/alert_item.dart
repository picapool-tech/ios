import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/alerts/widgets/caption_text_with_icon.dart';
import 'package:picapool/screens/alerts/widgets/count_down_timer.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/loading/image_loading.dart';

class AlertListItem extends StatelessWidget {
  final Offer offer;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onJoinChat;
  final RxBool isLoading;
  final VoidCallback? onExpired;

  const AlertListItem({
    Key? key,
    required this.offer,
    required this.isExpanded,
    required this.onTap,
    required this.onJoinChat,
    required this.isLoading,
    this.onExpired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
        decoration: roundedContainer().copyWith(
          color: AppTheme.currentTheme.scaffoldBackgroundColor,
          border: Border.all(
            color: AppTheme.currentTheme.dividerColor,
          ),
        ),
        child: 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with image and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and basic info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleWithAdditionalText(
                        titleText: offer.name.replaceAll("- FROM BRANDS", ""),
                        additionalText: DateTimeHelper.timeAgoSince(
                          offer.createdAt.toIso8601String(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildTagInfo(),
                      const SizedBox(height: 8),
                      CaptionTextWithIcon(
                        icon: Icons.access_time,
                        label: CountdownTimer(
                          expiryTime: offer.expiryAt,
                          onExpired: onExpired,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Offer image
                _buildOfferImage(),
              ],
            ),
            // Expanded content when isExpanded is true

            AnimatedSlide(
              offset: isExpanded ? Offset.zero : const Offset(0, -0.2),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: isExpanded ? 1.0 : 0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: SizedBox(
                    width: double.infinity,
                    height: isExpanded ? null : 0,
                    child:
                        isExpanded ? _expandedView() : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),

            const Divider(),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xffFF8D41),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    isExpanded ? "Hide Details" : "See Details",
                    style: TextStyle(
                      color: AppTheme.currentTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Widget _buildOfferImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 80,
        height: 80,
        child: (offer.images.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: offer.images.first,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: ImageLoading(
                    width: 80,
                    height: 80,
                  ),
                ),
                errorWidget: (context, error, _) => Image.asset(
                  "assets/icons/alert_image.png",
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                "assets/images/request_vicinity.png",
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildTagInfo() {
    if (offer.tags != null && offer.tags!.isNotEmpty) {
      return Row(
        children: [
          CachedNetworkImage(
            imageUrl: offer.tags!.first.icon,
            width: 15,
            height: 15,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              offer.tags!.first.tag,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: "MontserratM",
                color: Color(0xff7B7B7B),
              ),
            ),
          ),
        ],
      );
    } else {
      return Text(
        offer.desc,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _expandedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            offer.desc,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        PicaPrimaryButton(
          onPressed: onJoinChat,
          text: 'Join Chat',
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class TitleWithAdditionalText extends StatelessWidget {
  final String titleText;
  final String additionalText;
  const TitleWithAdditionalText({
    super.key,
    required this.titleText,
    required this.additionalText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titleText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Get.textTheme.titleMedium,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          additionalText,
          style: Get.textTheme.labelSmall,
        ),
      ],
    );
  }
}
