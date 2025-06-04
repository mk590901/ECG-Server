// --- Items BLoC (control elements list) ---
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../mock/service_mock.dart';
import '../mock/simulator_wrapper.dart';
import '../widget/graph_mode.dart';
import '../widget/graph_widget.dart';
import 'item_model.dart';

abstract class ItemsEvent {}

class CreateItemEvent extends ItemsEvent {
  final Function(String, int?) onObjectCreated;

  CreateItemEvent(this.onObjectCreated);
}

class AddItemEvent extends ItemsEvent {
  final String id;
  final int? length;
  late GraphWidget graphWidget;

  AddItemEvent(this.id, this.length,) {
    graphWidget = GraphWidget(
        uuid: id,
        samplesNumber: length?? 128,
        width: 340,
        height: 100,
        mode: GraphMode.flowing,);

    // if (!graphWidget.isStarted()) {
    //   graphWidget.start();
    // }

  }
}

class RemoveItemEvent extends ItemsEvent {
  final String id;
  final DismissDirection direction;
  final GraphWidget graphWidget;

  RemoveItemEvent(this.id, this.graphWidget, this.direction);
}

class ClearItemsEvent extends ItemsEvent {}

class ItemsState {
  final List<Item> items;

  ItemsState({required this.items});

  ItemsState copyWith({List<Item>? items}) {
    return ItemsState(items: items ?? this.items);
  }
}

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  ItemsBloc() : super(ItemsState(items: [])) {

    ServiceMock.instance()?.setItemsBloc(this);

    on<AddItemEvent>((event, emit) {

      final newItem = Item(id: event.id,
        title: "ECG Diagram [${event.id.substring(0, 8)}]",
        subtitle: "Sample rate is ${event.length} points/s",
        graphWidget: event.graphWidget,
      );
      emit(state.copyWith(items: [...state.items, newItem]));
    });

    on<CreateItemEvent>((event, emit) async {
      String objectId = ServiceMock.instance()?.add()?? const Uuid().v4().toString();
      SimulatorWrapper? wrapper = ServiceMock.instance()?.get(objectId);
      event.onObjectCreated(objectId, wrapper?.length());
    });

    on<RemoveItemEvent>((event, emit) {

      //@event.graphWidget.stop();

      emit(state.copyWith(
        items: state.items.where((item) => item.id != event.id).toList(),
      ));

      if (event.direction == DismissDirection.endToStart) {
        ServiceMock.instance()?.remove(event.id);
        print('Remove [${event.id}] simulator -> # ${ServiceMock.instance()?.size()}');
      }
      else {
        ServiceMock.instance()?.markPresence(event.id, false);
      }

    });

    on<ClearItemsEvent>((event, emit) {
      emit(state.copyWith(items: []));
    });

  }
}
