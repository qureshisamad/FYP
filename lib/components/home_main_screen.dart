import 'package:fyp/components/driver_main.dart';
import 'package:fyp/components/login_screen.dart';
import 'package:fyp/components/pendingApproval.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:humanitarian_icons/humanitarian_icons.dart';
import 'Home.dart';
import '/components/UserProfile.dart';
import 'mapPractice.dart';
import '/components/chat.dart';
import '/components/searchRide.dart';
import '/components/side_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/pages/profile_page.dart';
import 'vehicleReg.dart';

class HomeScreen extends StatefulWidget {
  final currentUser;
  const HomeScreen({Key? key, required this.currentUser}) : super(key: key);
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  int index = 0;

  void initState() {
    super.initState();
  }

  List<Widget> _buildScreens() {
    return [
      MapView(),
      DriverHomeScreen(),
      // PendingApproval(
      //   currentUser: widget.currentUser,
      // ),
      // Home(),
      // VehicleDetails(),
      // Chat(),
      UserProfile(
        currentUser: widget.currentUser,
      ),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home),
        title: ("Home"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          HumanitarianIcons.ambulance,
          // size: 35.0,
        ),
        title: ("Current"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.profile_circled),
        title: ("Settings"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        drawer: new Drawer(
          child: new ListView(
            children: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text("LogOut"))
            ],
          ),
        ),
        bottomNavigationBar: PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          confineInSafeArea: true,
          backgroundColor: Colors.white, // Default is Colors.white.
          handleAndroidBackButtonPress: true, // Default is true.
          resizeToAvoidBottomInset:
              true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
          stateManagement: true, // Default is true.
          hideNavigationBarWhenKeyboardShows:
              true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Colors.white,
          ),
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: ItemAnimationProperties(
            // Navigation Bar's items animation properties.
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: ScreenTransitionAnimation(
            // Screen transition animation on change of selected tab.
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle
              .neumorphic, // Choose the nav bar style with this property.
        ));
  }
}
