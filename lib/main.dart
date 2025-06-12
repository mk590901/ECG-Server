import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'mock/service_mock.dart';
import 'service_components/foreground_service.dart';
import 'ui_blocks/app_bloc.dart';
import 'ui_blocks/items_bloc.dart';
import 'ui_components/home_page.dart';

void main() async {
  ServiceAdapter.initInstance();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeForegroundService();
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
