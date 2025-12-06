import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapModel {
  double pinOffset = 0;
  bool drawRoute = false;
  List<MapObject> mapObjects = [];
  List<SearchItem> searchResult = [];

  void addMapObjects(MapObject mapObject) {
    mapObjects.add(mapObject);
  }

  void removeMapObjectsById(String id) {
    mapObjects.removeWhere((e) => e.mapId.value == id);
  }
}
