import 'package:court_app/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'components/body.dart';

class SignInAs extends StatefulWidget {
  static String routeName = "/sign_in_as_screen";
  @override
  _SignInAsState createState() => _SignInAsState();
}

class _SignInAsState extends State<SignInAs> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Sign In As"),
        ),
        body: SafeArea(child: Body()));
  }
}
