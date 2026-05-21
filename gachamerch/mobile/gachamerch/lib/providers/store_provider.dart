import 'package:flutter/foundation.dart';
import '../config/stores.dart';

class StoreProvider extends ChangeNotifier {
  StoreMeta _current = kStores.first;

  StoreMeta get current => _current;

  void select(StoreMeta store) {
    _current = store;
    notifyListeners();
  }

  void selectById(String id) {
    _current = storeById(id);
    notifyListeners();
  }
}
