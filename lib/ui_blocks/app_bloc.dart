// --- App BLoC (for Start/Stop и Mode1/Mode2) ---
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:gui_model/mock/service_mock.dart';

import '../service_components/foreground_service.dart';

class DataPacket {
  final String id;
  final List<double> rawData;
  DataPacket(this.id, this.rawData);
}

abstract class AppEvent {}

class ToggleRunningEvent extends AppEvent {}

class ToggleModeEvent extends AppEvent {}

class StartService extends AppEvent {}

class StopService extends AppEvent {}

class UpdateDataEvent extends AppEvent {
  final String id;
  final bool presence;
  final List<double> rawData;
  UpdateDataEvent(this.presence, this.id, this.rawData);
}

class UpdateData extends AppEvent {
  final int counter;
  UpdateData(this.counter);
}

class AppState {
  final bool isRunning;
  final bool isServer;
  final int counter;
  final DataPacket dataPacket;

  AppState( {
    required this.isRunning,
    this.counter = 0,
    required this.isServer,
    required this.dataPacket
  });

  AppState copyWith({
    bool? isRunning,
    bool? isServer,
    DataPacket? dataPacket,
  }) {
    return AppState(
      isRunning: isRunning ?? this.isRunning,
      isServer: isServer ?? this.isServer,
      dataPacket: dataPacket ?? this.dataPacket,
    );
  }
}

class AppBloc extends Bloc<AppEvent, AppState> {

  late StreamSubscription? _dataSubscription;

  AppBloc() : super(AppState(dataPacket: DataPacket('',[]), isRunning: false, isServer: true)) {

    ServiceMock.instance()?.setAppBloc(this);

    FlutterForegroundTask.isRunningService.then((isRunning) {
      emit(AppState(
        isRunning: isRunning,
        counter: state.counter,
        isServer: state.isServer,
        dataPacket: state.dataPacket,
        // inputData: state.inputData,
        // numbers: state.numbers,
      ));
    });

    _dataSubscription = FlutterForegroundTask.receivePort?.listen((data) {
      if (data is Map && data.containsKey('counter') && data.containsKey('numbers')) {
        int counter = data['counter'] as int;
        //List<double> rawData = List<double>.from(data['numbers'].map((e) => e as double));
        print('receivePort: $counter');
        //DataHolder.instance()?.putData(rawData);
        add(UpdateData(counter));
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
          dataPacket: state.dataPacket,
          // inputData: state.inputData,
          // numbers: state.numbers,
        ));
      }
    });

    on<StopService>((event, emit) async {
      await FlutterForegroundTask.stopService();
      emit(AppState(isRunning: false, counter: 0, isServer: state.isServer, dataPacket: state.dataPacket,));
    });

    on<ToggleRunningEvent>((event, emit) {
      if (state.isRunning) {
        ServiceMock.instance()?.stop();
      }
      else {
        ServiceMock.instance()?.start();
      }
      emit(state.copyWith(isRunning: !state.isRunning));
    });

    on<ToggleModeEvent>((event, emit) {
      emit(state.copyWith(isServer: !state.isServer));
    });

    on<UpdateDataEvent>((event, emit) {
      print ('UpdateDataEvent [${event.presence}] [${event.id}]');
      emit(state.copyWith(dataPacket: DataPacket(event.id,event.rawData)));
    });

    on<UpdateData>((event, emit) {
      emit(AppState(
        isRunning: state.isRunning,
        counter: event.counter,
        isServer: state.isServer,
        dataPacket: state.dataPacket,
      ));
    });
  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }

}
