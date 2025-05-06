import 'package:cafe/inicio_de_sesion/screens/inicio_de_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    center: true,
    title: "Cafe Paquito",
    backgroundColor: Color.fromRGBO(33, 33, 33, 0.392),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );


  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.maximize();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafe Paquito',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const InicioDeSesion01(),
      },
    );
  }
}
