import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:udevs_test_project/center_animation.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late YandexMapController mapController;

  List<MapObject> mapObjects = [];

  Point? userLocation;
  Point? cameraPosition;
  double pinOffset = 0;
  bool canDrawRoute = false;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;
    Position pos = await Geolocator.getCurrentPosition();
    userLocation = Point(latitude: pos.latitude, longitude: pos.longitude);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            mapObjects: mapObjects,
            nightModeEnabled: true,

            onCameraPositionChanged: (position, reason, finished) async {
              if (finished) {
                cameraPosition = position.target;
                pinOffset = 0;
              } else {
                pinOffset = -10;
              }
              setState(() {});
            },

            onMapCreated: (controller) async {
              mapController = controller;

              if (userLocation != null) {
                await mapController.moveCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: userLocation!, zoom: 15),
                  ),
                  animation: MapAnimation(
                    type: MapAnimationType.smooth,
                    duration: 1.0,
                  ),
                );

                await mapController.toggleUserLayer(
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
              controller: searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
                hintText: 'Manzilni kiriting',
                hintStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.search, color: Colors.black),
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: Colors.black),
            onPressed: () {
              if (userLocation != null) {
                mapController.moveCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: userLocation!, zoom: 15),
                  ),
                  animation: MapAnimation(
                    type: MapAnimationType.smooth,
                    duration: 1.0,
                  ),
                );
              }
              mapObjects.removeWhere((e) => e.mapId.value == "map_route");
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            backgroundColor: Colors.white,
            child: const Icon(Icons.route, color: Colors.black),
            onPressed: () async {
              canDrawRoute = true;
              await _polyline();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _polyline() async {
    if (!canDrawRoute) return;

    if (userLocation == null || cameraPosition == null) return;

    if (userLocation!.latitude == cameraPosition!.latitude &&
        userLocation!.longitude == cameraPosition!.longitude) {
      return;
    }

    var session = await YandexDriving.requestRoutes(
      points: [
        RequestPoint(
          point: userLocation!,
          requestPointType: RequestPointType.wayPoint,
        ),
        RequestPoint(
          point: cameraPosition!,
          requestPointType: RequestPointType.wayPoint,
        ),
      ],
      drivingOptions: DrivingOptions(routesCount: 1),
    );

    final result = await session.$2;

    if (result.routes == null || result.routes!.isEmpty) return;

    mapObjects.removeWhere((e) => e.mapId.value == "map_route");

    mapObjects.add(
      PolylineMapObject(
        mapId: const MapObjectId("map_route"),
        polyline: Polyline(points: result.routes!.first.geometry.points),
        strokeColor: Colors.blue,
        strokeWidth: 4,
      ),
    );

    setState(() {});
  }
}
