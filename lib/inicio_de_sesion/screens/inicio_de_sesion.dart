import 'package:cafe/inicio_de_sesion/screens/widgets/cabezera_acciones_ventana.dart';
import 'package:cafe/inicio_de_sesion/screens/widgets/modal_iniciar_sesion.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class InicioDeSesion01 extends StatefulWidget {
  const InicioDeSesion01({super.key});

  @override
  State<InicioDeSesion01> createState() => _InicioDeSesion01State();
}

class _InicioDeSesion01State extends State<InicioDeSesion01> {
  bool isMaximized = false;

  void _init() async {
    isMaximized = await windowManager.isMaximized();
    setState(() {});
  }

  @override
  void onWindowMaximize() {
    setState(() => isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    setState(() => isMaximized = false);
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

class BottonIniciarSesion extends StatelessWidget {
  BottonIniciarSesion({
    super.key,
  });

  // Controladores de los campos de texto
  TextEditingController correoController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  // Clave del formulario
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void _iniciarSesion() {
    if (formKey.currentState!.validate()) {
      print('Iniciando sesión con: ${correoController.text}');
      print('Contraseña: ${contrasenaController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: // Puedes colocar este widget donde lo necesites
          InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return ModalIniciarSesion(
                  contrasenaController: contrasenaController,
                  correoController: correoController,
                  formKey: formKey,
                  inicioDeSesion: () => _iniciarSesion(),
                );
              });
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: const Text(
            'Iniciar sesión',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
