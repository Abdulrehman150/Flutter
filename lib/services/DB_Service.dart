import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

import '../model/Conversations.dart';
import '../model/message.dart';
import '../model/contact.dart';

class DBService {
  static DBService instance = DBService();

  FirebaseFirestore _db;

  DBService() {
    _db = FirebaseFirestore.instance;
  }

  String _userCollection = "Users";
  String _conversationsCollection = "Conversations";

  Future<void> createUserInDB(
      String _uid,
      String _name,
      String _email,
      String _imageURL,
      String _fcmToken,
      double _latitude,
      double _longitude) async {
    try {
      return await _db.collection(_userCollection).doc(_uid).set({
        "name": _name,
        "email": _email,
        "image": _imageURL,
        "lastSeen": DateTime.now().toUtc(),
        "fcmToken": _fcmToken,
        "latitude": _latitude,
        "longitude": _longitude
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserLastSeenTime(
      String _userID, double _lattitude, double _longgitude) {
    var _ref = _db.collection(_userCollection).doc(_userID);
    return _ref.update({
      "lastSeen": Timestamp.now(),
      "latitude": _lattitude,
      "longitude": _longgitude
    });
  }

  Future<void> deleteMainConversation(String _conversationID) {
    var userCollection = _db.collection("Conversations").doc(_conversationID);

    return userCollection.delete();
  }

  Future<void> deleteFromOver(
      String _conversationID, String _currentID, String _recepientID) {
    var fromOverRecent = _db
        .collection("Users")
        .doc(_currentID)
        .collection("Conversations")
        .doc(_recepientID);
    return fromOverRecent.delete();
  }

  Future<void> deleteFromOther(
      String _conversationID, String _currentID, String _recepientID) {
    var fromOtherRecent = _db
        .collection("Users")
        .doc(_recepientID)
        .collection("Conversations")
        .doc(_currentID);
    return fromOtherRecent.delete();
  }

  Future<void> sendMessagee(String _conversationID, Message _message) {
    var _ref = _db
        .collection(_conversationsCollection)
        .doc(_conversationID)
        .collection("Messages");
    var _messageType = "";
    switch (_message.type) {
      case MessageType.Text:
        _messageType = "text";
        break;
      case MessageType.Image:
        _messageType = "image";
        break;
      default:
    }
    return _ref.add({
      "message": _message.content,
      "email": _message.email,
      "senderID": _message.senderID,
      "receiverID": _message.receiverID,
      "timestamp": _message.timestamp,
      "type": _messageType,
    });

    // ({
    //   "messages": FieldValue.arrayUnion(
    //     [
    //       {
    //         "message": _message.content,
    //         "senderID": _message.senderID,
    //         "timestamp": _message.timestamp,
    //         "type": _messageType,
    //       },
    //     ],
    //   ),
    // });
  }

  Future<void> sendMessage(String _conversationID, Message _message) {
    var _ref = _db.collection(_conversationsCollection).doc(_conversationID);
    var _messageType = "";
    switch (_message.type) {
      case MessageType.Text:
        _messageType = "text";
        break;
      case MessageType.Image:
        _messageType = "image";
        break;
      default:
    }
    return _ref.update({
      "messages": FieldValue.arrayUnion(
        [
          {
            "message": _message.content,
            "email": _message.email,
            "senderID": _message.senderID,
            "receiverID": _message.receiverID,
            "timestamp": _message.timestamp,
            "type": _messageType,
          },
        ],
      ),
    });
  }

  Future<void> createOrGetConversartion(String _currentID, String _recepientID,
      Future<void> _onSuccess(String _conversationID)) async {
    var _ref = _db.collection(_conversationsCollection);
    var _userConversationRef = _db
        .collection(_userCollection)
        .doc(_currentID)
        .collection(_conversationsCollection);
    try {
      var conversation = await _userConversationRef.doc(_recepientID).get();

      if (conversation.data() != null) {
        return _onSuccess(conversation.data()["conversationID"]);
      } else {
        var _conversationRef = _ref.doc();
        await _conversationRef.set(
          {
            "members": [_currentID, _recepientID],
            "ownerID": _currentID,
            "receiverID": _recepientID,
            'messages': [],
          },
        );
        var userData = await _db.collection("Users").doc(_recepientID).get();

        await _db
            .collection("Users")
            .doc(_currentID)
            .collection("Conversations")
            .doc(_recepientID)
            .set({
          "conversationID": _conversationRef.id,
          "image": userData.data()["image"],
          "name": userData.data()["name"],
          "unseenCount": 0
        });
        var myData = await _db.collection("Users").doc(_currentID).get();
        await _db
            .collection("Users")
            .doc(_recepientID)
            .collection("Conversations")
            .doc(_currentID)
            .set({
          "conversationID": _conversationRef.id,
          "image": myData.data()["image"],
          "name": myData.data()["name"],
          "unseenCount": 0
        });
        return _onSuccess(_conversationRef.id);
      }
    } catch (e) {
      print(e);
    }
  }

  Stream<Contact> getUserData(String _userID) {
    var _ref = _db.collection(_userCollection).doc(_userID);
    return _ref.get().asStream().map((_snapshot) {
      return Contact.fromFirestore(_snapshot);
    });
  }

  Stream<List<ConversationSnippet>> getUserConversations(String _userID) {
    var _ref = _db
        .collection(_userCollection)
        .doc(_userID)
        .collection(_conversationsCollection);
    return _ref.snapshots().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return ConversationSnippet.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<List<Contact>> getUsersInDB(String _searchName) {
    var _ref = _db
        .collection(_userCollection)
        .where("name", isGreaterThanOrEqualTo: _searchName)
        .where("name", isLessThan: _searchName + 'z');
    return _ref.get().asStream().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return Contact.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<Conversation> getConversation(String _conversationID) {
    var _ref = _db.collection(_conversationsCollection).doc(_conversationID);
    return _ref.snapshots().map(
      (_doc) {
        return Conversation.fromFirestore(_doc);
      },
    );
  }
}
