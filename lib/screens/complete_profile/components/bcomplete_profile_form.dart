import 'package:court_app/utils/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../components/custom_surfix_icon.dart';
import '../../../components/default_button.dart';
import '../../../components/form_error.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../screens/sign_up/verificationts.dart';

import 'package:court_app/utils/constants.dart';


class BCompleteProfileForm extends StatefulWidget {
  @override
  _BCompleteProfileFormState createState() => _BCompleteProfileFormState();
}

class _BCompleteProfileFormState extends State<BCompleteProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];

  String name;
  String cnic;
  String city;
  String address;
  String phoneNo;
  String barCouncil;
  String specialization;
  String courtType;

  final auth = FirebaseAuth.instance;
  User user;

  void nextField(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  //End

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
          buildNameFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildCNICFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPhoneNumberFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          barCouncilField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          specificField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          courtTypeField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildCityFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildAddressFormField(),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(40)),
          DefaultButton(
            text: "Continue",
            press: () async {
              if (_formKey.currentState.validate()) {
                try {
                  await FirebaseFirestore.instance
                      .collection('Lawyers')
                      .doc(auth.currentUser.email)
                      .set({
                    'Name': name,
                    'CNIC': cnic,
                    'Address': address,
                    'PhoneNo': phoneNo,
                    'BarCouncil': barCouncil,
                    'Specialization': specialization,
                    'CourtType': courtType,
                    'overAllRating':"0.0",
                    'city':city,
                    'Email': FirebaseAuth.instance.currentUser.email,
                  });
                  FirebaseAuth.instance.currentUser.updateDisplayName(name);
                  //Confusion
                  Navigator.pushNamed(
                      context, Verifications.routeName);
                } catch (e) {
                  print(e);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Container buildAddressFormField() {
    return Container(
      height: 150,
      child: TextFormField(
        expands: true,
        minLines: null,
        maxLines: null,
        keyboardType: TextInputType.streetAddress,
        onSaved: (newValue) => address = newValue,
        onChanged: (value) {
          if (value.isNotEmpty) {
            removeError(error: kAddressNullError);
          }
          address = value;
        },
        validator: (value) {
          if (value.isEmpty) {
            addError(error: kAddressNullError);
            return "";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: "Address",
          hintText: "Enter your Home address",
          // If  you are using latest version of flutter then lable text and hint text shown like this
          // if you r using flutter less then 1.20.* then maybe this is not working properly
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon:
              CustomSuffixIcon(svgIcon: "assets/icons/Location point.svg"),
        ),
      ),
    );
  }

  TextFormField specificField() {
    return TextFormField(
      keyboardType: TextInputType.name,
      onSaved: (newValue) => specialization = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kDrivingLicenseNumberError);
        }
        specialization = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kDrivingLicenseNumberError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Specific Field",
        hintText: "Enter your Specific Field",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/driving-license.svg"),
      ),
    );
  }

  TextFormField courtTypeField() {
    return TextFormField(
      keyboardType: TextInputType.name,
      onSaved: (newValue) => courtType = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNumberPlateError);
        }
        courtType = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kNumberPlateError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Court Type",
        hintText: "Enter your Court Type",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/license-plate.svg"),
      ),
    );
  }

  TextFormField barCouncilField() {
    return TextFormField(
      keyboardType: TextInputType.name,
      onSaved: (newValue) => barCouncil = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kRegistrationError);
        }
        barCouncil = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kRegistrationError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Bar Council",
        hintText: "Enter your Bar Council",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/van.svg"),
      ),
    );
  }

  TextFormField buildPhoneNumberFormField() {
    return TextFormField(
      initialValue: '+92',
      maxLength: 13,
      keyboardType: TextInputType.phone,
      onSaved: (newValue) => phoneNo = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPhoneNumberNullError);
        }
        phoneNo = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPhoneNumberNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Phone Number",
        hintText: "Enter your phone number",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }

  TextFormField buildCNICFormField() {
    return TextFormField(
      maxLength: 13,
      keyboardType: TextInputType.number,
      onSaved: (newValue) => cnic = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kCNICError);
        }
        cnic = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kCNICError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "CNIC",
        hintText: "Enter your CNIC",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon:
            CustomSuffixIcon(svgIcon: "assets/icons/card.svg"),
      ),
    );
  }

  TextFormField buildNameFormField() {
    return TextFormField(
      keyboardType: TextInputType.name,
      onSaved: (newValue) => name = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNamelNullError);
        }
        name = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kNamelNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Name",
        hintText: "Enter your name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

      TextFormField buildCityFormField() {
    return TextFormField(
      keyboardType: TextInputType.name,
      onSaved: (newValue) => city = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNamelNullError);
        }
        city = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kNamelNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "City",
        hintText: "Enter your City",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }


}
