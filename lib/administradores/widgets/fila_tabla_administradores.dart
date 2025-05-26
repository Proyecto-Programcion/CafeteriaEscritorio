import 'dart:convert';
import 'dart:typed_data';
import 'package:cafe/administradores/widgets/modal_editar_administrador.dart';
import 'package:cafe/logica/administradores/administrador_modelo.dart';
import 'package:cafe/logica/administradores/controller/eliminar_administrador_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RowTablaAdministradores extends StatelessWidget {
  final AdministradorModelo administradorModelo;
  RowTablaAdministradores({
    super.key,
    required this.administradorModelo,
  });

  // Método para convertir base64 a Uint8List
  Uint8List _base64ToUint8List(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      print('Error al decodificar base64: $e');
      return Uint8List(0); // Retorna array vacío si hay error
    }
  }

  void eliminarAdministrador() async {
    final EliminarAdministradorController eliminarAdministradorController =
        Get.put(EliminarAdministradorController());
    final resp = await eliminarAdministradorController
        .eliminarAdministrador(administradorModelo.idUsuario);
    if (resp) {
      Get.snackbar(
        'Administrador Despedido',
        'El administrador ha sido despedido correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error al despedir',
        'No se pudo despedir el administrador',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 82,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    "${administradorModelo.idUsuario}",
                    style: const TextStyle(
                      fontSize: 16, // Más pequeño y sin bold
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: (administradorModelo.imagen != null &&
                            administradorModelo.imagen!.isNotEmpty)
                        ? MemoryImage(
                            _base64ToUint8List(administradorModelo.imagen!))
                        : null,
                    child: (administradorModelo.imagen == null ||
                            administradorModelo.imagen!.isEmpty)
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 32)
                        : null,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "${administradorModelo.nombre}",
                    style: const TextStyle(
                      fontSize: 16, // Más pequeño y sin bold
                    ),
                  ),
                ),
              ),
              Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      "${administradorModelo.telefono}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  )),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "${administradorModelo.correo ?? 'No tiene'}",
                    style: const TextStyle(
                      fontSize: 16, // Más pequeño y sin bold
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "${administradorModelo.nombreSucursal}",
                    style: const TextStyle(
                      fontSize: 16, // Más pequeño y sin bold
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    "${administradorModelo.rol}",
                    style: const TextStyle(
                      fontSize: 16, // Más pequeño y sin bold
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return ModalActualizarAdministrador(
                                    administradorModelo: administradorModelo);
                              });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          eliminarAdministrador();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
