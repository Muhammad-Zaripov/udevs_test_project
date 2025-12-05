import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapModel {
  Point? userLocation;
  Point? cameraPosition;
  List<MapObject> mapObjects = [];
  double pinOffset = 0;
  bool drawRoute = false;

  void setUserLocation(Point location) {
    userLocation = location;
  }

  void setCameraPosition(Point position) {
    cameraPosition = position;
  }

  void setPinOffset(double offset) {
    pinOffset = offset;
  }

  void setDrawRoute(bool value) {
    drawRoute = value;
  }

  void addMapObject(MapObject object) {
    mapObjects.add(object);
  }

  void removeMapObjectById(String id) {
    mapObjects.removeWhere((e) => e.mapId.value == id);
  }
}
