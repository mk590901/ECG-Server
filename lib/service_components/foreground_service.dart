import 'dart:async';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'dart:math';

//import '../data_collection/data_holder.dart';
import '../data_collection/message_handler.dart';
import '../data_collection/pair_data_object.dart';
import '../ecg_simulator/ecg_simulator.dart';
import '../gui_adapter/simulator_wrapper.dart';

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
  SendPort? _sendPort;

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    print('Foreground service started');
    // Send initial data
    _sendPort?.send({
      'response': 'counter',
      'value': counter,
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    counter++;
    // Update notification
    await FlutterForegroundTask.updateService(
      foregroundTaskOptions: const ForegroundTaskOptions(interval: 1000,),
      notificationTitle: 'Foreground Service',
      notificationText: '${DateTime.now()}\ncounter: $counter',
    );

    // Send data to app
    sendPort?.send({
      'response': 'counter',
      'value': counter,
    });

    if (size() == 0) {
      print ('size = 0');
      return;
    }

    container.forEach((key, value) {
      print('loop ${value.id()} : ${value.presence()}');
      createSimulatorIfNeed(sendPort, key);
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
        Pair pair = add();
        String id = pair.uuid();
        int length = pair.counter();
        // Send data to app
        print ('Send data to app -> [created] [$id][$length]');

      }
      else
      if (command == 'delete_object') {
        String id = receivedData;
        print ('delete_object -> [$id]');
        remove(id);
      }
      else
      if (command == 'mark_object_unused') {
        String id = receivedData;
        print ('mark_object_unused -> [$id]');
        markUnused(id);
      }
      else
      if (command == 'mark_object_used') {
        String id = receivedData;
        print ('mark_object_used -> [$id]');
        markUsed(id);
      }
    } else {
      print('Invalid data format: $data');
    }
  }
////////////////////////////////////////////////////////////////////////////////
  int size() {
    return container.length;
  }

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

  void createSimulatorIfNeed(SendPort? sendPort, String key) {
    SimulatorWrapper? wrapper = get(key);
    if (wrapper == null) {
      return;
    }

    if (wrapper.presence()) {
      wrapper.setItemPresence(true);
    }

    List<double> rawData = wrapper.generateRawData(); //  Generate ECG signel

    sendPort?.send({
      'response': 'sync',  //  <- restored
      'value': {'id': wrapper.id(), 'length': wrapper.length(), 'raw_data': rawData, }, //wrapper.id(),
    });

  }

  SimulatorWrapper? get(String? id) {
    SimulatorWrapper? result;
    if (container.containsKey(id)) {
      result = container[id];
    }
    return result;
  }
}

// Entry point for the foreground task
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ServiceTaskHandler());
}
