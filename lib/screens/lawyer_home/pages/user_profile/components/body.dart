import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../../screens/lawyer_home/pages/user_profile/components/profile_menu.dart';
import '../../../../../screens/lawyer_home/pages/user_profile/components/profile_pic.dart';
import '../../../../../screens/edit_profiles/b_edit_profile.dart';
import '../../../../../screens/sign_in/sign_in_screen.dart';
import 'aboutUs.dart';
import '../../../../../widgets/snack_bar.dart';

class LawyerBody extends StatefulWidget {
  @override
  _LawyerBodyState createState() => _LawyerBodyState();
}

class _LawyerBodyState extends State<LawyerBody> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            LawyerProfilePic(),
            SizedBox(
              height: 10,
            ),
            LawyerProfileMenu(
              icon: 'assets/icons/User Icon.svg',
              text: 'Edit Profile',
              press: () {
                Navigator.pushNamed(context, LawyerEditProfile.routeName);
              },
            ),
            // DriverProfileMenu(
            //   icon: 'assets/icons/Settings.svg',
            //   text: 'Settings',
            //   press: () {},
            // ),
            LawyerProfileMenu(
              icon: 'assets/icons/Question mark.svg',
              text: 'Help Center',
              press: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => AboutUs()));
              },
            ),
            LawyerProfileMenu(
              icon: 'assets/icons/Log out.svg',
              text: 'Log Out',
              press: () async {
                FirebaseAuth.instance.signOut().whenComplete(() {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                }).catchError((e) {
                  Snack_Bar.show(context, e.message);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
