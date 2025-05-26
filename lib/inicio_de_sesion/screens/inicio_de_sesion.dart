import 'package:cafe/inicio_de_sesion/controllers/evaluar_si_hay_caja_abierta.dart';
import 'package:cafe/inicio_de_sesion/screens/widgets/boton_iniciar_sesion.dart';
import 'package:cafe/inicio_de_sesion/screens/widgets/cabezera_acciones_ventana.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:window_manager/window_manager.dart';

class InicioDeSesion01 extends StatefulWidget {
  const InicioDeSesion01({super.key});

  @override
  State<InicioDeSesion01> createState() => _InicioDeSesion01State();
}

class _InicioDeSesion01State extends State<InicioDeSesion01> {
  bool isMaximized = false;

  final EvaluarSiHayCajaAbiertaController evaluarSiHayCajaAbiertaController =
      Get.put(EvaluarSiHayCajaAbiertaController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    evaluarSiHayCajaAbiertaController.evaluarSiHayCajaAbierta().then((value) {
      if (value) {
        print('Caja abierta, redirigiendo a la pantalla de inicio');
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: CabezeraAccionesVentana(
            isMaximized: isMaximized,
          ),
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo
              Image.asset(
                'assets/images/fondo-login.jpg', // Cambia por la ruta de tu imagen
                fit: BoxFit.cover,
              ),
              // Container centrado
              Center(
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.7,
                  color: const Color(0xFFFAF0E6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/logo-cafe-paquito.png',
                            fit: BoxFit.contain, // O BoxFit.scaleDown
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.48,
                        child: const VerticalDivider(
                          color: Color.fromARGB(255, 192, 158, 97),
                          thickness: 2,
                          width: 10,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            BottonIniciarSesion(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
