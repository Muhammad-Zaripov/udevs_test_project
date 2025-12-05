import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:udevs_test_project/models/map_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapController {
  Point? userLocation;
  Point? cameraPosition;
  final MapModel model;
  final Function() setState;
  YandexMapController? mapController;
  Point? selectedLocation;
  MapController({required this.model, required this.setState});

  // User locationni olish
  Future<void> getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
    }

    Position pos = await Geolocator.getCurrentPosition();
    userLocation = Point(latitude: pos.latitude, longitude: pos.longitude);

    setState();
  }

  // Camera pozitsiyasini yangilash
  void onCameraPositionChanged(position, reason, finished) {
    if (finished) {
      cameraPosition = position.target;
      model.pinOffset = 0;
    } else {
      model.pinOffset = -10;
    }
    setState();
  }

  // Xarita yaratilganda
  Future<void> onMapCreated(controller) async {
    mapController = controller;

    if (userLocation != null) {
      await mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLocation!, zoom: 18),
        ),
        animation: MapAnimation(type: MapAnimationType.smooth, duration: 1.0),
      );

      await mapController!.toggleUserLayer(
        visible: true,
        autoZoomEnabled: false,
      );
    }
  }

  // User locationga qaytish
  void moveToUserLocation() {
    if (userLocation != null && mapController != null) {
      mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLocation!, zoom: 18),
        ),
        animation: MapAnimation(type: MapAnimationType.smooth, duration: 1.0),
      );
    }
    model.removeMapObjectById("map_route");
    model.removeMapObjectById("selected_marker");
    model.searchResults = [];
    setState();
  }

  // Camera positionga route chizish
  Future<void> drawRoute() async {
    model.drawRoute = true;

    if (userLocation == cameraPosition) {
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

    model.removeMapObjectById("map_route");

    model.addMapObject(
      PolylineMapObject(
        mapId: const MapObjectId("map_route"),
        polyline: Polyline(points: result.routes!.first.geometry.points),
        strokeColor: Colors.blue,
        strokeWidth: 4,
      ),
    );

    setState();
  }

  // Manzil qidirish
  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      model.searchResults = [];
      setState();
      return;
    }

    // User location yoki default Toshkent koordinatalari
    final centerLat = userLocation!.latitude;
    final centerLon = userLocation!.longitude;

    // Yandex Search API dan manzil qidirish
    final sessionResult = await YandexSearch.searchByText(
      searchText: query,
      geometry: Geometry.fromBoundingBox(
        BoundingBox(
          northEast: Point(
            latitude: centerLat + 1, // 1 daraja shimolga
            longitude: centerLon + 1, // 1 daraja sharqqa
          ),
          southWest: Point(
            latitude: centerLat - 1, // 1 daraja janubga
            longitude: centerLon - 1, // 1 daraja g'arbga
          ),
        ),
      ),
      searchOptions: SearchOptions(
        searchType: SearchType.geo,
        resultPageSize: 10,
      ),
    );

    // Session va result ni olish
    final searchResultFuture = sessionResult.$2;
    final searchResult = await searchResultFuture;
    if (searchResult.items != null) {
      model.searchResults = searchResult.items!;
      setState();
    }
  }

  // Tanlangan joyga o'tish va route chizish
  Future<void> selectLocation(SearchItem item) async {
    model.searchResults = [];

    // SearchItem dan Point olish
    final geometry = item.geometry.firstOrNull;
    if (geometry != null && geometry.point != null) {
      final selectedPoint = geometry.point!;
      selectedLocation = selectedPoint;

      // Marker qo'yish
      model.removeMapObjectById('selected_marker');
      model.addMapObject(
        PlacemarkMapObject(
          mapId: MapObjectId('selected_marker'),
          point: selectedPoint,
          opacity: 1.0,
        ),
      );

      // Kamerani shu joyga olib borish
      await mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: selectedPoint, zoom: 18),
        ),
        animation: MapAnimation(type: MapAnimationType.smooth, duration: 1.0),
      );

      // Route chizish
      await drawRouteToSelected();
    }

    setState();
  }

  // Tanlangan joyga route chizish
  Future<void> drawRouteToSelected() async {
    if (userLocation == null || selectedLocation == null) return;

    if (userLocation!.latitude == selectedLocation!.latitude &&
        userLocation!.longitude == selectedLocation!.longitude) {
      return;
    }

    var session = await YandexDriving.requestRoutes(
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

    final result = await session.$2;

    if (result.routes == null || result.routes!.isEmpty) return;

    model.removeMapObjectById("map_route");

    model.addMapObject(
      PolylineMapObject(
        mapId: const MapObjectId("map_route"),
        polyline: Polyline(points: result.routes!.first.geometry.points),
        strokeColor: Colors.blue,
        strokeWidth: 4,
      ),
    );

    setState();
  }
}
