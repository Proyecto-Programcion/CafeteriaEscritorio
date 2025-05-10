import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterClienteController extends GetxController {
  var cargando = false.obs;
  var error = ''.obs;

  Future<void> registrarCliente({
    required String nombre,
    required String telefono,
  }) async {
    cargando.value = true;
    error.value = '';
    try {
      // Aquí iría tu lógica real para registrar el cliente (por ejemplo, petición HTTP)
      await Future.delayed(const Duration(seconds: 1)); // Simulación
      Get.back(); // Cierra el modal
      Get.snackbar('Éxito', 'Cliente registrado correctamente');
    } catch (e) {
      error.value = 'Error al registrar: $e';
    }
    cargando.value = false;
  }
}

class ModalRegistrarCliente extends StatelessWidget {
  const ModalRegistrarCliente({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterClienteController());
    final nombreCtrl = TextEditingController();
    final telCtrl = TextEditingController();

    return AlertDialog(
      title: const Text('Registrar nuevo cliente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nombreCtrl,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: telCtrl,
            decoration: const InputDecoration(labelText: 'Teléfono'),
            keyboardType: TextInputType.phone,
          ),
          Obx(() => controller.error.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(controller.error.value,
                      style: const TextStyle(color: Colors.red)),
                )
              : const SizedBox.shrink()),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        Obx(() => controller.cargando.value
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  await controller.registrarCliente(
                    nombre: nombreCtrl.text,
                    telefono: telCtrl.text,
                  );
                },
                child: const Text('Registrar'),
              )),
      ],
    );
  }
}