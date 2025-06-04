// Home page
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../mock/service_mock.dart';
import '../ui_blocks/app_bloc.dart';
import '../ui_blocks/items_bloc.dart';
import '../utils.dart';
import 'card_view.dart';
import 'control_panel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Frontend App'),
      ),
      body: Column(
        children: [
          const ControlPanel(),
          Expanded(
            child: BlocConsumer<ItemsBloc, ItemsState>(
              listener: (context, state) {
                if (state.items.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
                }
              },
              builder: (context, state) {
                return ListView.builder(
                  controller: scrollController,
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        ServiceMock.instance()?.dispose(item.id);
                        context.read<ItemsBloc>().add(RemoveItemEvent(item.id, item.graphWidget, direction));
                      },
                      //  Swipe left->right
                      background: Container(
                        color: Colors.blueGrey.shade200,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      //  Swipe right->left
                      secondaryBackground: Container(
                        color: Colors.deepPurple.shade200,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 16),
                        child: const Icon(Icons.delete_forever, color: Colors.white),
                      ),
                      child: CardView(item: item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.read<AppBloc>().state.isRunning) {
            context.read<ItemsBloc>().add(
              CreateItemEvent((objectId,series) {
                context.read<ItemsBloc>().add(AddItemEvent(objectId, series));
              }),
            );
          }
          else {
            showToast(context, "Service isn't run");
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
