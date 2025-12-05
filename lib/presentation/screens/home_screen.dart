import 'package:flutter/material.dart';
import 'package:udevs_test_project/presentation/widgets/center_animation.dart';
import 'package:udevs_test_project/controllers/map_controller.dart';
import 'package:udevs_test_project/models/map_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final model = MapModel();
  late MapController controller;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = MapController(model: model, setState: () => setState(() {}));
    controller.getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            mapObjects: model.mapObjects,
            nightModeEnabled: true,
            onCameraPositionChanged: controller.onCameraPositionChanged,
            onMapCreated: controller.onMapCreated,
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
          CenterAnimation(pinOffset: model.pinOffset),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: controller.moveToUserLocation,
            child: const Icon(Icons.my_location, color: Colors.black),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: controller.drawRoute,
            child: const Icon(Icons.route, color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
