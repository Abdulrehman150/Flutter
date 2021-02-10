import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:swipe_to/swipe_to.dart';

import '../Provider/Auth_Provider.dart';
import '../services/DB_Service.dart';
import '../services/Media_Service.dart';
import '../services/cloud_storage_service.dart';

import '../model/Conversations.dart';
import '../model/message.dart';

class ConversationPage extends StatefulWidget {
  String _conversationID;
  String _receiverID;
  String _receiverImage;
  String _receiverName;
  double _latitude;
  double _longitude;

  ConversationPage(this._conversationID, this._receiverID, this._receiverName,
      this._receiverImage, this._latitude, this._longitude);

  @override
  State<StatefulWidget> createState() {
    return _ConversationPageState();
  }
}

class _ConversationPageState extends State<ConversationPage> {
  double _deviceHeight;
  double _deviceWidth;
  //String replyMsg;
  String replyMessage;
  VoidCallback onCancelReply;

  GlobalKey<FormState> _formKey;
  ScrollController _listViewController;
  AuthProvider _auth;
  bool admin = false;
  FirebaseMessaging _firebaseMessaging;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String _messageText;

  _ConversationPageState() {
    _formKey = GlobalKey<FormState>();
    _listViewController = ScrollController();
    _messageText = "";
    _firebaseMessaging = FirebaseMessaging();
  }
  final focusNode = FocusNode();

  @override
  void initState() {
    if (firebaseAuth.currentUser.email == "moon.mujahid786@gmail.com") {
      setState(() {
        admin = true;
      });
    }
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.getToken();
  }

  showLocation(title, latitude, longitude) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(title),
            content: GestureDetector(
              onTap: () {
                MapsLauncher.launchCoordinates(latitude, longitude);
              },
              child: Text(
                "Open Google Map",
                style: TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: Text("Dismiss"),
              ),
            ],
          );
        });
  }

  showImage(_image) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Image.network(_image),
          );
        });
  }

  void replyTomsg(String message) {
    setState(() {
      replyMessage = message;
    });
  }

  void cancelReply() {
    setState(() {
      replyMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(31, 31, 31, 1.0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(this.widget._receiverName),
              if (admin == true)
                GestureDetector(
                    onTap: () async {
                      showLocation("Location :", this.widget._latitude,
                          this.widget._longitude);
                    },
                    child: Icon(Icons.location_on)),
            ],
          )),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI(),
      ),
    );
  }

  Widget _conversationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        final isReplying = replyMessage != null;
        return SingleChildScrollView(
          child: Column(children: [
            _messageListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _messageField(_context),

              // Container(
              //   padding: EdgeInsets.all(8),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     crossAxisAlignment: isReplying
              //         ? CrossAxisAlignment.end
              //         : CrossAxisAlignment.center,
              //     mainAxisSize: MainAxisSize.max,
              //     children: [
              //       Expanded(
              //         child: Form(
              //           key: _formKey,
              //           child: Column(
              //             children: [
              //               //if (isReplying) buildReply(),
              //               TextFormField(
              //                 textCapitalization: TextCapitalization.sentences,
              //                 enableSuggestions: true,
              //                 decoration: InputDecoration(
              //                   filled: true,
              //                   fillColor: Color.fromRGBO(43, 43, 43, 1),
              //                   hintText: 'Type a message',
              //                   border: OutlineInputBorder(
              //                     borderSide: BorderSide.none,
              //                     borderRadius: BorderRadius.only(
              //                       topLeft: isReplying
              //                           ? Radius.zero
              //                           : Radius.circular(24),
              //                       topRight: isReplying
              //                           ? Radius.zero
              //                           : Radius.circular(24),
              //                       bottomLeft: Radius.circular(24),
              //                       bottomRight: Radius.circular(24),
              //                     ),
              //                   ),
              //                 ),
              //                 validator: (_input) {
              //                   if (_input.length == 0) {
              //                     return "Please enter a message";
              //                   }
              //                   return null;
              //                 },
              //                 onChanged: (_input) {
              //                   _formKey.currentState.save();
              //                 },
              //                 onSaved: (_input) {
              //                   setState(() {
              //                     _messageText = _input;
              //                   });
              //                 },
              //                 focusNode: focusNode,
              //                 cursorColor: Colors.white,
              //                 autocorrect: false,
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //       SizedBox(
              //         width: 5,
              //       ),
              //       _sendMessageButton(_context),
              //       SizedBox(
              //         width: 1,
              //       ),
              //       _imageMessageButton(),
              //     ],
              //   ),
              // ),
            ),
          ]),
        );
      },
    );
  }

  // Widget buildReply() => Container(
  //       padding: EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         color: Colors.grey.withOpacity(0.2),
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(12),
  //           topRight: Radius.circular(12),
  //         ),
  //       ),
  //       child:
  //           ReplyMessageWidget(message: replyMessage, onCancel: onCancelReply),
  //     );

  // ReplyMessageWidget({String message, onCancel}) {
  //   return IntrinsicHeight(
  //     child: Row(
  //       children: [
  //         Container(
  //           color: Colors.green,
  //           width: 4,
  //         ),
  //         const SizedBox(
  //           height: 8,
  //         ),
  //         Expanded(child: buildReplyMessage())
  //       ],
  //     ),
  //   );
  // }

