import 'dart:convert';
import 'dart:async'; //for setting timer

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  //this all variables can be changed. so we didn't make those at final
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  String? _displayName;
  Timer? _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  String? get displayName {
    return _displayName;
  }

  Future<void> _authenticate({
    required String email,
    required String password,
    String? displayName,
    required String urlSegment,
  }) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAjEzuC_Fcx7GWXmYs8h81p5iVqh9dtKzQ');
    try {
      final response = await http.post(
        url,
        body: (urlSegment == 'signUp')
            ? json.encode(
                {
                  'email': email,
                  'password': password,
                  'returnSecureToken': true,
                  'displayName': displayName,
                },
              )
            : json.encode(
                {
                  'email': email,
                  'password': password,
                  'returnSecureToken': true,
                },
              ),
      );
      print('response : ${response.toString()}');
      final responseData = json.decode(response.body);
      print('responseData : ${responseData.toString()}');

      // if (responseData.containskey('error')) {
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      //setting vars
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _displayName = responseData['displayName'];
      print('Display name is : .$_displayName.');

      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      print('success authentication : ${json.decode(response.body)}');

      //storing data on device
      final prefs = await SharedPreferences.getInstance();
      //if data is bigger then we can also input json data as String.
      final userData = json.encode(
        {
          'token': _token,
          'userId': userId,
          'expiryDate': _expiryDate!.toIso8601String(),
          'displayName': _displayName,
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      print('failed authentication : ${error.toString()}');
      throw error;
    }
    print('USER ID : $_userId\token : $_token\Expiry Date: $_expiryDate\n');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(
        email: email, password: password, urlSegment: 'signInWithPassword');
  }

  Future<void> signup(String displayName, String email, String password) async {
    return _authenticate(
      email: email,
      password: password,
      displayName: displayName,
      urlSegment: 'signUp',
    );
  }

  Future<bool> tryAutoLogin() async {
    print('tryAutoLogin executed.');
    final prefs = await SharedPreferences.getInstance();
    // print('recieved prefs data : ${prefs.toString()}');
    if (!prefs.containsKey('userData')) {
      print('On device data is not available.');
      return false;
    }
    print('auth data is found on device.');
    final extractedUserData = json.decode(prefs.getString('userData') as String)
        as Map<String, dynamic>;
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'] as String);
    print('user data : $extractedUserData || expiry date : $expiryDate');
    if (expiryDate.isBefore(DateTime.now())) {
      print('Token is expired.');
      return false;
    }
    _token = extractedUserData['token'] as String;
    _userId = extractedUserData['userId'] as String;
    _expiryDate = expiryDate;
    _displayName = extractedUserData['displayName'] as String;
    notifyListeners();
    _autoLogout();
    print('successfully auto login.');
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();

    //clearing on device data :
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData'); //if we are using multiple preferences then we should use this as this only removes the data of the specified key.
    prefs.clear(); //this clears everything.
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
