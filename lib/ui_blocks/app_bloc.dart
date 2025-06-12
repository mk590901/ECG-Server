// --- App BLoC (for Start/Stop и Mode1/Mode2) ---
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../gui_adapter/service_adapter.dart';
import '../service_components/foreground_service.dart';

abstract class AppEvent {}

class ToggleRunningEvent extends AppEvent {}

class ToggleModeEvent extends AppEvent {}

class StartService extends AppEvent {}

class StopService extends AppEvent {}

class UpdateData extends AppEvent {
  final int counter;
  UpdateData(this.counter);
}

class SendData extends AppEvent {
  final String command;
  final String data;
  SendData(this.command, this.data);
}

class AppState {
  final bool isRunning;
  final bool isServer;
  final int counter;
  final String sentData;

  AppState( {
    required this.isRunning,
    this.counter = 0,
    this.sentData = '',
    required this.isServer,
  });

  AppState copyWith({
    bool? isRunning,
    bool? isServer,
  }) {
    return AppState(
      isRunning: isRunning ?? this.isRunning,
      isServer: isServer ?? this.isServer,
    );
  }
}

class AppBloc extends Bloc<AppEvent, AppState> {

  late StreamSubscription? _dataSubscription;

  AppBloc() : super(AppState(/*dataPacket: DataPacket('',[]),*/ isRunning: false, isServer: true)) {

    ServiceAdapter.instance()?.setAppBloc(this);

    FlutterForegroundTask.isRunningService.then((isRunning) {
      emit(AppState(
        isRunning: isRunning,
        counter: state.counter,
        isServer: state.isServer,
       ));
    });

    _dataSubscription = FlutterForegroundTask.receivePort?.listen((data) {

      if (data is Map && data.containsKey('response') && data.containsKey('value')) {
        String command = data['response'] as String;
        print('listener.command->[$command]');
        if (command == 'counter') {
          int counter = data['value'] as int;
          add(UpdateData(counter));
        }

        if (command == 'sync') {
          Map map = data['value'] as Map;
          String id = map['id'];
          int length = map['length'];
          List<double> rawData = map['raw_data'];
          print ('listener.command->sync [$id]:[$length]->(${rawData.length})');
          ServiceAdapter.instance()?.createGuiItem(id, length);
          ServiceAdapter.instance()?.updateRawData(id,rawData);
        }
      }
    });

    on<StartService>((event, emit) async {
      bool isRunning = await FlutterForegroundTask.isRunningService;
      if (!isRunning) {
        await FlutterForegroundTask.startService(
          notificationTitle: 'Foreground Service',
          notificationText: 'Starting...',
          callback: startCallback,
        );
        emit(AppState(
          isRunning: true,
          counter: state.counter,
          isServer: state.isServer,
        ));
      }
      else {
        print('------- Service already running -------');
      }
    });

    on<StopService>((event, emit) async {
      await FlutterForegroundTask.stopService();
      emit(AppState(isRunning: false, counter: 0, isServer: state.isServer, ));
    });

    on<ToggleRunningEvent>((event, emit) {
      if (state.isRunning) {
        ServiceAdapter.instance()?.stop();
      }
      else {
        ServiceAdapter.instance()?.start();
      }
      emit(state.copyWith(isRunning: !state.isRunning));
    });

    on<ToggleModeEvent>((event, emit) {
      emit(state.copyWith(isServer: !state.isServer));
    });

    on<UpdateData>((event, emit) {
      emit(AppState(
        isRunning: state.isRunning,
        counter: event.counter,
        isServer: state.isServer,
      ));
    });

    on<SendData>((event, emit) async {
      print('Sending data to service: ${event.command}:${event.data}');
      FlutterForegroundTask.sendData({'command': event.command, 'data': event.data});

      emit(AppState(
        isRunning: state.isRunning,
        counter: state.counter,
        sentData: event.data, //  command?
        isServer: state.isServer,
      ));
    });

  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }

}
