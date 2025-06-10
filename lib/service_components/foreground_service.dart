import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'dart:math';

//import '../data_collection/data_holder.dart';
import '../data_collection/pair_data_object.dart';
import '../ecg_simulator/ecg_simulator.dart';
import '../mock/simulator_wrapper.dart';

// Initialize the foreground service
Future<void> initializeForegroundService() async {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'foreground_service',
      channelName: 'Foreground Service Notification',
      channelDescription: 'This notification appears when the foreground service is running.',
      channelImportance: NotificationChannelImportance.DEFAULT,
      priority: NotificationPriority.DEFAULT,
      enableVibration: false,
      playSound: false,
      showWhen: false,
      visibility: NotificationVisibility.VISIBILITY_PUBLIC,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 1000, // Run every 5 seconds
      autoRunOnBoot: false,
      allowWifiLock: true,
    ),
  );
}

// Task handler for the foreground service
class ServiceTaskHandler extends TaskHandler {

  final Map<String,SimulatorWrapper> container = {};

  int counter = 0;
  final Random random = Random();
  //final EcgSimulator ecgSimulator = EcgSimulator(128);
  SendPort? _sendPort;

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    print('Foreground service started');
    // Send initial data
    _sendPort?.send({
      // 'counter': counter,
      // 'numbers': [],
      'response': 'counter',
      'value': counter,

    });
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    counter++;
    List<double> numbers = []; //ecgSimulator.generateECGData();
    //@print('Foreground service running: $counter, numbers: ${numbers.length}');
    // Update notification
    await FlutterForegroundTask.updateService(
      foregroundTaskOptions: const ForegroundTaskOptions(interval: 1000,),
      notificationTitle: 'Foreground Service',
      notificationText: '${DateTime.now()}\ncounter: $counter',
      //notificationText: 'Counter: $counter, Numbers: ${numbers.map((n) => n.toStringAsFixed(2)).join(', ')}',
      // notificationIcon: NotificationIconData(
      //   resType: ResourceType.mipmap,
      //   resPrefix: ResourcePrefix.ic,
      //   name: 'com.example.flutter_fb_task.HEART_ICON',
      //   backgroundColor: Color(0xFF202020),
      // ),
    );

    // Send data to app
    sendPort?.send({
      // 'counter': counter,
      // 'numbers': numbers,
      'response': 'counter',
      'value': counter,
    });

    if (size() == 0) {
      return;
    }

    container.forEach((key, value) {
      print('loop ${value.id()} : ${value.presence()}');
      createGuiItemIfNeed(key);
      // List<double> rawData = value.generateRawData();
      // value.putData(rawData);
      // _appBloc?.add(UpdateDataEvent(value.presence(), key, []));
    });

  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('Foreground service stopped');
  }

  @override
  void onNotificationButtonPressed(String id) {
    print('Notification button pressed: $id');
  }

  @override
  void onNotificationPressed() {
    print('Notification pressed');
  }

  // Handle data sent from the app
  @override
  void onReceiveData (dynamic data) {
    print('onDataReceived called with data: $data');
    if (data is Map && data.containsKey('command') &&  data.containsKey('data')) {
      final String command = data['command'] as String;
      final String receivedData = data['data'] as String;
      print('Service received: $command:($receivedData)');
      if (command == 'create_object') {
        //String? id = add()?? '';
        //print ('add create_object -> [$id]');
        Pair pair = add();
        String id = pair.uuid();
        int length = pair.counter();
        // Send data to app
        _sendPort?.send({
          'response': 'created',
          'value': {'id': id, 'length': length, },
        });
      }
      else
      if (command == 'delete_object') {
        String id = receivedData;
        print ('delete_object -> [$id]');
        remove(id);
        // Send data to app
        // _sendPort?.send({
        //   'response': 'created',
        //   'value': id,
        // });
      }
      else
      if (command == 'mark_object_unused') {
        String id = receivedData;
        print ('mark_object_unused -> [$id]');
        markUnused(id);
        // Send data to app
        // _sendPort?.send({
        //   'response': 'created',
        //   'value': id,
        // });
      }
      else
      if (command == 'mark_object_used') {
        String id = receivedData;
        print ('mark_object_used -> [$id]');
        markUsed(id);
        // Send data to app
        // _sendPort?.send({
        //   'response': 'created',
        //   'value': id,
        // });
      }


      // FlutterForegroundTask.updateService(
      //   foregroundTaskOptions: const ForegroundTaskOptions(interval: 1000,),
      //   notificationTitle: 'Foreground Service',
      //   notificationText: 'Received: $receivedData',
      // );
    } else {
      print('Invalid data format: $data');
    }
  }
////////////////////////////////////////////////////////////////////////////////
  int size() {
    return container.length;
  }

  // String? add() {
  //   SimulatorWrapper wrapper = SimulatorWrapper();
  //   container[wrapper.id()] = wrapper;
  //   return wrapper.id();
  // }
  Pair add() {
    SimulatorWrapper wrapper = SimulatorWrapper();
    container[wrapper.id()] = wrapper;
    return Pair(wrapper.id(),wrapper.length());
  }

  void remove(String? id) {
    if (container.containsKey(id)) {
      container.remove(id);
    }

    print ('remove, size->[${size()}]');

    // if (size() == 0) {
    //   stop();
    // }

  }

  void markUnused(String? id,) {
    if (container.containsKey(id)) {
      container[id]?.setItemPresence(false);
    }
    print ('markUnused, size->[${size()}]');
  }

  void markUsed(String? id,) {
    if (container.containsKey(id)) {
      container[id]?.setItemPresence(true);
    }
    print ('markUsed, size->[${size()}]');
  }

  void createGuiItemIfNeed(String key) {
    SimulatorWrapper? wrapper = get(key);
    if (wrapper == null) {
      return;
    }

    if (wrapper.presence()) {
      print ('createGuiItemIfNeed [$key] - leave');
      return;
    }

    print ('createGuiItemIfNeed [$key] - recreate');

    wrapper.setItemPresence(true);

    _sendPort?.send({
      'response': 'created',  //  <- restored
      'value': {'id': wrapper.id(), 'length': wrapper.length(), }, //wrapper.id(),
    });


  }

  SimulatorWrapper? get(String? id) {
    SimulatorWrapper? result;
    if (container.containsKey(id)) {
      result = container[id];
    }
    return result;
  }

//////////////////////////////////////////////////////////////////////////////////////////
}

// Entry point for the foreground task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ServiceTaskHandler());
}
