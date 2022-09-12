import 'package:flutter/material.dart';
import 'package:fyp/components/driver_main.dart';
import 'package:fyp/components/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SideDrawer extends StatefulWidget {
  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  bool _isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.red),
            accountName: Text('PERSON'),
            accountEmail: Text('abc@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  'assets/person.jpg',
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Card(
            elevation: 8,
            margin: EdgeInsets.all(10.0),
            child: ListTile(
              leading: Icon(Icons.supervisor_account),
              title: Text('Switch to Driver Mode'),
              trailing: Switch(
                value: _isSwitched,
                onChanged: (value) {
                  setState(() {
                    _isSwitched = value;
                  });
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DriverHomeScreen()));
                },
                activeColor: Colors.red,
                activeTrackColor: _isSwitched ? Colors.red : Colors.grey,
              ),
            ),
          ),
          Divider(
            height: 5,
          ),
          ListTile(
            leading: Icon(Icons.event_available),
            title: Text('Booked Rides'),
            onTap: null,
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
            onTap: null,
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Request'),
            onTap: null,
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: null,
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Policies'),
            onTap: null,
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('LogOut'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  ((route) => false));
            },
          ),
        ],
      ),
    );
  }
}
