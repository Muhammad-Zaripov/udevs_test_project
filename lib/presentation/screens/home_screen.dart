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
  final MapModel mapModel = MapModel();
  late MapController mapController;
  final searchController = TextEditingController();

  @override
  void initState() {
    mapController = MapController(
      setState: () => setState(() {}),
      mapModel: mapModel,
    );
    super.initState();
    mapController.getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            mapObjects: mapModel.mapObjects,
            onMapCreated: mapController.onMapCreated,
            onCameraPositionChanged: mapController.onCameraPositionChanged,
          ),
          CenterAnimation(pinOffset: mapModel.pinOffset),
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    mapController.searchLocation(value);
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
                              mapModel.searchResult = [];
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

                if (mapModel.searchResult.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    constraints: BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: mapModel.searchResult.length,
                      itemBuilder: (context, index) {
                        final item = mapModel.searchResult[index];
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
                            mapController.onLocationTapped(index);
                            mapController.drawToSelected();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              searchController.clear();
              mapController.moveToUserLocation();
            },
            child: Icon(Icons.add, color: Colors.black),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              searchController.clear();
              mapController.drawRouteToCameraPosition();
            },
            child: Icon(Icons.route, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
