import 'package:flutter/material.dart';
import 'package:picapool/common/widgets/image_widget.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/utils/theme.dart';

class OfferListItem extends StatefulWidget {
  final Offer offer;
  final bool isExpanded;
  const OfferListItem({
    super.key,
    required this.offer,
    this.isExpanded = false,
  });

  @override
  State<OfferListItem> createState() => _OfferListItemState();
}

class _OfferListItemState extends State<OfferListItem> {
  Tag? get getOfferTag => widget.offer.tags?.firstOrNull;

  TextTheme get textTheme => Theme.of(context).textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: roundedContainer().copyWith(
        border: Border.all(
          color: AppTheme.light.dividerColor,
        ),
      ),
      constraints: const BoxConstraints(
        minHeight: 120,
      ),
      padding: const EdgeInsets.all(10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title and offer tags with description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.offer.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge,
                  ),
                  if (getOfferTag != null) ...[
                    const SizedBox(
                      height: 6,
                    ),
                    tagChipLabel(),
                  ] else
                    Text(
                      widget.offer.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),

                  // tag showing if not then 1 line description....
                  const SizedBox(
                    height: 6,
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.orange,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        DateTimeHelper.formatDateTimeExpiry(
                          widget.offer.expiryAt,
                        ),
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: "MontserratM",
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            // offer image.
            ImageWidget(
              imageUrl: widget.offer.images.lastOrNull ?? "",
              fallBackAssetImageUrl: "assets/images/request_vicinity.png",
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  Widget tagChipLabel() {
    return Container(
      decoration: roundedContainer().copyWith(
        color: AppTheme.light.primaryColorLight.withAlpha(100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageWidget(
            imageUrl: getOfferTag!.icon,
            fallBackAssetImageUrl: "",
            width: 15,
            height: 15,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            getOfferTag!.tag,
            style: textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
