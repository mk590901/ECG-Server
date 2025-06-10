//import 'dart:math';
import 'package:uuid/uuid.dart';

import '../ecg_simulator/ecg_simulator.dart';
import '../utils.dart';

class SimulatorWrapper {
  late String _id; // = const Uuid().v4().toString();
  //final Random random = Random();
  late int _seriesLength;// = getSeriesLength();

  late List<double> rawData = [];

  //late final EcgSimulator _ecgSimulator = EcgSimulator(_seriesLength);
  late EcgSimulator _ecgSimulator; // = EcgSimulator(_seriesLength);
  late bool _itemPresence = true;

  SimulatorWrapper() {  //  For service
    _id = const Uuid().v4().toString();
    _seriesLength = getSeriesLength();
    _ecgSimulator = EcgSimulator(_seriesLength);
  }

  SimulatorWrapper.part(this._id, this._seriesLength);  //  For app

  String id() {
    return _id;
  }

  bool presence() {
    return _itemPresence;
  }

  int length() {
    return _seriesLength;
  }

  List<double> generateRawData() {
    return _ecgSimulator.generateECGData();
  }

  void setItemPresence(bool presence) {
    _itemPresence = presence;
  }

  List<double> getData() {
    return rawData;
  }

  void putData(List<double> data) {
    rawData = data;
  }


}
