import 'dart:async';
import 'package:synchronized/synchronized.dart';

import '../ui_blocks/app_bloc.dart';
import '../ui_blocks/item_model.dart';
import '../ui_blocks/items_bloc.dart';
import 'simulator_wrapper.dart';

class ServiceMock {
  static ServiceMock? _instance;

  final Map<String,SimulatorWrapper> container = {};
  final Lock _lock = Lock();

  late AppBloc? _appBloc;
  late ItemsBloc? _itemsBloc;

  static int PERIOD = 1000;
  final Duration _period = Duration(milliseconds: PERIOD);
  late Timer? _timer;

  static void initInstance() {
    _instance ??= ServiceMock();
    print ('ServiceMock.initInstance -- Ok');
  }

  static ServiceMock? instance() {
    if (_instance == null) {
      throw Exception("--- ServiceMock was not initialized ---");
    }
    return _instance;
  }

  String? add() {

      SimulatorWrapper wrapper = SimulatorWrapper();
      _lock.synchronized(() {
        container[wrapper.id()] = wrapper;
      });

      if (size() == 1) {
        start();
      }

      return wrapper.id();

    // SimulatorWrapper wrapper = SimulatorWrapper();
    // container[wrapper.id()] = wrapper;
    // return wrapper.id();
  }

  void remove(String? id) {

    _lock.synchronized(() {
      if (container.containsKey(id)) {
        container.remove(id);
      }
    });

    if (size() == 0) {
      stop();
    }

  }

  void markPresence(String? id, bool presence) {
    _lock.synchronized(() {
      if (container.containsKey(id)) {
        container[id]?.setItemPresence(false);
      }
    });

  }

  SimulatorWrapper? get(String? id) {
    SimulatorWrapper? result;
    _lock.synchronized(() {
      if (container.containsKey(id)) {
        result = container[id];
      }
    });
    return result;
  }

  List<double> getData(String id) {
    List<double> result = [];
    SimulatorWrapper? wrapper = get(id);
    if (wrapper == null) {
      return result;
    }
    result = wrapper.getData();

    return result;
  }

  int size() {
    return container.length;
  }

  void setItemsBloc(ItemsBloc? itemsBloc) {
    _itemsBloc = itemsBloc;
  }

  void setAppBloc(AppBloc? appBloc) {
    _appBloc = appBloc;
  }

  void start() {

    if (container.isEmpty) {
      return;
    }
    print ('------- ServiceMock.start -------');
    _timer = Timer.periodic(_period, (Timer t) {
      callbackFunction();
    });
  }

  void callbackFunction() {
    print ('------- ServiceMock.callbackFunction -------');
    container.forEach((key, value) {
      createGuiItemIfNeed(key);
      List<double> rawData = value.generateRawData();
      value.putData(rawData);
      _appBloc?.add(UpdateDataEvent(value.presence(), key, []));
    });
  }

  void stop() {

    if (_timer != null && _timer!.isActive) {
      _timer?.cancel();
    }
    _timer = null;
    print ('------- callbackFunction.stop -------');

    // Maybe remove content of List<Item>
    _itemsBloc?.add(ClearItemsEvent());


  }

  void dispose(String key) {
    print ('- ServiceMock.dispose($key) -');
    Item? item = getItem(key);
    item?.graphWidget.stop();
    print ('+ ServiceMock.dispose($key) +');

  }

  void createGuiItemIfNeed(String key) {
    if (_itemsBloc == null) {
      return;
    }
    if (itemsListContains(key)) {
      return;
    }
    SimulatorWrapper? wrapper = get(key);
    if (wrapper == null) {
      return;
    }
    wrapper.setItemPresence(true);
    _itemsBloc?.add(AddItemEvent(key, wrapper.length()));
  }

  bool itemsListContains(String key) {
    bool result = false;

    if (_itemsBloc == null) {
      return result;
    }

    List<Item>? items = _itemsBloc?.state.items;
    if (items == null) {
      return result;
    }

    int size = items.length;
    if (size ==  0) {
      return result;
    }

    for (int i = 0; i < size; i++) {
      Item item = items[i];
      if (item.id == key) {
        result = true;
        break;
      }
    }
    return result;
  }

  Item? getItem(String key) {
    Item? result;

    if (_itemsBloc == null) {
      return result;
    }

    List<Item>? items = _itemsBloc?.state.items;
    if (items == null) {
      return result;
    }

    int size = items.length;
    if (size ==  0) {
      return result;
    }

    for (int i = 0; i < size; i++) {
      Item item = items[i];
      if (item.id == key) {
        result = item;
        break;
      }
    }
    return result;
  }

}
