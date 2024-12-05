import 'package:flutter/material.dart';
import 'package:picapool/models/message_model_new.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  bool _isMessageEmpty = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _messageController.addListener(() {
      setState(() {
        _isMessageEmpty = _messageController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  final List<MessageModel> publicMessages = [
    MessageModel(
      sender: "Shreya Roy",
      message: "Hi, I am ready to pool, \npaying 400?",
      time: "5:30 PM",
      isMe: false,
      imageUrl: 'https://via.placeholder.com/150',
      showSenderDetails: true,
    ),
    MessageModel(
      sender: "You",
      message: "Hi, who all are willing to \npool for this offer?",
      time: "5:31 PM",
      isMe: true,
      imageUrl: '',
      showSenderDetails: false,
    ),
    MessageModel(
      sender: "Pranav",
      message: "Hi, I am ready to pool, \npaying 400?",
      time: "5:32 PM",
      isMe: false,
      imageUrl: 'https://via.placeholder.com/150',
      showSenderDetails: true,
    ),
    MessageModel(
      sender: "Pranav",
      message: "If you are paying 200 let \nme know",
      time: "5:32 PM",
      isMe: false,
      imageUrl: 'https://via.placeholder.com/150',
      showSenderDetails: false,
    ),
    MessageModel(
      sender: "You",
      message: "Hi, who all are willing to pool for \nthis offer?",
      time: "5:34 PM",
      isMe: true,
      imageUrl: '',
      showSenderDetails: false,
      replyToMessage: "Hi, I am ready to pool, paying 400?",
      replySender: "Pranav",
    ),
    MessageModel(
      sender: "Pranav",
      message: "Hi, I am ready to pool, \npaying 400?",
      time: "5:36 PM",
      isMe: false,
      imageUrl: 'https://via.placeholder.com/150',
      showSenderDetails: true,
      replyToMessage: "Hi, who all are willing to pool for this offer?",
      replySender: "You",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "KFC 50% off",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: "MontserratSB",
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orange,
          labelStyle: const TextStyle(
            fontFamily: "MontserratR", // Tab bar font style
          ),
          tabs: const [
            Tab(text: "Public Chat"),
            Tab(text: "Private chats (3)"),
          ],
        ),
      ),
      body: Container(
        color: Colors.white, // Set chat background to white
        child: TabBarView(
          controller: _tabController,
          children: [
            // Public Chat Tab
            PublicChatView(
              messages: publicMessages,
            ),
            // Private Chat Tab
            PrivateChatView(),
          ],
        ),
      ),
      bottomNavigationBar: ChatInputField(
        controller: _messageController,
        isMessageEmpty: _isMessageEmpty,
      ),
    );
  }
}

class PublicChatView extends StatelessWidget {
  final List<MessageModel> messages;

  PublicChatView({required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatBubble(
          sender: message.sender,
          message: message.message,
          time: message.time,
          isMe: message.isMe,
          imageUrl: message.imageUrl ?? '',
          showSenderDetails: message.showSenderDetails,
          replyToMessage: message.replyToMessage,
          replySender: message.replySender,
        );
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String sender;
  final String message;
  final String time;
  final bool isMe;
  final String imageUrl;
  final bool showSenderDetails;
  final String? replyToMessage;
  final String? replySender;

  const ChatBubble({
    required this.sender,
    required this.message,
    required this.time,
    required this.isMe,
    required this.imageUrl,
    required this.showSenderDetails,
    this.replyToMessage,
    this.replySender,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe && showSenderDetails) ...[
              CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 20,
              ),
              const SizedBox(width: 10),
            ] else if (!isMe) ...[
              const SizedBox(width: 50),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe && showSenderDetails)
                    Text(
                      sender,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontFamily: "MontserratSB", // Sender's name font
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFFF3D7C5)
                          : const Color(0xFFDEDEDE), // Main bubble colors
                      borderRadius: BorderRadius.only(
                        topLeft: isMe
                            ? const Radius.circular(10)
                            : const Radius.circular(0),
                        topRight: const Radius.circular(10),
                        bottomLeft: const Radius.circular(10),
                        bottomRight: isMe
                            ? const Radius.circular(0)
                            : const Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (replyToMessage != null && replySender != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color(0xFFFFE2D0)
                                  : const Color(
                                      0xFFEBEBEB), // Lighter background for reply
                              borderRadius: BorderRadius.circular(10),
                              border: const Border(
                                left: BorderSide(
                                    color: Colors.orange,
                                    width:
                                        3), // Orange line to the left of reply
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  replySender!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily:
                                        "MontserratSB", // Replied sender's name font
                                    color: isMe
                                        ? Colors.orange.shade700
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        4), // Small space between name and message
                                Text(
                                  replyToMessage!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily:
                                        "MontserratM", // Replied message font
                                    fontSize:
                                        14, // Regular size for reply message
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          message,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: "MontserratM", // Chat text font
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          time,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xff6C6C6C)),
                        ),
                      ],
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
}

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isMessageEmpty;

  const ChatInputField({
    required this.controller,
    required this.isMessageEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Chat input field
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
                    Image.asset(
                      "assets/icons/Group 497.png",
                      height: 25,
                    ),
                    // Text input field
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: '  Drag up to confirm',
                          hintStyle: TextStyle(fontFamily: "MontserratM"),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // Attach file icon
                    Image.asset(
                      "assets/icons/pinselect.png",
                      height: 25,
                    ),
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
                onPressed: isMessageEmpty
                    ? null
                    : () {
                        // Handle message send action here
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

class PrivateChatView extends StatelessWidget {
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
                  isJoined: false),
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
