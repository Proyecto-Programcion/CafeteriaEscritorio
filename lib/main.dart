import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/admin_remote_db.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:cafe/inicio_de_sesion/screens/inicio_de_sesion.dart';
import 'package:cafe/Inicio_screen/vista_principal_screen.dart';
import 'package:cafe/productos_screen/productos_screen.dart';
import 'package:cafe/promociones/promocionesScreeen.dart';
import 'package:cafe/usuarios/clientesScreen.dart';
import 'package:cafe/venta_screen/venta_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:get/get.dart';

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
    await windowManager.focus();
  });

  try {
    await Database.connect();
    DatabaseRemote.connect();
  } catch (e) {
    print('Error al conectar a la base de datos: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cafe Paquito',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const InicioDeSesion01(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isMaximized = false;
  int index = 0;

  // Tu lista de pantallas/widgets
  final List<Widget> listaDeScreens = [
    const InicioScreen(),
    const ProductosScreen(),
    const VentaScreen(),
    const ClientesScreen(),
    const PromocionesPage(),
    Center(child: Text('Pantalla Trending')),
  ];

  void cambiarIndex(int nuevoIndex) {
    setState(() {
      index = nuevoIndex;
    });
  }

  void init() async {
    isMaximized = await windowManager.isMaximized();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CabezeraMain(isMaximized: isMaximized),
          Expanded(
            child: Row(
              children: [
                // Navbar vertical, pásale la función y el index actual si quieres resaltar el seleccionado
                NavbarNavegacion(
                  onTap: cambiarIndex,
                  selectedIndex: index,
                ),
                // Contenido principal
                Expanded(
                  child: Container(
                    color: const Color.fromARGB(255, 250, 240, 230),
                    child: listaDeScreens[
                        index], // Aquí se muestra la pantalla seleccionada
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Modifica tu NavbarNavegacion para aceptar onTap y selectedIndex:
class NavbarNavegacion extends StatelessWidget {
  final void Function(int)? onTap;
  final int? selectedIndex;

  const NavbarNavegacion({
    super.key,
    this.onTap,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home,
      Icons.notes,
      Icons.shopping_cart,
      Icons.person,
      Icons.discount,
      Icons.trending_up,
    ];

    return Container(
      width: 70,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ...List.generate(icons.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: InkWell(
                onTap: () => onTap?.call(i),
                child: Icon(
                  icons[i],
                  color: selectedIndex == i
                      ? const Color.fromARGB(255, 107, 199, 223)
                      : Colors.black,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class CabezeraMain extends StatelessWidget {
  const CabezeraMain({
    super.key,
    required this.isMaximized,
  });

  final bool isMaximized;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 90,
      color: const Color.fromARGB(255, 85, 107, 47),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              '${SesionActiva().nombreUsuario}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 90,
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    windowManager.minimize();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.minimize,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () async {
                    if (isMaximized) {
                      await windowManager.unmaximize();
                    } else {
                      await windowManager.maximize();
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isMaximized ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    windowManager.close();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
