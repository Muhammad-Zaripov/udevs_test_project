import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:udevs_test_project/center_animation.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late YandexMapController controller;
  List<MapObject> mapObjects = [];
  Point? userLocation;
  Point? cameraPosition;
  double pinOffset = 0;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    // Permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // User locationni olish
    Position pos = await Geolocator.getCurrentPosition();
    final point = Point(latitude: pos.latitude, longitude: pos.longitude);
    setState(() {
      userLocation = point;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            mapObjects: mapObjects,

            onCameraPositionChanged: (cameraPosition, reason, finished) async {
              if (finished) {
                this.cameraPosition = cameraPosition.target;
                setState(() {
                  pinOffset = 0;
                });
                print("Camera position: $cameraPosition");
              } else {
                setState(() {
                  pinOffset = -10;
                });
              }
            },
            nightModeEnabled: true,
            onMapCreated: (YandexMapController yandexMapController) async {
              controller = yandexMapController;

              // Agar user location mavjud bo'lsa, camerani u yerga olib borish
              if (userLocation != null) {
                await controller.moveCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: userLocation!, zoom: 15),
                  ),
                );

                // User layer ko'rsatish
                await controller.toggleUserLayer(
                  visible: true,
                  autoZoomEnabled: false,
                );
              }
            },
          ),
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
                hintText: 'Manzilni kiriting',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          CenterAnimation(pinOffset: pinOffset),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white.withOpacity(0.5),
        onPressed: () async {
          // Agar user location mavjud bo'lsa, camerani u yerga olib borish
          if (userLocation != null) {
            await controller.moveCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: userLocation!, zoom: 20),
              ),
            );

            // User layer ko'rsatish
            await controller.toggleUserLayer(
              visible: true,
              autoZoomEnabled: false,
            );
          }
        },
        child: Icon(Icons.my_location),
      ),
    );
  }
}
