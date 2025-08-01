import 'package:cafe/common/enums.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:cafe/inicio_de_sesion/controllers/evaluar_si_hay_caja_abierta.dart';
import 'package:cafe/inicio_de_sesion/controllers/iniciar_sesion_controller.dart';
import 'package:cafe/inicio_de_sesion/screens/widgets/modal_abrir_caja.dart';
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
  final EvaluarSiHayCajaAbiertaController evaluarSiHayCajaAbiertaController =
      Get.put(EvaluarSiHayCajaAbiertaController());

  void _iniciarSesion(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      final resp = await iniciarSesionController.iniciarSesion(
          correoController.text, contrasenaController.text);
      if (resp) {
        final resp = await evaluarSiHayCajaAbiertaController
            .evaluarSiHayCajaAbierta(idUsuario: SesionActiva().idUsuario!);
            print('Respuesta de evaluar si hay caja abierta: $resp');
        if (resp) {
          // Si hay caja abierta, redirigir a la pantalla de inicio
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else {
          // Si no hay caja abierta, mostrar modal para abrir caja
          showDialog(
            context: context,
            builder: (context) {
              return ModalAbrirCaja();
            },
          );
        }
      }
    }
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
