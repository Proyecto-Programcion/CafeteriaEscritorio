import 'package:cafe/logica/clientes/controllers/registrarClientes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cafe/logica/clientes/controllers/obtenerClientes.dart';
import 'package:flutter/services.dart';

class ModalRegistrarCliente extends StatefulWidget {
  const ModalRegistrarCliente({super.key});

  @override
  State<ModalRegistrarCliente> createState() => _ModalRegistrarClienteState();
}

class _ModalRegistrarClienteState extends State<ModalRegistrarCliente> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();

  bool _isLoading = false;

  Future<void> registrarCliente() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Inicializa el controlador si no está inicializado
      if (!Get.isRegistered<RegistrarUsuariosController>()) {
        Get.put(RegistrarUsuariosController());
      }
      if (!Get.isRegistered<ObtenerClientesController>()) {
        Get.put(ObtenerClientesController());
      }
      final clientesController = Get.find<ObtenerClientesController>();
      final registrarController = Get.find<RegistrarUsuariosController>();
      await registrarController.registrarUsuario(
        nombre: nombreController.text.trim(),
        numeroTelefono: telefonoController.text.trim(),
      );
      // Refresca el listado
      await clientesController.obtenerClientes();

      if (mounted) {
        Navigator.of(context).pop();
      }
      print('Cliente registrado correctamente');
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('duplicate key value') &&
          errorMsg.contains('telefono')) {
        // Extrae el número duplicado del error
        final RegExp regex =
            RegExp(r'Key \(telefono\)=\((\d+)\) already exists');
        final match = regex.firstMatch(errorMsg);
        final telefonoDuplicado =
            match != null ? match.group(1) : telefonoController.text.trim();
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            backgroundColor: const Color(0xFFFAF0E6), // fondoColor
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        color: Color(0xFF9B7B22), size: 44),
                    const SizedBox(height: 10),
                    const Text(
                      'Error',
                      style: TextStyle(
                        color: Color(0xFF9B7B22), // primaryTextColor
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // Línea decorativa
                    Container(
                      height: 3,
                      width: 44,
                      margin: const EdgeInsets.only(top: 4, bottom: 10),
                      decoration: BoxDecoration(
                        color: Color(0xFFF0F0F0), // tableHeaderColor
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Ya existe un cliente con ese teléfono.',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF9B7B22), // primaryTextColor
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        // Quita "Exception: " si existe al inicio del mensaje
        String mensaje = errorMsg;
        if (mensaje.startsWith('Exception: ')) {
          mensaje = mensaje.replaceFirst('Exception: ', '');
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
      print('No se pudo registrar el cliente: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cerrar
                  Row(
                    children: [
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Título
                  const Text(
                    "Registrar nuevo cliente",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Nombre
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: TextFormField(
                      controller: nombreController,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo obligatorio' : null,
                      decoration: _rectFieldDecoration("Nombre"),
                    ),
                  ),
                  // Teléfono
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: TextFormField(
                      controller: telefonoController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obligatorio';
                        if (v.length != 10) return 'Debe tener 10 dígitos';
                        final number = int.tryParse(v);
                        if (number == null) return 'Ingrese sólo números';
                        return null;
                      },
                      decoration: _rectFieldDecoration("Teléfono"),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                registrarCliente();
                              }
                            },
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Registrar Cliente',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _rectFieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle:
        const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.black, width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFD3D3D3)),
    ),
    filled: true,
    fillColor: const Color(0xFFF8F8F8),
  );
}
