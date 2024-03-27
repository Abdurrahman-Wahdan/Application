import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travel/widgets/postScreen.dart';
// import 'package:travel/widgets/home_app_bar.dart';
import 'package:travel/widgets/location_screen.dart'; // Import the LocationScreen
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;

class HomeBottomBar extends StatefulWidget {
  @override
  _HomeBottomBarState createState() => _HomeBottomBarState();
}

class _HomeBottomBarState extends State<HomeBottomBar> {
  File? imageFile;
  loc.Location location = loc.Location();
  var readableLocation = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow color
            spreadRadius: 1, // Spread radius
            blurRadius: 5, // Blur radius
            offset: Offset(0, 2), // Offset of the shadow
          ),
        ],
      ),
      child: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        index: 2,
        items: [
          Icon(Icons.camera_alt, size: 30),
          Icon(Icons.location_pin, size: 30),
          Icon(
            Icons.home,
            size: 30,
            color: Colors.redAccent,
          ),
          Icon(Icons.person, size: 30),
          Icon(Icons.list, size: 30),
        ],
        onTap: (index) {
          if (index == 0) {
            // Show a dialog to ask the user whether to take a picture or choose from gallery
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    "Select an option",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  contentPadding:
                      EdgeInsets.all(30.0), // Adjust the content size
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Material(
                          elevation: 0.0,
                          color: Colors
                              .transparent, // Add elevation for shadow effect
                          child: InkWell(
                            onTap: () => getImage(source: ImageSource.camera),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Take a picture",
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(10.0)),
                        Material(
                          elevation: 0.0,
                          color: Colors
                              .transparent, // Add elevation for shadow effect
                          child: InkWell(
                            onTap: () => getImage(source: ImageSource.gallery),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.photo,
                                  size: 30,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Choose from gallery",
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (index == 1) {
            // Navigate to the LocationScreen when the location button is pressed
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationScreen(),
              ),
            );
          }
        },
      ),
    );
  }

  openGPS() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Request to enable location services
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Handle the case where the user denies enabling location services
        return;
      }
    }

    // Location services are enabled, you can use the location data now
    // If you need to get the current location, you can use location.getLocation()

    // Example: Get the current location and convert coordinates to a readable location
    loc.LocationData currentLocation = await location.getLocation();
    List<Placemark> placemarks = await placemarkFromCoordinates(
      currentLocation.latitude!,
      currentLocation.longitude!,
    );

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      setState(() {
        readableLocation =
            "${placemark.street}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}";
      });
    }
  }

  void getImage({required ImageSource source}) async {
    // Check and request camera permission if needed
    var cameraStatus = await Permission.camera.status;
    if (cameraStatus.isDenied) {
      await Permission.camera.request();
      cameraStatus = await Permission.camera.status;
      if (cameraStatus.isDenied) {
        // Handle the case where the user denies camera permission
        return;
      }
    }

    // Check and request location permission if needed
    var locationStatus = await Permission.location.status;
    if (locationStatus.isDenied) {
      await Permission.location.request();
      locationStatus = await Permission.location.status;
      if (locationStatus.isDenied) {
        // Handle the case where the user denies location permission
        return;
      }
    }

    await openGPS(); // Wait for location information

    // Now that both permissions are granted, proceed to capture image
    final file = await ImagePicker().pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (file?.path != null) {
      setState(() {
        imageFile = File(file!.path);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostScreen(
              imageFile: imageFile,
              readableLocation: readableLocation,
            ),
          ),
        );
      });
    }
  }
}
