import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turimap/core/di/injection_container.dart' as di;
import 'package:turimap/core/utils/constants.dart';
import 'package:turimap/features/route/presentation/bloc/route_bloc.dart';
import 'package:turimap/features/route/presentation/pages/map_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
  runApp(const TuriMapApp());
}

class TuriMapApp extends StatelessWidget {
  const TuriMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006B75),
        ),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => di.sl<RouteBloc>(),
        child: const MapPage(),
      ),
    );
  }
}