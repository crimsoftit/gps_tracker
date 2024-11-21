// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationDisplayScreen extends StatefulWidget {
  const LocationDisplayScreen({super.key});

  @override
  State<LocationDisplayScreen> createState() => _LocationDisplayScreenState();
}

class _LocationDisplayScreenState extends State<LocationDisplayScreen> {
  String? currentAddress;
  Position? currentPosition;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'location services are disabled! please enable the services.',
          ),
        ),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'location permissions are denied!!',
            ),
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();

    if (!hasPermission) return;

    // await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
    //     .then((Position position) {
    //   setState(() => currentPosition = position);
    // }).catchError((e) {
    //   debugPrint(e);
    // });

    await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    ).then((Position position) {
      setState(() {
        currentPosition = position;
      });
      getAddressFromLatLng(currentPosition!);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('error fetching current position'),
        ),
      );
      debugPrint(e);
    });
  }

  Future<void> getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            currentPosition!.latitude, currentPosition!.longitude)
        .then(
      (List<Placemark> placemarks) {
        Placemark place = placemarks[0];
        setState(
          () {
            currentAddress =
                '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea} ${place.postalCode}';
          },
        );
      },
    ).catchError((onError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('error fetching current position'),
        ),
      );
      debugPrint(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location Display Page")),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('LAT: ${currentPosition?.latitude ?? ""}'),
              Text('LNG: ${currentPosition?.longitude ?? ""}'),
              Text('ADDRESS: ${currentAddress ?? ""}'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: getCurrentPosition,
                child: const Text("Get Current Location"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
