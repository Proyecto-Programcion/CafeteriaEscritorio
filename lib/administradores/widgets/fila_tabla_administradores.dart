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

  // Método para construir avatar según tipo de imagen (base64 o URL)
  Widget _buildAvatar(String? imagen) {
    if (imagen == null || imagen.isEmpty) {
      return const Icon(Icons.person, color: Colors.white, size: 32);
    } else if (imagen.startsWith('http') || imagen.startsWith('https')) {
      // Es URL
      return ClipOval(
        child: Image.network(
          imagen,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, color: Colors.white, size: 32);
          },
        ),
      );
    } else {
      // Intenta decodificar Base64
      try {
        final bytes = base64Decode(imagen);
        return ClipOval(
          child: Image.memory(
            bytes,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        print('Error al decodificar base64: $e');
        return const Icon(Icons.person, color: Colors.white, size: 32);
      }
    }
  }

  void eliminarAdministrador(BuildContext context) async {
    final EliminarAdministradorController eliminarAdministradorController =
        Get.put(EliminarAdministradorController());
    final resp = await eliminarAdministradorController
        .eliminarAdministrador(administradorModelo.idUsuario);
    if (resp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El administrador ha sido despedido correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo despedir el administrador'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
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
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
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
                  child: _buildAvatar(administradorModelo.imagen),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  "${administradorModelo.nombre}",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  "${administradorModelo.telefono}",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  "${administradorModelo.correo ?? 'No tiene'}",
                  style: const TextStyle(
                    fontSize: 16,
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
                    fontSize: 16,
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
                    fontSize: 16,
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
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        eliminarAdministrador(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
