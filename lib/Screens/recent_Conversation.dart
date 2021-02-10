import 'package:Social_Spark/services/DB_Service.dart';
import 'package:Social_Spark/services/Navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../Provider/Auth_Provider.dart';

import '../services/DB_Service.dart';
import '../services/Navigation_service.dart';

import '../model/Conversations.dart';
import '../model/message.dart';

import '../Screens/Conversation_Page.dart';

class RecentConversationsPage extends StatefulWidget {
  final double _height;
  final double _width;

  RecentConversationsPage(this._height, this._width);

  @override
  _RecentConversationsPageState createState() =>
      _RecentConversationsPageState();
}

User user = FirebaseAuth.instance.currentUser;
String currentUser = user.uid;

class _RecentConversationsPageState extends State<RecentConversationsPage> {
  showImage(_image) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text("Profile Image"),
            content: Image.network(_image),
            // actions: <Widget>[
            //   FlatButton(
            //     onPressed: () {
            //       Navigator.pop(ctx);
            //     },
            //     child: Text("Dismiss"),
            //   ),
            // ],
          );
        });
  }

  deleteMsg(conversationID, currentId, recepientId) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text("Delete Alert"),
            content: Text("Delete from Everyone ?"),
            actions: <Widget>[
              Row(
                children: [
                  FlatButton(
                    onPressed: () async {
                      await DBService.instance
                          .deleteMainConversation(conversationID);
                      await DBService.instance.deleteFromOver(
                          conversationID, currentId, recepientId);
                      await DBService.instance.deleteFromOther(
                          conversationID, currentId, recepientId);
                      Navigator.pop(ctx);
                    },
                    child: Text("Yes"),
                  ),
                  FlatButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                    },
                    child: Text("No"),
                  ),
                ],
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget._height,
      width: widget._width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationsListViewWidget(),
      ),
    );
  }

  Widget _conversationsListViewWidget() {
    return Builder(
      builder: (BuildContext _context) {
        var _auth = Provider.of<AuthProvider>(_context);
        return Container(
          height: widget._height,
          width: widget._width,
          child: StreamBuilder<List<ConversationSnippet>>(
            stream: DBService.instance.getUserConversations(_auth.user.uid),
            builder: (_context, _snashot) {
              var _data = _snashot.data;
              if (_data != null) {
                _data.removeWhere((_c) {
                  return _c.timestamp == null;
                });
                return _data.length != 0
                    ? ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: _data.length,
                        itemBuilder: (_context, _index) {
                          return
                              // await DBService.instance.deleteFromOver(
                              //     _data[_index].conversationID,
                              //     currentUser,
                              //     _data[_index].id);
                              // await DBService.instance.deleteFromOther(
                              //     _data[_index].conversationID,
                              //     currentUser,
                              //     _data[_index].id);

                              Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: Container(
                              height: 75,
                              //color: Colors.white,
                              child: ListTile(
                                onTap: () {
                                  NavigationService.instance.navigateToRoute(
                                    MaterialPageRoute(
                                      builder: (BuildContext _context) {
                                        return ConversationPage(
                                            _data[_index].conversationID,
                                            _data[_index].id,
                                            _data[_index].name,
                                            _data[_index].image,
                                            _data[_index].latitude,
                                            _data[_index].longitude);
                                      },
                                    ),
                                  );
                                },
                                title: Text(_data[_index].name),
                                subtitle: Text(
                                    _data[_index].type == MessageType.Text
                                        ? _data[_index].lastMessage
                                        : "Attachment: Image"),
                                leading: GestureDetector(
                                  onTap: () {
                                    showImage(_data[_index].image);
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image:
                                            NetworkImage(_data[_index].image),
                                      ),
                                    ),
                                  ),
                                ),
                                trailing: _listTileTrailingWidgets(
                                    _data[_index].timestamp),
                              ),
                            ),
                            actions: <Widget>[],
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: 'Delete',
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () => deleteMsg(
                                    _data[_index].conversationID,
                                    currentUser,
                                    _data[_index].id),
                              ),
                            ],
                          );
                        },
                      )
                    : Align(
                        child: Text(
                          "No Conversations Yet!",
                          style:
                              TextStyle(color: Colors.white30, fontSize: 15.0),
                        ),
                      );
              } else {
                return SpinKitWanderingCubes(
                  color: Colors.blue,
                  size: 50.0,
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _listTileTrailingWidgets(Timestamp _lastMessageTimestamp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          "Last Message",
          style: TextStyle(fontSize: 15),
        ),
        Text(
          timeago.format(_lastMessageTimestamp.toDate()),
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
