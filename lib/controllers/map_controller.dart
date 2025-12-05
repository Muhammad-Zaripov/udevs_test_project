import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:udevs_test_project/models/map_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapController {
  final MapModel model;
  final Function() setState;
  YandexMapController? mapController;

  MapController({required this.model, required this.setState});

  // User locationni olish
  Future<void> getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition();
    model.setUserLocation(
      Point(latitude: pos.latitude, longitude: pos.longitude),
    );

    setState();
  }

  // Camera pozitsiyasini yangilash
  void onCameraPositionChanged(position, reason, finished) {
    if (finished) {
      model.setCameraPosition(position.target);
      model.setPinOffset(0);
    } else {
      model.setPinOffset(-10);
    }
    setState();
  }

  // Xarita yaratilganda
  Future<void> onMapCreated(YandexMapController controller) async {
    mapController = controller;

    if (model.userLocation != null) {
      await mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: model.userLocation!, zoom: 15),
        ),
        animation: MapAnimation(type: MapAnimationType.smooth, duration: 1.0),
      );

      await mapController!.toggleUserLayer(
        visible: true,
        autoZoomEnabled: true,
      );
    }
  }

  // User locationga qaytish
  void moveToUserLocation() {
    if (model.userLocation != null && mapController != null) {
      mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: model.userLocation!, zoom: 15),
        ),
        animation: MapAnimation(type: MapAnimationType.smooth, duration: 1.0),
      );
    }
    model.removeMapObjectById("map_route");
    setState();
  }

  // Route chizish
  Future<void> drawRoute() async {
    model.setDrawRoute(true);

    if (model.userLocation == null || model.cameraPosition == null) return;

    if (model.userLocation == model.cameraPosition) {
      return;
    }

    var session = await YandexDriving.requestRoutes(
      points: [
        RequestPoint(
          point: model.userLocation!,
          requestPointType: RequestPointType.wayPoint,
        ),
        RequestPoint(
          point: model.cameraPosition!,
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
