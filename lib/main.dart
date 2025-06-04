import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//import 'data_collection/data_holder.dart';
import 'mock/service_mock.dart';
import 'ui_blocks/app_bloc.dart';
import 'ui_blocks/items_bloc.dart';
import 'ui_components/home_page.dart';

void main() {
  //DataHolder.initInstance();
  ServiceMock.initInstance();
  runApp(const FrontendApp());
}

// App class
class FrontendApp extends StatelessWidget {
  const FrontendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppBloc()),
        BlocProvider(create: (context) => ItemsBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
