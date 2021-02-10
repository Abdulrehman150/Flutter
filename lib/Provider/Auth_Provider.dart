import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';

import '../services/Navigation_service.dart';
import '../services/snackbar_service.dart';
import '../services/DB_Service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error,
}

class AuthProvider extends ChangeNotifier {
  User user;
  AuthStatus status;

  FirebaseAuth _auth;
  static AuthProvider instance = AuthProvider();
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  double latitude;
  double longitude;

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _checkCurrentUserIsAuthenticated();
  }
  void _autoLogin() async {
    if (user != null) {
      await getLocation();
      await DBService.instance
          .updateUserLastSeenTime(user.uid, latitude, longitude);
      return NavigationService.instance.navigateToReplacement('home');
    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    user = await _auth.currentUser;
    if (user != null) {
      notifyListeners();
      await _autoLogin();
    }
  }

  void loginWithEmailAndPassword(String _email, String _password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      SnackBarService.instance.showSnackBarSuccess("Welcome, ${user.email}");
      await getLocation();
      await DBService.instance
          .updateUserLastSeenTime(user.uid, latitude, longitude);
      NavigationService.instance.navigateToReplacement("home");
    } catch (error) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance.showSnackBarError(error.toString());
    }
    notifyListeners();
  }

  void signUPWithEmailAndPassword(
      String _email,
      String _password,
      Future<void> onSuccess(
          String _uid, double latitude, double longitude)) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      await onSuccess(user.uid, latitude, longitude);
      SnackBarService.instance.showSnackBarSuccess("Welcome, ${user.email}");
      await getLocation();
      await DBService.instance
          .updateUserLastSeenTime(user.uid, latitude, longitude);
      NavigationService.instance.goBack();
      NavigationService.instance.navigateToReplacement("home");
    } catch (error) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance.showSnackBarError(error.toString());
    }
    notifyListeners();
  }

  void logoutUser(Future<void> onSuccess()) async {
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      await NavigationService.instance.navigateToReplacement('login');
      SnackBarService.instance.showSnackBarSuccess("Logged Out Successfully");
    } catch (e) {
      SnackBarService.instance.showSnackBarError(e.toString());
    }
  }

  Future getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    latitude = _locationData.latitude;
    longitude = _locationData.longitude;
  }
}
