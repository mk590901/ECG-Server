// --- App BLoC (for Start/Stop и Mode1/Mode2) ---
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gui_model/mock/service_mock.dart';

class DataPacket {
  final String id;
  final List<double> rawData;
  DataPacket(this.id, this.rawData);
}

abstract class AppEvent {}

class ToggleRunningEvent extends AppEvent {}

class ToggleModeEvent extends AppEvent {}

class UpdateDataEvent extends AppEvent {
  final String id;
  final bool presence;
  final List<double> rawData;
  UpdateDataEvent(this.presence, this.id, this.rawData);
}

class AppState {
  final bool isRunning;
  final bool isServer;
  final DataPacket dataPacket;

  AppState( {
    required this.isRunning,
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
  AppBloc() : super(AppState(dataPacket: DataPacket('',[]), isRunning: false, isServer: true)) {

    ServiceMock.instance()?.setAppBloc(this);

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

  }
}
