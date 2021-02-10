import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  Text,
  Image,
}

class Message {
  final String senderID;
  final String receiverID;
  final String email;
  final String content;
  final String name;
  final Timestamp timestamp;
  final MessageType type;
  final String replyMessage;

  Message(
      {this.senderID,
      this.receiverID,
      this.email,
      this.name,
      this.content,
      this.timestamp,
      this.type,
      this.replyMessage});
}
