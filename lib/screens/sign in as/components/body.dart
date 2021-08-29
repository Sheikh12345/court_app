import 'package:court_app/components/default_button.dart';
import 'package:court_app/screens/sign_in/sign_in_screen.dart';
import 'package:court_app/utils/size_config.dart';
import 'package:flutter/material.dart';


class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int _value = 1;
  int lawyer = 1;
  int customer = 3;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[

                SizedBox(height: SizeConfig.screenHeight * 0.09),

                ListTile(
                  title: Text(
                    'Lawyer',
                  ),
                  leading: Radio(
                    value: lawyer,
                    groupValue: _value,
                    activeColor: Color(0xFF6200EE),
                    onChanged: (int value) {
                      setState(() {
                        print(value);
                        _value = value;
                      });
                    },
                  ),
                ),

                ListTile(
                  title: Text(
                    'Customer',
                  ),
                  leading: Radio(
                    value: customer,
                    groupValue: _value,
                    activeColor: Color(0xFF6200EE),
                    onChanged: (int value) {
                      setState(() {
                        print(value);
                        _value = value;
                      });
                    },
                  ),
                ),

                SizedBox(height: SizeConfig.screenHeight * 0.09),

                DefaultButton(
                  text: "Continue",
                  press: () {
                    Navigator.pushNamed(context, SignInScreen.routeName);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
