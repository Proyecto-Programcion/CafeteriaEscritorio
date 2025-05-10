import 'package:cafe/inicio_de_sesion/controllers/iniciar_sesion_controller.dart';
import 'package:cafe/inicio_de_sesion/screens/widgets/modal_iniciar_sesion.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class BottonIniciarSesion extends StatelessWidget {
  BottonIniciarSesion({
    super.key,
  });

  // Controladores de los campos de texto
  TextEditingController correoController = TextEditingController();
  TextEditingController contrasenaController = TextEditingController();
  // Clave del formulario
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final IniciarSesionController iniciarSesionController =
      Get.put(IniciarSesionController());

  // void _iniciarSesion(BuildContext context) async {
  //   if (formKey.currentState!.validate()) {
  //     print('Iniciando sesión con: ${correoController.text}');
  //     print('Contraseña: ${contrasenaController.text}');
  //     final resp = await iniciarSesionController.iniciarSesion(
  //         correoController.text, contrasenaController.text);
  //     if (resp == true) {
  //       Navigator.of(context).pop();
  //       Navigator.pushReplacementNamed(context, '/home');
  //     }
  //   }
  // }
  void _iniciarSesion(BuildContext context) async {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return ModalIniciarSesion(
                  contrasenaController: contrasenaController,
                  correoController: correoController,
                  formKey: formKey,
                  inicioDeSesion: () => _iniciarSesion(context),
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
