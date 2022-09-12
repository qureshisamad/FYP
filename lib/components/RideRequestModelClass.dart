class RideRequestModelClass {
  final String ride_id;
  final String driver_id;
  final String user_id;
  final String vehicle_id;
  final String userName;
  final double userDestinationLat;
  final double userDestinationLon;
  final double userSourceLat;
  final double userSourceLon;
  final String rideDate;
  final String ridetime;
  final double rideFare;
  final double totalKms;
  final String status;

  RideRequestModelClass(
      {required this.rideFare,
      required this.totalKms,
      required this.ridetime,
      required this.rideDate,
      required this.ride_id,
      required this.driver_id,
      required this.user_id,
      required this.vehicle_id,
      required this.userName,
      required this.userDestinationLat,
      required this.userDestinationLon,
      required this.userSourceLat,
      required this.userSourceLon,
      required this.status});
}
