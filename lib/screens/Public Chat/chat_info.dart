import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/chats/chat_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:picapool/utils/date_time_helper.dart';

class ChatInfo extends StatefulWidget {
  final Offer? offer;

  final int chatId;

  final int creatorId;
  const ChatInfo({
    super.key,
    required this.chatId,
    required this.creatorId,
    this.offer,
  });

  @override
  State<ChatInfo> createState() => _ChatInfoState();
}

class _ChatInfoState extends State<ChatInfo> {
  final ChatController _chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Chat Info'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: false,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            if (widget.offer != null)
              SliverToBoxAdapter(
                child: offerCard(
                  offer: widget.offer!,
                ),
              ),
          ];
        },
        body: Column(
          children: [
            Expanded(
              child: GetBuilder(
                  init: _chatController,
                  builder: (controller) {
                    if (_chatController.isLoading.value &&
                        _chatController.usersInChat.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (_chatController.usersInChat.isEmpty &&
                        !_chatController.isLoading.value) {
                      return const Center(
                        child: Text('No users in chat'),
                      );
                    }

                    return ListView.builder(
                      itemCount: _chatController.usersInChat.length,
                      itemBuilder: (context, index) {
                        final user =
                            _chatController.usersInChat.values.elementAt(index);
                        return userListItem(user);
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      _chatController.getAllUsersInChat(widget.chatId);
    });
  }

  Widget offerCard({
    required Offer offer,
  }) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    offer.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  DateTimeHelper.timeAgoSince(
                      offer.createdAt.toIso8601String()),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Subtitle
            Text(
              offer.desc,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Image Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Icon with Label
                      // _buildIconLabel(Icons.fastfood, category),
                      // const SizedBox(width: 16),
                      _buildIconLabel(Icons.timer,
                          DateTimeHelper.formatDateTimeExpiry(offer.expiryAt)),
                      const SizedBox(height: 10),
                      _buildIconLabel(
                          Icons.location_on,
                          offer.radius != null
                              ? "${offer.radius} m"
                              : "Unknown"),
                      const SizedBox(height: 10),
                      _buildIconLabel(Icons.group,
                          "${_chatController.usersInChat.length.toString()} users"),
                    ],
                  ),
                ),
                // Offer Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (offer.images.isEmpty)
                      ? Image.asset(
                          "assets/images/request_vicinity.png",
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          width: MediaQuery.of(context).size.width * 0.5,
                          imageUrl: offer.images.first,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                ),
              ],
            ),
            // Column(
            //   children: [
            //     ElevatedButton.icon(
            //       onPressed: () {},
            //       style: ElevatedButton.styleFrom(
            //         foregroundColor: Colors.white,
            //         backgroundColor: Colors.orange,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //       ),
            //       icon: const Icon(Icons.open_in_new, size: 16),
            //       label: const Text("STORE"),
            //     ),
            //     const SizedBox(height: 8),
            //     TextButton(
            //       onPressed: () {},
            //       child: const Text(
            //         "Terms & cond.",
            //         style: TextStyle(color: Colors.grey),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget userListItem(User user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundColor:
            (widget.creatorId != user.id) ? Colors.grey : Colors.orange,
        backgroundImage: (user.pic == null)
            ? const AssetImage("assets/icons/Frame 64.png") as ImageProvider
            : CachedNetworkImageProvider(
                user.pic!,
              ), // Color based on status
      ),
      title: Text(
        user.username ?? "Picapool User",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.all(8),
      subtitle: (user.id == widget.creatorId) ? const Text("Admin") : null,
      // trailing: (widget.creatorId == user.id)
      //     ? ElevatedButton(
      //         onPressed: () {},
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.grey.shade200,
      //           side: const BorderSide(color: Colors.grey),
      //         ),
      //         child: const Text(
      //           "Admin",
      //           style: TextStyle(color: Colors.grey),
      //         ),
      //       )
      //     : ElevatedButton(
      //         onPressed: () {},
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.white,
      //           side: const BorderSide(color: Colors.orange),
      //         ),
      //         child: const Text(
      //           "Request",
      //           style: TextStyle(color: Colors.orange),
      //         ),
      //       ),
    );
  }

  // Helper to build icon-label widgets
  Widget _buildIconLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
