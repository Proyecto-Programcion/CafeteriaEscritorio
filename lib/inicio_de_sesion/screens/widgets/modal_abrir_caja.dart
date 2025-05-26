import 'package:cafe/common/sesion_activa.dart';
import 'package:cafe/inicio_de_sesion/controllers/abrir_caja_contorller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ModalAbrirCaja extends StatelessWidget {
  ModalAbrirCaja({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidadController = TextEditingController();

  void _abrirCaja(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final AgregarTurnoCajaController agregarTurnoCajaController =
          Get.put(AgregarTurnoCajaController());
      final resp = await agregarTurnoCajaController.agregarTurnoCaja(
        idUsuario: SesionActiva().idUsuario!,
        fechaInicio: DateTime.now(),
        montoInicial: double.tryParse(_cantidadController.text) ?? 0.0,
      );

      if (resp) {
        Navigator.pop(context, true);
      } else {
        Navigator.pop(context, false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al abrir la caja, Intentalo de nuevo. Error: ${agregarTurnoCajaController.mensajeError.value}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        width: 400,
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hola ${SesionActiva().nombreUsuario}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ingresa la cantidad de dinero con la que deseas abrir la caja.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
                child: TextFormField(
              controller: _cantidadController,
              decoration: InputDecoration(
                labelText: 'Cantidad a abrir',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una cantidad';
                }
                final cantidad = double.tryParse(value);
                if (cantidad == null || cantidad <= -1) {
                  return 'Ingresa un número válido mayor a 0';
                }
                return null;
              },
            )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _abrirCaja(context);
              },
              child: const Text('Abrir Caja'),
            ),
          ],
        ),
      ),
    );
  }
}
