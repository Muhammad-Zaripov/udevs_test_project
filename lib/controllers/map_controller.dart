import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:udevs_test_project/models/map_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapController {
  final MapModel mapModel;
  Point? userLocation;
  Point? cameraPosition;
  Point? selectedLocation;
  final VoidCallback setState;
  YandexMapController? mapController;
  MapController({
    this.mapController,
    required this.setState,
    required this.mapModel,
  });

  void getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
    }
    Position position = await Geolocator.getCurrentPosition();
    userLocation = Point(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    setState();
  }

  Future<void> onMapCreated(controller) async {
    mapController = controller;
    if (userLocation != null) {
      mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLocation!, zoom: 15.0),
        ),
        animation: MapAnimation(type: MapAnimationType.smooth, duration: 1.0),
      );
    }
    await mapController!.toggleUserLayer(visible: true);
    setState();
  }

  void onCameraPositionChanged(position, reason, finished) {
    if (finished) {
      cameraPosition = position.target;
      mapModel.pinOffset = 0;
      print("Camera position: $cameraPosition");
    } else {
      mapModel.pinOffset = -10;
    }

    setState();
  }

  void moveToUserLocation() {
    if (userLocation != null) {
      mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLocation!, zoom: 15.0),
        ),
        animation: MapAnimation(type: MapAnimationType.smooth, duration: 1.0),
      );
    }
    mapModel.removeMapObjectsById("select_in_map");
    mapModel.removeMapObjectsById("search");
    print("User location: $userLocation");
    setState();
  }

  Future<void> drawRouteToCameraPosition() async {
    mapModel.drawRoute = true;

    if (userLocation == cameraPosition) {
      return;
    }

    var route = await YandexDriving.requestRoutes(
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

    final result = await route.$2;

    if (result.routes == null || result.routes!.isEmpty) return;

    mapModel.removeMapObjectsById("select_in_map");
    mapModel.removeMapObjectsById("search");

    mapModel.addMapObjects(
      PolylineMapObject(
        mapId: const MapObjectId("select_in_map"),
        polyline: Polyline(points: result.routes!.first.geometry.points),
        strokeColor: Colors.blue,
        strokeWidth: 4,
      ),
    );
    print(result.routes!.first.geometry.points);

    setState();
  }

  Future<void> searchLocation(String location) async {
    if (location.isEmpty) {
      mapModel.searchResult = [];
      setState();
      return;
    }

    var (session, resultFuture) = await YandexSearch.searchByText(
      searchText: location,
      geometry: Geometry.fromPoint(userLocation!),
      searchOptions: SearchOptions(
        searchType: SearchType.geo,
        resultPageSize: 20,
      ),
    );

    final result = await resultFuture;
    mapModel.searchResult = result.items ?? [];
    setState();
  }

  void onLocationTapped(int index) {
    final item = mapModel.searchResult[index];
    selectedLocation = item.geometry.first.point;
    print("Tanlangan joy: $selectedLocation");

    mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: selectedLocation!, zoom: 16),
      ),
      animation: MapAnimation(type: MapAnimationType.smooth, duration: 1.0),
    );

    mapModel.searchResult = [];
    setState();
  }

  Future<void> drawToSelected() async {
    if (selectedLocation == null) {
      return;
    }

    if (userLocation == null) {
      return;
    }
    if (userLocation == selectedLocation) {
      return;
    }
    var route = await YandexDriving.requestRoutes(
      points: [
        RequestPoint(
          point: userLocation!,
          requestPointType: RequestPointType.wayPoint,
        ),
        RequestPoint(
          point: selectedLocation!,
          requestPointType: RequestPointType.wayPoint,
        ),
      ],
      drivingOptions: DrivingOptions(routesCount: 1),
    );
    final result = await route.$2;
    if (result.routes == null || result.routes!.isEmpty) return;
    mapModel.removeMapObjectsById("select_in_map");
    mapModel.removeMapObjectsById("search");
    mapModel.addMapObjects(
      PolylineMapObject(
        mapId: const MapObjectId("search"),
        polyline: Polyline(points: result.routes!.first.geometry.points),
        strokeColor: Colors.blue,
        strokeWidth: 4,
      ),
    );
    setState();
  }
}
