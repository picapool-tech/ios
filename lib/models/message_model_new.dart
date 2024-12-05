class MessageModel {
  final String sender;
  final String message;
  final String time;
  final bool isMe;
  final String? imageUrl;
  final bool showSenderDetails;
  final String? replyToMessage;
  final String? replySender;

  MessageModel({
    required this.sender,
    required this.message,
    required this.time,
    required this.isMe,
    this.imageUrl,
    this.showSenderDetails = false,
    this.replyToMessage,
    this.replySender,
  });
}
