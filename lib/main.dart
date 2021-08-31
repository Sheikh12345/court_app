import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/buyer_home/v_bottom_navigation.dart';
import 'screens/splash/splash_screen.dart';
import 'methods/firebase_methods.dart';
import 'utils/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/lawyer_home/b_bottom_navigation.dart';
import 'utils/routes.dart';
import 'screens/admin_home/v_bottom_navigation.dart';
import 'screens/block_home/v_bottom_navigation.dart';
import 'screens/delete_home/v_bottom_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  // This widget is the screens.root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String initRoute;
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null && user.emailVerified)
      return FutureBuilder(
        future: getRole(FirebaseAuth.instance.currentUser.email),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == "Customer") {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'E - CASE',
              theme: theme(),
              initialRoute: BuyerBottomNavigation.routeName,
              routes: routes,
            );
          } else if (snapshot.data == "Lawyer") {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'E - CASE',
              theme: theme(),
              initialRoute: SellerBottomNavigation.routeName, // DriverBottom
              routes: routes,
            );
          } else if (snapshot.data == "Admin") {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'E - CASE',
              theme: theme(),
              initialRoute: AdminBottomNavigation.routeName, // DriverBottom
              routes: routes,
            );
          } else if (snapshot.data == "Deleted") {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'E - CASE',
              theme: theme(),
              initialRoute: DeletedBottomNavigation.routeName, // DriverBottom
              routes: routes,
            );
          } else if (snapshot.data == "Blocked") {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'E - CASE',
              theme: theme(),
              initialRoute: BlockedBottomNavigation.routeName, // DriverBottom
              routes: routes,
            );
          }

          return Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    else
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E - CASE',
        theme: theme(),
        initialRoute: SplashScreen.routeName,
        routes: routes,
      );
  }
}
