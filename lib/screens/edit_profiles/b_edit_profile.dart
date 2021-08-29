import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:court_app/utils/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../components/custom_surfix_icon.dart';
import '../../components/default_button.dart';
import '../../components/form_error.dart';
import 'package:court_app/utils/constants.dart';
import '../../widgets/loading_alert_dailog.dart';
import '../../widgets/snack_bar.dart';

class SellerEditProfile extends StatefulWidget {
  static String routeName = "/driver_edit_profile";

  @override
  _SellerEditProfileState createState() => _SellerEditProfileState();
}

class _SellerEditProfileState extends State<SellerEditProfile> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];

  String storeName;
  String storeCnic;
  String storeAddress;
  String storePhoneNo;
  String storeBarCouncil;
  String storeCourtType;
  String storeSpecialization;

  String name;
  String cnic;
  String address;
  String phoneNo;
  String barCouncil;
  String courtType;
  String specialization;

  void addError({String error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String error}) {
    if (!errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Edit Profile",
            style: TextStyle(
              color: Color(0XFF8B8B8B),
            ),
          ),
          elevation: 2,
          centerTitle: true,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Lawyers')
              .doc(FirebaseAuth.instance.currentUser.email)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.data == null)
              return SpinKitCircle(color: kPrimaryColor,);
            storeName = snapshot.data['Name'];
            storeCnic = snapshot.data['CNIC'];
            storePhoneNo = snapshot.data['PhoneNo'];
            storeAddress = snapshot.data['Address'];
            storeBarCouncil = snapshot.data['BarCouncil'];
            storeCourtType = snapshot.data['CourtType'];
            storeSpecialization = snapshot.data['Specialization'];
            return SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(20)),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Container(
                      child: Column(
                        children: [
                          SizedBox(height: SizeConfig.screenHeight * 0.03),
                          Text(
                            "You can edit your profile here!",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: getProportionateScreenHeight(30)),
                          buildNameFormField(),
                          SizedBox(height: getProportionateScreenHeight(30)),
                          buildCNICFormField(),
                          SizedBox(height: getProportionateScreenHeight(30)),
                          buildPhoneNumberFormField(),
                          SizedBox(height: getProportionateScreenHeight(30)),
                          barCouncilFormField(),
                          SizedBox(height: getProportionateScreenHeight(30)),
                          courtTypeFormField(),
                          SizedBox(height: getProportionateScreenHeight(30)),
                          specializationFormField(),
                          SizedBox(height: getProportionateScreenHeight(30)),
                          buildAddressFormField(),
                          SizedBox(height: getProportionateScreenHeight(20)),
                          FormError(errors: errors),
                          SizedBox(height: getProportionateScreenHeight(20)),
                          DefaultButton(
                            text: "Update",
                            press: () async {
                              if (_formKey.currentState.validate()) {
                                if (name == null) {
                                  name = storeName;
                                }
                                if (address == null) {
                                  address = storeAddress;
                                }
                                if (phoneNo == null) {
                                  phoneNo = storePhoneNo;
                                }
                                if (cnic == null) {
                                  cnic = storeCnic;
                                }
                                if (barCouncil == null) {
                                  barCouncil =
                                      storeBarCouncil;
                                }
                                if (courtType == null) {
                                  courtType =
                                      storeCourtType;
                                }
                                if (specialization == null) {
                                  specialization =
                                      storeSpecialization;
                                }
                                showLoadingDialog(context);
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('Lawyers')
                                      .doc(FirebaseAuth
                                          .instance.currentUser.email)
                                      .update({
                                    'Name': name,
                                    'CNIC': cnic,
                                    'Address': address,
                                    'PhoneNo': phoneNo,
                                    'Specialization': specialization,
                                    'BarCouncil': barCouncil,
                                    'CourtType': courtType,
                                  }).then((value) => {
                                    Navigator.pop(context),
                                    Snack_Bar.show(context, "Profile Updated Successfully!")
                                  });
                                } catch (e) {
                                  print(e);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }

  Container buildAddressFormField() {
    return Container(
      height: 150,
      child: TextFormField(
        expands: true,
        minLines: null,
        maxLines: null,
        initialValue: storeAddress,
        keyboardType: TextInputType.streetAddress,
        onSaved: (newValue) => address = newValue,
        onChanged: (value) {
          if (value.isNotEmpty) {
            removeError(error: kAddressNullError);
            address = value;
          }
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
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon:
              CustomSuffixIcon(svgIcon: "assets/icons/Location point.svg"),
        ),
      ),
    );
  }

  TextFormField barCouncilFormField() {
    return TextFormField(
      initialValue: storeBarCouncil,
      keyboardType: TextInputType.name,
      onSaved: (newValue) => barCouncil = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kDrivingLicenseNumberError);
        }
        barCouncil = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kDrivingLicenseNumberError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Bar Council",
        hintText: "Enter your Bar Council",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/driving-license.svg"),
      ),
    );
  }

  TextFormField courtTypeFormField() {
    return TextFormField(
      initialValue: storeCourtType,
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
        labelText: "CourtType",
        hintText: "Enter your CourtType",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/license-plate.svg"),
      ),
    );
  }

  TextFormField specializationFormField() {
    return TextFormField(
      initialValue: storeSpecialization,
      keyboardType: TextInputType.name,
      onSaved: (newValue) => specialization = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kRegistrationError);
        }
        specialization = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kRegistrationError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Specialization",
        hintText: "Enter your Specialization",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/van.svg"),
      ),
    );
  }

  TextFormField buildPhoneNumberFormField() {
    return TextFormField(
      initialValue: storePhoneNo,
      maxLength: 13,
      keyboardType: TextInputType.phone,
      onSaved: (newValue) => phoneNo = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPhoneNumberNullError);
          phoneNo = value;
        }
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
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }

  TextFormField buildCNICFormField() {
    return TextFormField(
      initialValue: storeCnic,
      maxLength: 13,
      keyboardType: TextInputType.number,
      onSaved: (newValue) => cnic = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kCNICError);
          cnic = value;
        }
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
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/card.svg"),
      ),
    );
  }

  TextFormField buildNameFormField() {
    return TextFormField(
      initialValue: storeName,
      keyboardType: TextInputType.name,
      onSaved: (newValue) => name = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNamelNullError);
          name = value;
        }
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
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }
}