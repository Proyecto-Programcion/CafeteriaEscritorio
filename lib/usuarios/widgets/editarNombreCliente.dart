import 'package:cafe/logica/usuarios/controllers/actualizaUsuario.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cafe/logica/usuarios/controllers/obtenerUsuarios.dart';

class ModalEditarNombreCliente extends StatefulWidget {
  final int idCliente;
  final String nombreActual;

  const ModalEditarNombreCliente({
    super.key,
    required this.idCliente,
    required this.nombreActual,
  });

  @override
  State<ModalEditarNombreCliente> createState() => _ModalEditarNombreClienteState();
}

class _ModalEditarNombreClienteState extends State<ModalEditarNombreCliente> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nombreController;
  bool _isLoading = false;

  late final EditarClienteController editarController;
  late final ObtenerClientesController clientesController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.nombreActual);
    editarController = Get.put(EditarClienteController());
    clientesController = Get.put(ObtenerClientesController());
  }

  Future<void> editarNombre() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await editarController.editarNombreCliente(
        idCliente: widget.idCliente,
        nuevoNombre: nombreController.text.trim(),
      );
      await clientesController.obtenerClientes();

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      String mensaje = e.toString().replaceFirst('Exception: ', '');
      _mostrarDialogoError(mensaje);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarDialogoError(String mensaje) {
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
                  const Text(
                    "Editar nombre del cliente",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: TextFormField(
                      controller: nombreController,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo obligatorio' : null,
                      decoration: InputDecoration(
                        labelText: "Nombre",
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 15),
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
                      ),
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
                      onPressed: _isLoading ? null : editarNombre,
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
                              'Guardar cambios',
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