//_message.senderID == _auth.user.uid;
  // Widget buildReplyMessage() => Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Expanded(
  //               child: Text(
  //                 this.widget._receiverName,
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //             //if (onCancelReply != null)
  //             GestureDetector(
  //               child: Icon(
  //                 Icons.close,
  //                 color: Colors.grey,
  //               ),
  //               onTap: cancelReply,
  //             )
  //           ],
  //         ),
  //         const SizedBox(
  //           height: 8,
  //         ),
  //         Text(
  //           replyMessage.toString(),
  //           style: TextStyle(color: Colors.black54),
  //         )
  //       ],
  //     );

  Widget _messageListView() {
    return Container(
      //color: Colors.red,
      height: _deviceHeight * 0.74,
      width: _deviceWidth,
      child: StreamBuilder<Conversation>(
        stream: DBService.instance.getConversation(this.widget._conversationID),
        builder: (BuildContext _context, _snapshot) {
          Timer(
              Duration(milliseconds: 40),
              () => {
                    if (_listViewController.hasClients)
                      {
                        _listViewController.jumpTo(
                            _listViewController.position.maxScrollExtent),
                      },
                  });

          var _conversationData = _snapshot.data;
          if (_conversationData != null) {
            if (_conversationData.messages.length != 0) {
              return ListView.builder(
                controller: _listViewController,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: _conversationData.messages.length,
                itemBuilder: (BuildContext _context, int _index) {
                  var message = _conversationData.messages[_index];
                  bool isOwnMessage = message.senderID == _auth.user.uid;
                  return _messageListViewChild(isOwnMessage, message);
                },
              );
            } else {
              return Align(
                alignment: Alignment.center,
                child: Text("Let's start a conversation!"),
              );
            }
          } else {
            return SpinKitWanderingCubes(
              color: Colors.blue,
              size: 50.0,
            );
          }
        },
      ),
    );
  }

  Widget _messageListViewChild(bool _isOwnMessage, Message _message) {
    // bool isOwnMessage = _message.senderID == _auth.user.uid;
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            _isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          !_isOwnMessage ? _userImageWidget() : Container(),
          SizedBox(width: _deviceWidth * 0.02),
          _message.type == MessageType.Text
              ? SwipeTo(
                  onRightSwipe: () {
                    //replyTomsg(_message.content);
                    focusNode.requestFocus();
                  },
                  child: _textMessageBubble(
                    _isOwnMessage,
                    _message.content,
                    _message.timestamp,
                  ),
                )

              //
              : GestureDetector(
                  onTap: () {
                    showImage(_message.content);
                  },
                  child: _imageMessageBubble(
                      _isOwnMessage, _message.content, _message.timestamp),
                ),
        ],
      ),
    );
  }

  Widget _userImageWidget() {
    double _imageRadius = _deviceHeight * 0.05;
    return Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(this.widget._receiverImage),
        ),
      ),
    );
  }

  Widget _textMessageBubble(
      bool _isOwnMessage, String _message, Timestamp _timestamp) {
    List<Color> _colorScheme = _isOwnMessage
        ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    return Container(
      constraints: BoxConstraints(
        minWidth: 100.0,
        maxWidth: 250.0,
        // minHeight: 40.0,
        //maxHeight: 250.0,
      ),
      height: _deviceHeight * 0.11 + (_message.length / 20 * 5.0),
      //width: _deviceWidth * 0.75,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: !_isOwnMessage ? Radius.circular(0) : Radius.circular(10),
          bottomRight: _isOwnMessage ? Radius.circular(0) : Radius.circular(10),
        ),
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(_message),
          Text(
            timeago.format(_timestamp.toDate()),
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(
      bool _isOwnMessage, String _imageURL, Timestamp _timestamp) {
    List<Color> _colorScheme = _isOwnMessage
        ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    DecorationImage _image =
        DecorationImage(image: NetworkImage(_imageURL), fit: BoxFit.cover);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: !_isOwnMessage ? Radius.circular(0) : Radius.circular(10),
          bottomRight: _isOwnMessage ? Radius.circular(0) : Radius.circular(10),
        ),
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            height: _deviceHeight * 0.30,
            width: _deviceWidth * 0.40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: _image,
            ),
          ),
          Text(
            timeago.format(_timestamp.toDate()),
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _messageField(BuildContext _context) {
    return Container(
      //color: Colors.amber,
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1),
        //  color: Colors.amber,
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.04, vertical: _deviceHeight * 0.03),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _messageTextField(),
            _sendMessageButton(_context),
            _imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        focusNode: focusNode,
        validator: (_input) {
          if (_input.length == 0) {
            return "Please enter a message";
          }
          return null;
        },
        onChanged: (_input) {
          setState(() {
            _messageText = _input;
          });
        },
        onSaved: (_input) {
          _formKey.currentState.save();
        },
        cursorColor: Colors.white,
        decoration: InputDecoration(
            border: InputBorder.none, hintText: "Type a message"),
        autocorrect: false,
      ),
    );
  }

  // Widget _messageField() {
  //   final isReplying = replyMsg != null;
  //   return Container(
  //     padding: EdgeInsets.only(left: 15),
  //     //color: Colors.amber,

  //     // height: isReplying ? _deviceHeight * 0.2 : _deviceHeight * 0.08,
  //     decoration: BoxDecoration(
  //       //color: Color.fromRGBO(43, 43, 43, 1),
  //       color: Colors.amber,
  //       borderRadius:
  //           isReplying ? BorderRadius.circular(12) : BorderRadius.circular(50),
  //     ),
  //     margin: EdgeInsets.symmetric(
  //         horizontal: _deviceWidth * 0.03,
  //         vertical:
  //             replyMsg != null ? _deviceHeight * 0.01 : _deviceHeight * 0.04),
  //     child: Form(
  //       key: _formKey,
  //       child: _messageTextField(),
  //     ),
  //   );
  // }

