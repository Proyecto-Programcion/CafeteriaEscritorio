import 'package:cafe/administradores/administradores_screen.dart';
import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/admin_remote_db.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:cafe/configuraciones/configuraciones_Screen.dart';
import 'package:cafe/configuraciones/widgets/modal_cerar_caja.dart';
import 'package:cafe/controlVenta/controlGastos.dart';
import 'package:cafe/control_Stock/control_stock_screen.dart';
import 'package:cafe/inicio_de_sesion/controllers/evaluar_si_hay_caja_abierta.dart';
import 'package:cafe/inicio_de_sesion/screens/inicio_de_sesion.dart';
import 'package:cafe/Inicio_screen/vista_principal_screen.dart';
import 'package:cafe/productos_screen/productos_screen.dart';
import 'package:cafe/promociones/promocionesScreeen.dart';
import 'package:cafe/turnoCaja/detalles_turno_caja_screen.dart';
import 'package:cafe/turnoCaja/turno_caja_screen.dart';
import 'package:cafe/usuarios/clientesScreen.dart';
import 'package:cafe/venta_screen/metodos_impresora.dart';
import 'package:cafe/venta_screen/venta_screen.dart';
import 'package:cafe/venta_screen/ver_ventas_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fijar orientaciones permitidas
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Si está en escritorio, inicializar windowManager
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      center: true,
      title: "Cafe Paquito",
      backgroundColor: Color.fromRGBO(33, 33, 33, 0.392),
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
      size: Size(1200, 800),
      minimumSize: Size(900, 600),
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.maximize(); // Siempre abrir maximizado
    });
  }

  // Conexión a la base de datos
  try {
    await Database.connect();
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
      routes: {
        '/': (context) => const InicioDeSesion01(),
        '/home': (context) => const HomeScreen(),
        '/turno_caja': (context) => const SizedBox(),
        '/detalle_turno': (context) => DetallesTurnoCajaScreen(),
        'productoScreen': (context) => const ProductosScreen(),
      },
    );
  }
}

// ----- INICIO DEL CÓDIGO DE BLOQUEO DE VENTANA -----

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  bool isMaximized = true;
  int index = 0;

  final List<Widget> listaDeScreens = [
    const InicioScreen(),
    const ProductosScreen(),
    const VentaScreen(),
    const ClientesScreen(),
    if (SesionActiva().rolUsuario == 'Admin') const PromocionesPage(),
    if (SesionActiva().rolUsuario == 'Admin') const AdministradoresScreen(),
    const ControlDeGastosScreen(),
    if (SesionActiva().rolUsuario == 'Admin') const ControlStockScreen(),
    if (SesionActiva().rolUsuario == 'Admin') const TurnoCajaScreen(),
    const VerVentasScreen(),
    const ConfiguracionesScreen(),
  ];

  void cambiarIndex(int nuevoIndex) {
    setState(() {
      index = nuevoIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    _setupMaximizeListener();
     // Solicitar foco al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _setupMaximizeListener() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);
      // Al abrir, forzar maximizado por cualquier cosa
      if (!await windowManager.isMaximized()) {
        await windowManager.maximize();
      }
    }
  }

  // Si la ventana es restaurada o redimensionada, la volvemos a maximizar
  @override
  void onWindowResize() async {
    if (!await windowManager.isMaximized()) {
      await windowManager.maximize();
    }
  }

  @override
  void onWindowUnmaximize() async {
    if (!await windowManager.isMaximized()) {
      await windowManager.maximize();
    }
  }

  //FocusNode para manejar el teclado
  // Esto es necesario para que el KeyboardListener funcione correctamente
  final FocusNode _focusNode = FocusNode(); 

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          // Aquí puedes manejar eventos de teclado si es necesario
          // Por ejemplo, cambiar de pantalla con teclas específicas
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            if (index > 0) cambiarIndex(index - 1);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            if (index < listaDeScreens.length - 1) cambiarIndex(index + 1);
          }
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            CabezeraMain(
              isMaximized: isMaximized,
            ),
            Expanded(
              child: Row(
                children: [
                  NavbarNavegacion(
                    onTap: cambiarIndex,
                    selectedIndex: index,
                  ),
                  Expanded(
                    child: Container(
                      color: const Color.fromARGB(255, 250, 240, 230),
                      child: listaDeScreens[index],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }
}

// ----- FIN DEL CÓDIGO DE BLOQUEO DE VENTANA -----

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
      Icons.inventory,
      Icons.shopping_cart,
      Icons.person,
      if (SesionActiva().rolUsuario == 'Admin') Icons.discount,
      if (SesionActiva().rolUsuario == 'Admin') Icons.badge,
      Icons.attach_money_outlined,
      if (SesionActiva().rolUsuario == 'Admin') Icons.inventory_sharp,
      if (SesionActiva().rolUsuario == 'Admin') Icons.receipt_long,
      Icons.payments,
      Icons.settings,
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
              '${SesionActiva().nombreUsuario?.toUpperCase()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 90,
            child: Row(
              children: [
                Container(
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
