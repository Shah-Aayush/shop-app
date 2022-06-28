// import 'dart:math';

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import './components/constants.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';
// import './components/cancel_button.dart';
// import './components/login_form.dart';
// import './components/register_form.dart';
// import './components/rounded_button.dart';
// import './components/rounded_input.dart';
// import './components/rounded_password_input.dart';

enum AuthMode { Signup, Login }

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class AnimatedAuthScreen extends StatefulWidget {
  // const AnimatedAuthScreen({Key? key}) : super(key: key);
  static const routeName = '/auth-screen';

  @override
  _AnimatedAuthScreenState createState() => _AnimatedAuthScreenState();
}

class _AnimatedAuthScreenState extends State<AnimatedAuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool showPassword = false;
  late Animation<double> containerSize;
  late AnimationController animationController;
  Duration animationDuration = Duration(milliseconds: 270);

  //authscreen variables :
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'displayName': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showAlertDialogMessage(
    BuildContext context,
    String titleMessage,
    String contentMessage,
    String buttonTitle,
  ) {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(titleMessage),
          content: Text(
            contentMessage,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(buttonTitle),
            ),
          ],
        ),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(titleMessage),
          content: Text(
            contentMessage,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(buttonTitle),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _submit() async {
    print('submit pressed.');
    if (isLogin) {
      if (!_loginFormKey.currentState!.validate()) {
        // Invalid!
        return;
      }
      _loginFormKey.currentState!.save();
    } else {
      if (!_registerFormKey.currentState!.validate()) {
        // Invalid!
        return;
      }
      _registerFormKey.currentState!.save();
    }

    setState(() {
      _isLoading = true;
    });
    var errorMessage;
    print(
        'data collected : .${_authData['email']}. .${_authData['password']}. .${_authData['displayName']}.');
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        print('Inside TRY LOGIN');
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'] as String,
          _authData['password'] as String,
        );
      } else {
        print('Inside TRY SIGNUP');
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['displayName'] as String,
          _authData['email'] as String,
          _authData['password'] as String,
        );
      }
      // Navigator.of(context).pushReplacementNamed('/products-overview');  //this can be one approach.
      print('success TRY');
    } on HttpException catch (error) {
      print('HTTP EXCEPTION');
      //specific exception :
      errorMessage = 'Authentication failed.';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with this email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      print(errorMessage);
      _showAlertDialogMessage(context, 'OOPS!', errorMessage, 'Okay');
      // print(error);
    } catch (error) {
      print("DEFAULT CATCH");
      errorMessage = 'Could not authenticate you. Please try again later.';
      print(errorMessage);
      _showAlertDialogMessage(context, 'OOPS!', errorMessage, 'Okay');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
    print('Switched authmode to $_authMode');
  }

  bool isValidMail(String mailId) {
    return RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(mailId);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

    animationController =
        AnimationController(vsync: this, duration: animationDuration);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double viewInset = MediaQuery.of(context)
        .viewInsets
        .bottom; // we are using this to determine Keyboard is opened or not
    double defaultLoginSize = size.height - (size.height * 0.2);
    double defaultRegisterSize = size.height - (size.height * 0.1);

    containerSize = Tween<double>(
            begin: size.height * 0.1, end: defaultRegisterSize)
        .animate(
            CurvedAnimation(parent: animationController, curve: Curves.linear));

    return Scaffold(
      body: Stack(
        children: [
          // Lets add some decorations
          Positioned(
              top: 100,
              right: -50,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: kPrimaryColor),
              )),

          Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: kPrimaryColor),
              )),

          // Cancel Button
          AnimatedOpacity(
            opacity: isLogin ? 0.0 : 1.0,
            duration: animationDuration,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: size.width,
                height: size.height * 0.1,
                alignment: Alignment.bottomCenter,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: isLogin
                      ? () {}
                      : () {
                          _switchAuthMode();
                          // returning null to disable the button
                          animationController.reverse();
                          setState(() {
                            _passwordController.clear();
                            isLogin = !isLogin;
                          });
                        },
                  color: kPrimaryColor,
                ),
              ),
            ),
          ),
          // CancelButton(
          //   isLogin: isLogin,
          //   animationDuration: animationDuration,
          //   size: size,
          //   animationController: animationController,
          //   tapEvent: isLogin
          //       ? () {}
          //       : () {
          //           // returning null to disable the button
          //           animationController.reverse();
          //           setState(() {
          //             isLogin = !isLogin;
          //           });
          //         },
          // ),

          // Login Form
          Form(
            key: _loginFormKey,
            child: AnimatedOpacity(
              opacity: isLogin ? 1.0 : 0.0,
              duration: animationDuration * 4,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: size.width,
                  height: defaultLoginSize,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),

                        SizedBox(height: 40),

                        Lottie.asset('assets/animations/login.json',
                            height: MediaQuery.of(context).size.height / 3),
                        // SvgPicture.asset('assets/svgs/login.svg'),

                        SizedBox(height: 40),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          width: size.width * 0.8,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: kPrimaryColor.withAlpha(50)),
                          //LoginEmail
                          child: TextFormField(
                            cursorColor: kPrimaryColor,
                            decoration: InputDecoration(
                                icon: Icon(Icons.mail, color: kPrimaryColor),
                                hintText: 'E-mail',
                                border: InputBorder.none),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter email!';
                              }
                              if (!isValidMail(value)) {
                                return 'Invalid email!';
                              }
                              return null;
                              // return null;
                            },
                            onSaved: (value) {
                              _authData['email'] = value!;
                            },
                          ),
                        ),

                        // RoundedInput(icon: Icons.mail, hint: 'Username'),

                        //LoginPassword
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          width: size.width * 0.8,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: kPrimaryColor.withAlpha(50)),
                          child: TextFormField(
                            obscureText: !showPassword,
                            cursorColor: kPrimaryColor,
                            decoration: InputDecoration(
                              icon: Icon(Icons.lock, color: kPrimaryColor),
                              hintText: 'Password',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  print('password show : $showPassword');
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                icon: showPassword
                                    ? Icon(Icons.visibility_off)
                                    : Icon(Icons.visibility),
                              ),
                            ),
                            controller: _passwordController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter password!';
                              }
                              if (value.length < 5) {
                                return 'Password is too short!';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _authData['password'] = value!;
                            },
                          ),
                        ),

                        // RoundedPasswordInput(hint: 'Password'),

                        SizedBox(height: 10),
                        //LoginButton
                        if (_isLoading)
                          if (Platform.isAndroid)
                            CircularProgressIndicator()
                          else
                            CupertinoActivityIndicator()
                        else
                          InkWell(
                            onTap: _submit,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              width: size.width * 0.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: kPrimaryColor,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 20),
                              alignment: Alignment.center,
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),

                        // RoundedButton(title: 'LOGIN'),

                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // LoginForm(
          //     isLogin: isLogin,
          //     animationDuration: animationDuration,
          //     size: size,
          //     defaultLoginSize: defaultLoginSize),

          // Register Container
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              if (viewInset == 0 && isLogin) {
                return buildRegisterContainer();
              } else if (!isLogin) {
                return buildRegisterContainer();
              }

              // Returning empty container to hide the widget
              return Container();
            },
          ),

          // Register Form
          Form(
            key: _registerFormKey,
            child: AnimatedOpacity(
              opacity: isLogin ? 0.0 : 1.0,
              duration: animationDuration * 5,
              child: Visibility(
                visible: !isLogin,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: size.width,
                    height: defaultRegisterSize,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Text(
                            'Welcome',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          SizedBox(height: 40),
                          Lottie.asset('assets/animations/register.json',
                              height: MediaQuery.of(context).size.height / 3),
                          // SvgPicture.asset('assets/svgs/register.svg'),
                          SizedBox(height: 40),
                          //RegisterName
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: size.width * 0.8,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: kPrimaryColor.withAlpha(50)),
                            child: TextFormField(
                              cursorColor: kPrimaryColor,
                              decoration: InputDecoration(
                                icon: Icon(Icons.face_rounded,
                                    color: kPrimaryColor),
                                hintText: 'Name',
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter name!';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _authData['displayName'] = value!.capitalize();
                              },
                            ),
                          ),
                          //RegisterEmail
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: size.width * 0.8,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: kPrimaryColor.withAlpha(50)),
                            child: TextFormField(
                              cursorColor: kPrimaryColor,
                              decoration: InputDecoration(
                                icon: Icon(Icons.mail, color: kPrimaryColor),
                                hintText: 'Email',
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter email!';
                                }
                                if (!isValidMail(value)) {
                                  return 'Invalid email!';
                                }
                                return null;
                                // return null;
                              },
                              onSaved: (value) {
                                _authData['email'] = value!;
                              },
                            ),
                          ),
                          //RegisterPassword
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: size.width * 0.8,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: kPrimaryColor.withAlpha(50)),
                            child: TextFormField(
                              obscureText: !showPassword,
                              cursorColor: kPrimaryColor,
                              decoration: InputDecoration(
                                icon: Icon(Icons.lock, color: kPrimaryColor),
                                hintText: 'Password',
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    print('password show : $showPassword');
                                    setState(() {
                                      showPassword = !showPassword;
                                    });
                                  },
                                  icon: showPassword
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                                ),
                              ),
                              controller: _passwordController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter password!';
                                }
                                if (value.length < 5) {
                                  return 'Password is too short!';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _authData['password'] = value!;
                              },
                            ),
                          ),
                          //RegisterPasswordConfirm
                          // Container(
                          //   margin: EdgeInsets.symmetric(vertical: 10),
                          //   padding: EdgeInsets.symmetric(
                          //       horizontal: 20, vertical: 5),
                          //   width: size.width * 0.8,
                          //   decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(30),
                          //       color: kPrimaryColor.withAlpha(50)),
                          //   child: TextFormField(
                          //     enabled: _authMode == AuthMode.Signup,
                          //     obscureText: true,
                          //     cursorColor: kPrimaryColor,
                          //     decoration: InputDecoration(
                          //       icon: Icon(Icons.lock, color: kPrimaryColor),
                          //       hintText: 'Confirm Password',
                          //       border: InputBorder.none,
                          //     ),
                          //     validator: _authMode == AuthMode.Signup
                          //         ? (value) {
                          //             if (value != _passwordController.text) {
                          //               return 'Passwords do not match!';
                          //             }
                          //             return null;
                          //           }
                          //         : null,
                          //   ),
                          // ),
                          SizedBox(height: 10),
                          //RegisterButton
                          if (_isLoading)
                            if (Platform.isAndroid)
                              CircularProgressIndicator()
                            else
                              CupertinoActivityIndicator()
                          else
                            InkWell(
                              onTap: _submit,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                width: size.width * 0.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: kPrimaryColor,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 20),
                                alignment: Alignment.center,
                                child: Text(
                                  'SIGN UP',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // RegisterForm(
          //     isLogin: isLogin,
          //     animationDuration: animationDuration,
          //     size: size,
          //     defaultLoginSize: defaultRegisterSize),
        ],
      ),
    );
  }

  Widget buildRegisterContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: containerSize.value,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100),
              topRight: Radius.circular(100),
            ),
            color: kBackgroundColor),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: !isLogin
              ? null
              : () {
                  animationController.forward();
                  _switchAuthMode();
                  setState(() {
                    isLogin = !isLogin;
                    _passwordController.clear();
                  });
                },
          child: isLogin
              ? Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(color: kPrimaryColor, fontSize: 18),
                )
              : null,
        ),
      ),
    );
  }
}
