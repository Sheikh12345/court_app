import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:court_app/screens/block_home/v_bottom_navigation.dart';
import 'package:court_app/screens/delete_home/v_bottom_navigation.dart';
import 'package:court_app/utils/size_config.dart';
import 'package:flutter/material.dart';
import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../screens/lawyer_home/b_bottom_navigation.dart';
import '../../../screens/forgot_password/forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../screens/buyer_home/v_bottom_navigation.dart';
import '../../../widgets/alert_dialog.dart';
import '../../../widgets/loading_alert_dailog.dart';
import '../../../widgets/snack_bar.dart';
import '../../../screens/admin_home/v_bottom_navigation.dart';
import '../../../components/default_button.dart';
import 'package:court_app/utils/constants.dart';

class SignForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();

  String _role;

  final auth = FirebaseAuth.instance;
  User user;
  String email;
  String password;
  bool remember = false;

  final List<String> errors = [];

  void addError({String error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          Row(
            children: [
              Checkbox(
                value: remember,
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    remember = value;
                  });
                },
              ),
              Text("Remember me"),
              Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, ForgotPasswordScreen.routeName),
                child: Text(
                  "Forgot Password",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(20)),
          DefaultButton(
            text: "Sign in",
            press: () async {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(email)
                    .get()
                    .then((value) => {
                          showLoadingDialog(context),
                          signInUser(email, password, context, value),
                        })
                    .catchError((e) {
                  addError(error: "Please enter valid email");
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Email or password is wrong",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }
            },
          ),
        ],
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        setState(() {
          if (value.isNotEmpty) {
            removeError(error: kPassNullError);
          } else if (value.length >= 8) {
            removeError(error: kShortPassError);
          }
          password = value;
        });
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        // If  you are using latest version of flutter then label text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
        email = value;
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "Enter your email",
        // If  you are using latest version of flutter then label text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }

  Future signInUser(email, password, context, value) async {
    _role = value.get('Role');
    print("Role => $_role");
    auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      if (value.user.emailVerified) {
        if (_role == "Customer") {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => BuyerBottomNavigation()),
              (Route<dynamic> route) => false);
        } else if (_role == "Lawyer") {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => SellerBottomNavigation()),
              (Route<dynamic> route) => false);
        } else if (_role == "Admin") {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => AdminBottomNavigation()),
              (Route<dynamic> route) => false);
        } else if (_role == "Deleted") {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => DeletedBottomNavigation()),
              (Route<dynamic> route) => false);
        } else if (_role == "Blocked") {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => BlockedBottomNavigation()),
              (Route<dynamic> route) => false);
        }

        // print(snapshot.data);
      } else {
        String title = "Email not verified";
        String content = "Please verify the Email first to SigIn.";
        verifyEmailDialog(context, title, content);
      }
    }).catchError((e) {
      Navigator.pop(context);
      Snack_Bar.show(context, e.message);
    });
  }
}
