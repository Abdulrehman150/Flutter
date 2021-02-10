import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SnackBarService {
  BuildContext _buildContext;

  static SnackBarService instance = SnackBarService();

  SnackBarService() {}

  set buildContext(BuildContext _context) {
    _buildContext = _context;
  }

  void showSnackBarError(String _message) {
    Scaffold.of(_buildContext).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
        content: Text(
          _message,
           style: TextStyle(
              color: Colors.white, 
        backgroundColor:    Colors.red, fontSize: 15),
        ),
      ),
    );
  }
   void showSnackBarSuccess(String _message) {
    Scaffold.of(_buildContext).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
        content: Text(
          _message,
          style: TextStyle(
              color: Colors.white,
               backgroundColor: Colors.green, fontSize: 15),
        ),
      ),
    );
  }
}
