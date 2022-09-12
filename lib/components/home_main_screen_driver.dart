import 'package:fyp/components/RideRequests.dart';
import 'package:fyp/components/currentRideDriverPickup.dart';
import 'package:fyp/components/driver_main.dart';
import 'package:fyp/components/login_screen.dart';
import 'package:fyp/components/pendingApproval.dart';

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
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class HomeScreenDriver extends StatefulWidget {
  final currentUser;
  const HomeScreenDriver({Key? key, required this.currentUser})
      : super(key: key);
  _HomeScreenDriver createState() => _HomeScreenDriver();
}

class _HomeScreenDriver extends State<HomeScreenDriver> {
  //  _controller;

  PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  int index = 0;

  void initState() {
    super.initState();
  }

  List<Widget> _buildScreens() {
    return [
      DriverHomeScreen(),
      // CurrentRideDriverPickup(rideData: widget.currentUser),
      RideRequests(currentUser: widget.currentUser),
      UserProfile(currentUser: widget.currentUser),

      // DriverHomeScreen(),
      // PendingApproval(
      //   currentUser: widget.currentUser,
      // ),
      // Home(),
      // VehicleDetails(),
      // Chat(),
      // UserProfile(
      //   currentUser: widget.currentUser,
      // ),
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
        icon: Icon(CupertinoIcons.car_fill),
        title: ("Current"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.settings),
        title: ("Settings"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  Widget build(BuildContext context) {
    return Scaffold(
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


  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     home: Scaffold(
  //       drawer: SideDrawer(),
  //       // appBar: AppBar(
  //       //   centerTitle: true,
  //       //   title: Row(
  //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       //     children: [
  //       //       Container(
  //       //           padding: const EdgeInsets.all(8.0),
  //       //           child: Text('E-AMBULANCE')),
  //       //       Image.asset(
  //       //         'assets/FYPLogo2.png',
  //       //         fit: BoxFit.contain,
  //       //         height: 80,
  //       //         width: 80,
  //       //       ),
  //       //     ],
  //       //   ),
  //       //   backgroundColor: Colors.red,
  //       // ),
  //       body: listOfWidgets.elementAt(index),
  //       bottomNavigationBar: BottomNavigationBar(
  //         backgroundColor: Colors.red,
  //         fixedColor: Colors.red,
  //         type: BottomNavigationBarType.shifting,
  //         unselectedItemColor: Colors.grey,
  //         currentIndex: index,
  //         elevation: 5,
  //         items: [
  //           BottomNavigationBarItem(
  //             icon: Icon(Icons.home),
  //             label: 'Home',
  //           ),
  //           // BottomNavigationBarItem(
  //           //   icon: Icon(Icons.search),
  //           //   label: 'Search',
  //           // ),
  //           // BottomNavigationBarItem(
  //           //   icon: Icon(Icons.chat),
  //           //   label: 'chat',
  //           // ),
  //           BottomNavigationBarItem(
  //             icon: Icon(Icons.person),
  //             label: 'Profile',
  //           ),
  //         ],
  //         onTap: _onTapBottomNavigation,
  //       ),
  //     ),
  //   );
  // }

