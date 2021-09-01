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

class LawyerEditProfile extends StatefulWidget {
  static String routeName = "/driver_edit_profile";

  @override
  _LawyerEditProfileState createState() => _LawyerEditProfileState();
}

class _LawyerEditProfileState extends State<LawyerEditProfile> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];

  int isCourtType = 0;
  int isSpecificField = 0;

  String storeName;
  String dropdownResultSpecificField = '';
  String dropdownResultCourtType = '';
  String storeCnic;
  String storeAddress;
  String storePhoneNo;
  String storeBarCouncil;
  String storeCourtType;
  String storeSpecialization;
  String storeBarMembership;
  String storeHighCourtMembership;
  String storeLicense;

  String name;
  String cnic;
  String address;
  String phoneNo;
  String barCouncil;
  String courtType;
  String specialization;
  String barMembership;
  String highCourtMembership;
  String license;

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
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 600), () {
      setState(() {});
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
              return SpinKitCircle(
                color: kPrimaryColor,
              );
            storeName = snapshot.data['Name'];
            storeCnic = snapshot.data['CNIC'];
            storePhoneNo = snapshot.data['PhoneNo'];
            storeAddress = snapshot.data['Address'];
            storeBarCouncil = snapshot.data['BarCouncil'];
            storeCourtType = snapshot.data['CourtType'];
            storeSpecialization = snapshot.data['Specialization'];
            storeBarMembership = snapshot.data['barMembership'];
            storeHighCourtMembership = snapshot.data['highCourtMembership'];
            storeLicense = snapshot.data['license'];

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
                          buildDistrictBarMembershipFormField(),
                          SizedBox(height: getProportionateScreenHeight(30)),
                          buildHighCourtBarMembershipFormField(),
                          SizedBox(height: getProportionateScreenHeight(30)),
                          buildLicenseFormField(),
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
                                  barCouncil = storeBarCouncil;
                                }
                                if (courtType == null) {
                                  courtType = storeCourtType;
                                }
                                if (specialization == null) {
                                  specialization = storeSpecialization;
                                }
                                if (barMembership == null) {
                                  barMembership = storeBarMembership;
                                }
                                if (highCourtMembership == null) {
                                  highCourtMembership =
                                      storeHighCourtMembership;
                                }

                                if (license == null) {
                                  license = storeLicense;
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
                                    'CourtType': dropdownResultCourtType,
                                    'barMembership': barMembership,
                                    'highCourtMembership':
                                        dropdownResultSpecificField,
                                    'license': license
                                  }).then((value) => {
                                            Navigator.pop(context),
                                            Snack_Bar.show(context,
                                                "Profile Updated Successfully!")
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
        suffixIcon:
            CustomSuffixIcon(svgIcon: "assets/icons/driving-license.svg"),
      ),
    );
  }

  courtTypeFormField() {
    if (isCourtType != 1) {
      dropdownResultCourtType = storeCourtType;
      isCourtType = 1;
    }
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      height: 60,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey, width: 1)),
      child: DropdownButton<String>(
        underline: Container(),
        isExpanded: true,
        hint: Text(dropdownResultCourtType ?? 'Court type'),
        items: courtTypeList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: new Text(
              value,
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            dropdownResultCourtType = value;
          });
        },
      ),
    );
  }

  specializationFormField() {
    if (isSpecificField != 1) {
      setState(() {
        dropdownResultSpecificField = storeSpecialization;
        isSpecificField = 1;
      });
    }
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      height: 60,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey, width: 1)),
      child: DropdownButton<String>(
        underline: Container(),
        isExpanded: true,
        hint: dropdownResultSpecificField != null
            ? Text(dropdownResultSpecificField)
            : Text('Specific field'),
        items: specificFieldList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: new Text(value),
          );
        }).toList(),
        onChanged: (value) {
          print(value.toString());
          setState(() {
            dropdownResultSpecificField = value;
          });
        },
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

  TextFormField buildDistrictBarMembershipFormField() {
    return TextFormField(
      initialValue: storeBarMembership,
      keyboardType: TextInputType.name,
      onSaved: (newValue) => barMembership = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNamelNullError);
          barMembership = value;
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
        labelText: "District bar membership",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildHighCourtBarMembershipFormField() {
    return TextFormField(
      initialValue: storeHighCourtMembership,
      keyboardType: TextInputType.name,
      onSaved: (newValue) => highCourtMembership = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNamelNullError);
          highCourtMembership = value;
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
        labelText: "High court bar membership",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildLicenseFormField() {
    return TextFormField(
      initialValue: storeLicense,
      keyboardType: TextInputType.name,
      onSaved: (newValue) => license = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNamelNullError);
          license = value;
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
          labelText: "License",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: Container(
            child: Icon(Icons.confirmation_number_outlined),
            margin: EdgeInsets.only(right: 14),
          )),
    );
  }
}
