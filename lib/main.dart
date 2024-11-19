import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter GPS Location Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter GPS Location Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String data = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'your location address is:',
            ),
            Text(
              data,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getPosition,
        tooltip: 'your location',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void getPosition() async {
    var status = await Permission.location.request();

    if (status == PermissionStatus.granted) {
      Position positionData = await determinePosition();
      getUserAddressFromLatLong(positionData);
    }
  }

  determinePosition() async {
    bool locationServicesEnabled;
    LocationPermission locationPermission;

    locationServicesEnabled = await Geolocator.isLocationServiceEnabled();

    if (!locationServicesEnabled) {
      return Future.error(
          'please enable location services on your device to proceed');
    }

    locationPermission = await Geolocator.checkPermission();

    if (locationPermission == LocationPermission.denied) {
      return Future.error(
          'permission to use location services denied for now!!');
    } else if (locationPermission == LocationPermission.deniedForever) {
      return Future.error(
          'permission to use location services denied forever!!');
    }

    return await Geolocator.getCurrentPosition();
  }

  void getUserAddressFromLatLong(Position positionInfo) async {
    List<Placemark> placemark = await placemarkFromCoordinates(
        positionInfo.latitude, positionInfo.longitude);

    Placemark place = placemark[0];

    var userAddress = "${place.street}, ${place.country}";

    setState(() {
      data = userAddress;
    });
  }
}
