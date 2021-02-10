import 'package:Social_Spark/services/Navigation_service.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../Provider/Auth_Provider.dart';

import '../services/DB_Service.dart';
import '../services/Navigation_service.dart';

import '../Screens/Conversation_Page.dart';

import '../model/contact.dart';

class SearchPage extends StatefulWidget {
  double _height;
  double _width;

  SearchPage(this._height, this._width);

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  String _searchText;

  AuthProvider _auth;

  _SearchPageState() {
    _searchText = '';
    print(_searchText);
  }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: this.widget._height * 0.75,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _searchPageUI(),
      ),
    );
  }

  Widget _searchPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _userSearchField(),
              _usersListView(),
            ],
          ),
        );
      },
    );
  }

  Widget _userSearchField() {
    return Container(
      //color: Colors.amber,
      height: this.widget._height * 0.08,
      width: this.widget._width,
      padding: EdgeInsets.symmetric(vertical: this.widget._height * 0.02),
      child: TextField(
        autocorrect: false,
        style: TextStyle(color: Colors.white),
        onSubmitted: (_input) {
          setState(() {
            _searchText = _input;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          labelStyle: TextStyle(color: Colors.white),
          labelText: "Search",
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _usersListView() {
    return StreamBuilder<List<Contact>>(
      stream: DBService.instance.getUsersInDB(_searchText),
      builder: (_context, _snapshot) {
        var _usersData = _snapshot.data;
        if (_usersData != null) {
          _usersData.removeWhere((_contact) => _contact.id == _auth.user.uid);
        }
        return _snapshot.hasData
            ? Container(
                height: this.widget._height * 0.73,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: _usersData.length,
                  itemBuilder: (BuildContext _context, int _index) {
                    var _userData = _usersData[_index];
                    var _currentTime = DateTime.now();
                    var _recepientID = _usersData[_index].id;
                    var _isUserActive = !_userData.lastseen.toDate().isBefore(
                          _currentTime.subtract(
                            Duration(minutes: 10),
                          ),
                        );
                    return Container(
                      height: 75,
                      child: ListTile(
                        onTap: () {
                          DBService.instance.createOrGetConversartion(
                              _auth.user.uid, _recepientID, (_conversationID) {
                            NavigationService.instance.navigateToRoute(
                              MaterialPageRoute(
                                builder: (_context) {
                                  return ConversationPage(
                                      _conversationID,
                                      _recepientID,
                                      _userData.name,
                                      _userData.image,
                                      _userData.latitude,
                                      _userData.longitude);
                                },
                              ),
                            );
                          });
                        },
                        title: Text(_userData.name),
                        leading: GestureDetector(
                          onTap: () {
                            showImage(_userData.image);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(_userData.image),
                              ),
                            ),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            _isUserActive
                                ? Text(
                                    "Active Now",
                                    style: TextStyle(fontSize: 15),
                                  )
                                : Text(
                                    "Last Seen",
                                    style: TextStyle(fontSize: 15),
                                  ),
                            _isUserActive
                                ? Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  )
                                : Text(
                                    timeago.format(
                                      _userData.lastseen.toDate(),
                                    ),
                                    style: TextStyle(fontSize: 15),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            : SpinKitWanderingCubes(
                color: Colors.blue,
                size: 50.0,
              );
      },
    );
  }
}
