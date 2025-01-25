import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/chats/chat_controller.dart';
import 'package:picapool/functions/user/user_controller.dart';
import 'package:picapool/models/chat_model.dart';
import 'package:picapool/models/live_offer_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/Public%20Chat/chat_info.dart';
import 'package:picapool/screens/Public%20Chat/public_chat_page.dart';
import 'package:picapool/utils/date_time_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isMessageEmpty;
  final Function(String message) onSend;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.isMessageEmpty,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    // Smiley icon
                    // Image.asset(
                    //   "assets/icons/Group 497.png",
                    //   height: 25,
                    // ),
                    // Text input field
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: '  Your message...',
                          hintStyle: TextStyle(fontFamily: "MontserratM"),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // Attach file icon
                    // Image.asset(
                    //   "assets/icons/pinselect.png",
                    //   height: 25,
                    // ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.orange,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  // Handle message send action here
                  onSend(controller.text);
                  controller.clear(); // Clear input after sending
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final Chat chat;
  final String chatTitle;
  final Offer? offer;
  final LiveOffer? liveOffer;
  const ChatPage({
    super.key,
    required this.chat,
    required this.chatTitle,
    this.offer,
    this.liveOffer,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class PrivateChatView extends StatelessWidget {
  const PrivateChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: const [
              RoomTile(
                roomName: "Yash’s room",
                occupancy: "4 occupied",
                isJoined: false,
              ),
              RoomTile(
                  roomName: "Akshay’s room",
                  occupancy: "3 occupied",
                  isJoined: true),
              RoomTile(
                  roomName: "Diya’s room",
                  occupancy: "4 occupied",
                  isJoined: false),
              RoomTile(
                  roomName: "Rohan’s room",
                  occupancy: "2 occupied",
                  isJoined: true),
              RoomTile(
                  roomName: "Yash’s room",
                  occupancy: "4 occupied",
                  isJoined: false),
              RoomTile(
                  roomName: "Dhiraj’s room",
                  occupancy: "3 occupied",
                  isJoined: false),
              RoomTile(
                  roomName: "Diya’s room",
                  occupancy: "4 occupied",
                  isJoined: false),
              RoomTile(
                  roomName: "Rohan’s room",
                  occupancy: "2 occupied",
                  isJoined: false),
            ],
          ),
        ),
        // Create Room Button at the bottom
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OutlinedButton.icon(
            onPressed: () {
              // Action for creating a room
            },
            icon: const Icon(Icons.add, color: Colors.orange),
            label: const Text(
              "Create room",
              style: TextStyle(color: Colors.orange),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.orange),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RoomTile extends StatelessWidget {
  final String roomName;
  final String occupancy;
  final bool isJoined;

  const RoomTile({
    super.key,
    required this.roomName,
    required this.occupancy,
    required this.isJoined,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: isJoined
                  ? Colors.grey
                  : Colors.orange, // Color based on status
              child: Text(
                roomName[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              roomName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(occupancy),
            trailing: isJoined
                ? ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      "Requested",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.orange),
                    ),
                    child: const Text(
                      "Request",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
          ),
          // Occupancy Indicator Lines
          Padding(
            padding: const EdgeInsets.only(left: 56.0, top: 4.0),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.orange),
                const SizedBox(width: 5),
                const Icon(Icons.circle, size: 8, color: Colors.orange),
                const SizedBox(width: 5),
                Icon(Icons.circle, size: 8, color: Colors.grey.shade400),
                const SizedBox(width: 5),
                Icon(Icons.circle, size: 8, color: Colors.grey.shade400),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  bool _isMessageEmpty = true;
  final ScrollController _scrollController = ScrollController();
  final ChatController chatController = Get.find<ChatController>();
  final UserController _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      primary: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              onPressed: _goToChatInfo,
              icon: const Icon(Icons.more_vert, color: Colors.orange)),
          if (widget.offer?.name.toLowerCase().contains("- from brands") ??
              false)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                onPressed: () async {
                  var formattedString =
                      "Hi,\nThis side ${_userController.user.value!.username} from chat: ${widget.chat.id} want to go ahead with buying the product";
                  var urlString =
                      "https://api.whatsapp.com/send/?phone=917224052216&text=$formattedString&type=phone_number&app_absent=0";
                  final Uri url = Uri.parse(urlString);
                  debugPrint(url.toString());
                  if (!await launchUrl(url)) {
                    Get.snackbar(
                      "Oop! something occured",
                      "Something went wrong processing your requeset.",
                    );
                  }
                },
                color: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text("Good to go"),
              ),
            ),
        ],
        centerTitle: false,
        title: InkWell(
          onTap: _goToChatInfo,
          child: SizedBox(
            width: double.infinity,
            height: AppBarTheme.of(context).toolbarHeight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.chatTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: "MontserratSB",
                ),
              ),
            ),
          ),
        ),
      ),
      body:
          // Public Chat Tab
          Column(
        children: [
          Expanded(
            child: GetBuilder<ChatController>(
              builder: (controller) {
                if (controller.isLoading.value && controller.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.isNotEmpty &&
                    controller.messages.isEmpty) {
                  return Center(
                    child: Text(controller.errorMessage.value),
                  );
                }

                if (controller.messages.isEmpty) {
                  return const Center(
                    child: Text("No messages found"),
                  );
                }

                debugPrint("${controller.messages.length}");

                return ListView.builder(
                  controller: chatController.scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];

                    return ChatBubble(
                      sender: (message.userId != null)
                          ? chatController
                                  .getUserNameFromIdInChat(message.userId!) ??
                              ""
                          : "",
                      message: message.content,
                      time: DateTimeHelper.timeAgoSince(
                          message.createdAt.toIso8601String()),
                      isMe: message.userId == _userController.user.value!.id,
                      imageUrl: '',
                      showSenderDetails: false,
                      // replyToMessage: message.replyToMessage,
                      // replySender: message.replySender,
                    );
                  },
                );
              },
            ),
          ),
          ChatInputField(
            controller: _messageController,
            isMessageEmpty: _isMessageEmpty,
            onSend: (!_isMessageEmpty)
                ? (message) {
                    debugPrint("Sending..chat");
                    if (!chatController.isSocketConnected()) {
                      Get.snackbar(
                        "No Action",
                        "No connection to send message",
                      );
                    }
                    chatController.sendMessage(message);
                    // chatController.sendReaction(message, 220);
                  }
                : (message) {},
          ),
        ],
      ),
      // Private Chat Tab
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    chatController.disconnectSocket();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      chatController.connectToSocket(
        _userController.user.value!.id,
        widget.chat.id,
      );

      await chatController.getAllUsersInChat(widget.chat.id);

      _messageController.addListener(isActive);

      chatController.getAllMessages(widget.chat.id);
      debugPrint("${widget.chat.toJson()}");
    });
  }

  void isActive() {
    setState(() {
      _isMessageEmpty = _messageController.text.isEmpty;
    });
  }

  void listen() {
    if (chatController.socketService.socket == null) {
      return;
    }
    chatController.socketService.socket!.on('receiveMessage', (data) {
      // final message = Message.fromJson(data);
      debugPrint("Here I am in the model");
      chatController.handleIncomingMessage(data);
    });
  }

  void _goToChatInfo() {
    Get.to(
      () => ChatInfo(
        chatId: widget.chat.id,
        creatorId: widget.offer?.userId ?? widget.liveOffer?.userId ?? -1,
        offer: widget.offer,
      ),
    );
  }
}
