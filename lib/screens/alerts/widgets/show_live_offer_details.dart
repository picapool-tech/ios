import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:picapool/features/chats/chat_api.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/chats/values/enums.dart';
import 'package:picapool/screens/alerts/widgets/alert_item.dart';
import 'package:picapool/screens/alerts/widgets/caption_text_with_icon.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:picapool/utils/theme.dart';

// Circular list implementation for dashed line
class CircularIntervalList<T> {
  final List<T> _values;
  int _index = 0;

  CircularIntervalList(this._values);

  T get next {
    if (_index >= _values.length) {
      _index = 0;
    }
    return _values[_index++];
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines
    for (double y = 10; y < size.height; y += 20) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw vertical grid lines
    for (double x = 10; x < size.width; x += 20) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Add some random "roads"
    final roadPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Horizontal roads
    for (double y = 40; y < size.height; y += 50) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        roadPaint,
      );
    }

    // Vertical roads
    for (double x = 50; x < size.width; x += 70) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        roadPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter to draw route line
class RoutePainter extends CustomPainter {
  final String fromLocation;
  final String toLocation;

  RoutePainter({
    this.fromLocation = 'Start',
    this.toLocation = 'End',
  });

  // Create a dashed path
  Path dashPath(
    Path source, {
    required CircularIntervalList<double> dashArray,
  }) {
    final Path dest = Path();
    for (final pathMetric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final double len = dashArray.next;
        if (draw) {
          dest.addPath(
            pathMetric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw main route between points
    final paint = Paint()
      ..color = Colors.blue.shade500
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(30, 72);

    // Create a more realistic path with multiple curves
    // Simulate a real driving route with turns
    final double midX = size.width / 2;
    final double quarterX = size.width / 4;
    final double threeQuarterX = size.width * 3 / 4;

    path.cubicTo(
      quarterX, 90, // First control point
      quarterX, 30, // Second control point
      midX, 30, // End point of first curve
    );

    path.cubicTo(
      threeQuarterX, 30, // First control point
      threeQuarterX, 90, // Second control point
      size.width - 30, 72, // End point of second curve
    );

    // Draw main route path
    canvas.drawPath(path, paint);

    // Draw dashed car path
    final dashPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashedPath = dashPath(
      path,
      dashArray: CircularIntervalList<double>([8, 4]),
    );

    canvas.drawPath(dashedPath, dashPaint);

    // Draw car icon at path position
    final carIconPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    // Calculate position along path (around 40% of the way)
    final pathMetrics = path.computeMetrics().first;
    final carPosition =
        pathMetrics.getTangentForOffset(pathMetrics.length * 0.4)!;

    // Draw car icon
    canvas.save();
    canvas.translate(carPosition.position.dx, carPosition.position.dy);
    canvas.rotate(carPosition.angle);

    // More detailed car shape
    final carPath = Path();
    // Car body
    carPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 14, height: 8),
      const Radius.circular(4),
    ));
    // Car roof
    carPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -2), width: 8, height: 4),
      const Radius.circular(2),
    ));

    canvas.drawPath(carPath, carIconPaint);

    // Car wheels
    final wheelPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(-4, 4), 1.5, wheelPaint);
    canvas.drawCircle(const Offset(4, 4), 1.5, wheelPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ShowLiveOfferDetails extends StatefulWidget {
  final int liveOfferId;
  const ShowLiveOfferDetails({
    super.key,
    required this.liveOfferId,
  });

  @override
  State<ShowLiveOfferDetails> createState() => _ShowLiveOfferDetailsState();
}

class _ShowLiveOfferDetailsState extends State<ShowLiveOfferDetails> {
  final LiveOfferController _liveOfferController =
      Get.find<LiveOfferController>();

  final ChatController _chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_liveOfferController.liveOffer.value == null &&
          _liveOfferController.liveofferState ==
              GetLiveOfferState.liveofferLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (_liveOfferController.liveOffer.value == null) {
        return const Center(
          child: Text('No offer details available'),
        );
      }

      var offer = _liveOfferController.liveOffer.value;

      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Yay! you've found a new ride",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.all(15),
              decoration: roundedContainer().copyWith(
                color: AppTheme.currentTheme.scaffoldBackgroundColor,
                border: Border.all(color: AppTheme.currentTheme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and time
                  TitleWithAdditionalText(
                    titleText: "Cab Share",
                    additionalText: DateTimeHelper.timeAgoSince(
                      offer!.updatedAt!.toIso8601String(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tags for seats and user
                  _buildTagInfo(offer),

                  const SizedBox(height: 12),

                  // From -> To with car icon
                  CaptionTextWithIcon(
                    icon: Icons.location_on,
                    label: Expanded(
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            text: "Pickup: ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: offer.fromAddress ?? 'Location',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // To -> From with car icon
                  CaptionTextWithIcon(
                    color: Colors.red,
                    icon: Icons.location_on,
                    label: Expanded(
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            text: "Drop: ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: offer.toAddress ?? 'Location',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Map showing route
                  _buildRouteMap(offer),

                  const SizedBox(height: 16),

                  // Join ride button
                  SizedBox(
                    width: double.infinity,
                    child: PicaPrimaryButton(
                      onPressed: () async {
                        Get.back();
                        var chatController = Get.find<ChatController>();
                        ChatAndOfferModel? chat = await chatController
                            .getChatFromLiveOfferId(widget.liveOfferId);
                        if (chat != null) {
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  chat: chat.chat,
                                  chatTitle:
                                      chat.liveOffer?.from ?? "Cab Share",
                                  liveOffer: chat.liveOffer,
                                  offer: chat.offer,
                                ),
                              ),
                            );
                          }
                        } else {
                          Get.snackbar(
                            'Error',
                            'Unable to join the ride',
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                      text: "Join this Ride",
                      isLoading: _chatController
                          .getLoadingState(ChatLoadingEnums.getLiveOfferChat),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _liveOfferController.getLiveOffer("${widget.liveOfferId}");
    });
  }

  // Helper to make address labels shorter
  String _abbreviateAddress(String address) {
    // If address is longer than 10 chars, truncate and add ellipsis
    if (address.length > 10) {
      return "${address.substring(0, 10)}...";
    }
    return address;
  }

  // Map with route between locations
  Widget _buildRouteMap(dynamic offer) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Map background
            Container(
              color: const Color(0xFFF2F2F7),
            ),

            // Grid lines to simulate map
            CustomPaint(
              size: const Size(double.infinity, 150),
              painter: MapGridPainter(),
            ),

            // Route indicator overlay
            Positioned.fill(
              child: CustomPaint(
                painter: RoutePainter(
                  // Pass actual addresses to display on the route
                  fromLocation: offer.fromAddress ?? 'Start',
                  toLocation: offer.toAddress ?? 'End',
                ),
              ),
            ),

            // Origin marker
            Positioned(
              left: 20,
              top: 60,
              child: Column(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      // Show abbreviated address
                      _abbreviateAddress(offer.fromAddress ?? "Start"),
                      style:
                          TextStyle(fontSize: 10, color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),

            // Destination marker
            Positioned(
              right: 20,
              top: 60,
              child: Column(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 24,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      // Show abbreviated address
                      _abbreviateAddress(offer.toAddress ?? "End"),
                      style: const TextStyle(fontSize: 10, color: Colors.red),
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

  // Simple tag widget
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  // Info tags (seats, offered by)
  Widget _buildTagInfo(offer) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildTag("${offer.seats} seats", Colors.blue.shade100),
        _buildTag("Cab Share", Colors.orange.shade100),
      ],
    );
  }
}
