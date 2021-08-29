import 'package:court_app/screens/sign%20in%20as/sign_in_as_screen.dart';
import 'package:flutter/widgets.dart';
import '../models/verify_email.dart';
import '../screens/seller_home/pages/home_page.dart';
import '../screens/seller_home/pages/online_users.dart';
import '../screens/seller_home/pages/user_profile/user_profile.dart';
import '../screens/complete_profile/vcomplete_profile_screen.dart';
import '../screens/seller_home/b_bottom_navigation.dart';
import '../screens/edit_profiles/b_edit_profile.dart';
import '../screens/edit_profiles/vendor_edit_profile.dart';
import '../screens/forgot_password/forgot_password_screen.dart';
import '../screens/otp/otp_screen.dart';

import '../screens/buyer_home/pages/chat_screen.dart';
import '../screens/buyer_home/v_bottom_navigation.dart';
import '../screens/registration_success/registration_success_screen.dart';
import '../screens/sign_in/sign_in_screen.dart';
import '../screens/sign_up/verificationts.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/sign_up/sign_up_screen.dart';
import '../screens/buyer_home/pages/aboutUs.dart';
import '../screens/admin_home/v_bottom_navigation.dart';
import '../screens/block_home/v_bottom_navigation.dart';
import '../screens/delete_home/v_bottom_navigation.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  SignInAs.routeName: (context) => SignInAs(),
  SignInScreen.routeName: (context) => SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
  SignUpScreen.routeName: (context) => SignUpScreen(),
  VCompleteProfileScreen.routeName: (context) => VCompleteProfileScreen(),
  OtpScreen.routeName: (context) => OtpScreen(),
  BuyerBottomNavigation.routeName: (context) => BuyerBottomNavigation(),
  VerifyEmail.routeName: (context) => VerifyEmail(),
  RegistrationSuccessScreen.routeName: (context) => RegistrationSuccessScreen(),
  SellerBottomNavigation.routeName: (context) => SellerBottomNavigation(),
  Verifications.routeName: (context) => Verifications(),
  SellerEditProfile.routeName: (context) => SellerEditProfile(),
  ParentEditProfile.routeName: (context) => ParentEditProfile(),
  SellerHomePage.routeName: (context) => SellerHomePage(),
  AppUserPage.routeName: (context) => AppUserPage(),
  AboutUs.routeName: (context) => AboutUs(),
  ChatScreen.routeName: (context) => ChatScreen(),
  OnlineUsersScreen.routeName: (context) => OnlineUsersScreen(),
  AdminBottomNavigation.routeName: (context) => AdminBottomNavigation(),
  BlockedBottomNavigation.routeName: (context) => BlockedBottomNavigation(),
  DeletedBottomNavigation.routeName: (context) => DeletedBottomNavigation(),
};
