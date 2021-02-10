import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/Auth_Provider.dart';
import '../services/DB_Service.dart';
import '../model/contact.dart';

class ProfileScreen extends StatefulWidget {
  final double _height;
  final double _width;

  ProfileScreen(this._height, this._width);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthProvider _auth;
  showImage(_image) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text("My image"),
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
      child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance, child: profilePageUI()),
    );
  }

  Widget profilePageUI() {
    return Builder(builder: (BuildContext _context) {
      _auth = Provider.of<AuthProvider>(_context);
      return StreamBuilder<Contact>(
          stream: DBService.instance.getUserData(_auth.user.uid),
          builder: (_context, _snapshot) {
            var userData = _snapshot.data;
            return _snapshot.hasData
                ? Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: widget._height * 0.50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                              onTap: () {
                                showImage(userData.image);
                              },
                              child: _userImageWidget(userData.image)),
                          _userNameWidget(userData.name),
                          _userEmailWidget(userData.email),
                          _logoutButton(),
                        ],
                      ),
                    ),
                  )
                : SpinKitWanderingCubes(
                    color: Colors.blue,
                    size: 50.0,
                  );
          });
    });
  }

  Widget _userImageWidget(String _image) {
    double _imageRadius = widget._height * 0.20;
    return Align(
      child: Container(
        height: _imageRadius,
        width: _imageRadius,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_imageRadius),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(_image),
          ),
        ),
      ),
    );
  }

  Widget _userNameWidget(String _username) {
    return Container(
      height: widget._height * 0.05,
      width: widget._width,
      child: Text(
        _username,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
    );
  }

  Widget _userEmailWidget(String _userEmail) {
    return Container(
      height: widget._height * 0.05,
      width: widget._width,
      child: Text(
        _userEmail,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white24, fontSize: 15),
      ),
    );
  }

  Widget _logoutButton() {
    return Align(
      child: Container(
        height: widget._height * 0.06,
        width: widget._width * 0.80,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0)),
        child: MaterialButton(
          onPressed: () {
            _auth.logoutUser(() {});
          },
          color: Colors.red,
          child: Text(
            "LOGOUT",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
