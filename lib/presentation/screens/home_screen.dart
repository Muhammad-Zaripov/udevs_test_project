import 'package:flutter/material.dart';
import 'package:udevs_test_project/controllers/map_controller.dart';
import 'package:udevs_test_project/models/map_model.dart';
import 'package:udevs_test_project/presentation/widgets/center_animation.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapModel model = MapModel();
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

          // Search TextField va natijalar
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    controller.searchLocation(value);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Manzilni kiriting',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.black),
                            onPressed: () {
                              searchController.clear();
                              model.searchResults = [];
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                // Qidiruv natijalari ro'yxati
                if (model.searchResults.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: model.searchResults.length,
                      itemBuilder: (context, index) {
                        final item = model.searchResults[index];
                        return ListTile(
                          title: Text(
                            item.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle:
                              item.toponymMetadata?.address.formattedAddress !=
                                  null
                              ? Text(
                                  item
                                      .toponymMetadata!
                                      .address
                                      .formattedAddress,
                                  style: TextStyle(fontSize: 12),
                                )
                              : null,
                          onTap: () {
                            searchController.text = item.name;
                            controller.selectLocation(item);
                          },
                        );
                      },
                    ),
                  ),
              ],
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
            onPressed: () {
              controller.moveToUserLocation();
              searchController.clear();
            },
            child: const Icon(Icons.my_location, color: Colors.black),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              controller.drawRoute();
              searchController.clear();
            },
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
