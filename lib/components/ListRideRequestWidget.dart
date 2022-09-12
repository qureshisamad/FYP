import 'RideRequestModelClass.dart';
// import 'package:fetch_my_car/Model/VehicleList.dart';
// import 'package:fetch_my_car/components/ViewVehicle.dart';
import 'package:flutter/material.dart';

class ListRideRequestWidget extends StatelessWidget {
  final RideRequestModelClass item;
  final Animation<double> animation;
  final VoidCallback? onCancel;
  final VoidCallback? onDone;
  final BuildContext context;

  const ListRideRequestWidget(
      {Key? key,
      required this.item,
      required this.animation,
      this.onCancel,
      this.onDone,
      required this.context})
      : super(key: key);

  @override
  Widget build(BuildContext context) => SizeTransition(
      key: ValueKey('images/civic.png'),
      sizeFactor: animation,
      child: buildItem());

  Widget buildItem() => Container(
        child: Card(
          color: Color(0xff453658),
          elevation: 8,
          child: ListTile(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return new AlertDialog(
                        title: new Text("My Super title"),
                        content: new Text("Hello World"),
                      );
                    });
              },
              title: Text(
                '${item.userName}',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  'Date: ${item.rideDate} ${item.ridetime}\nFrom:${item.userSourceLon}\nTo: ${item.userDestinationLon}',
                  style: TextStyle(color: Colors.white)),
              leading: Image.asset(
                'assets/FYPLogo.png',
                width: 52,
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    Expanded(
                        child: button(
                            Icons.cancel_outlined, onCancel, Colors.red)),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(child: button(Icons.check, onDone, Colors.white)),
                  ],
                ),
              )),
        ),
      );

  Widget button(IconData icon, VoidCallback? call, Color color) =>
      ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xff392850)),
            elevation: MaterialStateProperty.all(10),
            padding: MaterialStateProperty.all(EdgeInsets.all(5))),
        onPressed: call,
        child: Icon(icon, color: color),
      );
}
