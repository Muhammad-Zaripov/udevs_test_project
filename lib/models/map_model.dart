import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapModel {
  List<MapObject> mapObjects = [];
  List<SearchItem> searchResults = [];
  double pinOffset = 0;
  bool drawRoute = false;

  void addMapObject(MapObject object) {
    mapObjects.add(object);
  }

  void removeMapObjectById(String id) {
    mapObjects.removeWhere((e) => e.mapId.value == id);
  }
}