//if (isReplying) buildReply();
  // Widget _messageTextField() {
  //   final isReplying = replyMsg != null;
  //   return
  // }

  Widget _sendMessageButton(BuildContext _context) {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: IconButton(
          icon: Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              DBService.instance.sendMessage(
                this.widget._conversationID,
                Message(
                    content: _messageText,
                    timestamp: Timestamp.now(),
                    senderID: _auth.user.uid,
                    receiverID: this.widget._receiverID,
                    email: _auth.user.email,
                    type: MessageType.Text),
              );
              _formKey.currentState.reset();
              FocusScope.of(_context).unfocus();
              DBService.instance.sendMessagee(
                this.widget._conversationID,
                Message(
                    content: _messageText,
                    timestamp: Timestamp.now(),
                    senderID: _auth.user.uid,
                    receiverID: this.widget._receiverID,
                    email: _auth.user.email,
                    type: MessageType.Text),
              );
              _formKey.currentState.reset();
              FocusScope.of(_context).unfocus();
            }
          }),
    );
  }

  Widget _imageMessageButton() {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: FloatingActionButton(
        onPressed: () async {
          var _image = await MediaService.instance.getImageFromLibrary();
          if (_image != null) {
            var _result = await CloudStorageService.instance
                .uploadMediaMessage(_auth.user.uid, _image);
            var _imageURL = await _result.ref.getDownloadURL();
            await DBService.instance.sendMessage(
              this.widget._conversationID,
              Message(
                  content: _imageURL,
                  senderID: _auth.user.uid,
                  timestamp: Timestamp.now(),
                  type: MessageType.Image),
            );
          }
        },
        child: Icon(Icons.camera_enhance),
      ),
    );
  }
}
