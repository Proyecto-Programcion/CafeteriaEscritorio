import 'dart:convert';
import 'dart:io';

import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/administradores/controller/listar_administradores_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class AgregarAdministradorController extends GetxController {
  final Rx<Estado> estado = Estado.inicio.obs;
  final RxString mensaje = ''.obs;

  Future<bool> agregarAdministrador({
    required String nombre,
    String? correo,
    required String telefono,
    required String urlImagen,
    required int idSucursal,
    required String contrasena,
    required String rol,
  }) async {
    estado.value = Estado.carga;
    mensaje.value = '';
    try {
      String imagenBase64 = '';
      if (urlImagen.isNotEmpty) {
        try {
          imagenBase64 = base64Encode(await File(urlImagen).readAsBytes());
        } catch (_) {
          imagenBase64 = '';
        }
      }

      final sql = Sql.named('''
        INSERT INTO usuarios (nombre, correo, telefono, contrasena, imagen, idSucursal, rol)
        VALUES (@nombre, @correo, @telefono, @contrasena, @imagen, @idsucursal, @rol);
      ''');

      await Database.conn.execute(sql, parameters: {
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'contrasena': contrasena,
        'imagen': imagenBase64,
        'idsucursal': idSucursal,
        'rol': rol,
      });

      estado.value = Estado.exito;
      Get.back();
      Get.snackbar(
        'Éxito',
        'Administrador agregado exitosamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      final ListarAdministradoresController listarAdminsController =
          Get.find<ListarAdministradoresController>();
      listarAdminsController.obtenerAdministradores();
      mensaje.value = 'Administrador agregado exitosamente';
      return true;
    } catch (e) {
      estado.value = Estado.error;
      print('Error al agregar administrador: $e');
      if (e.toString().contains('duplicate key value')) {
        if (e.toString().contains('correo')) {
          mensaje.value = 'Ya existe un administrador con ese correo';
        } else if (e.toString().contains('usuarios_telefono_key')) {
          mensaje.value = 'Ya existe un administrador con ese teléfono';
        } else {
          mensaje.value = 'Error al agregar el administrador: $e';
        }
        Get.snackbar(
          'Error',
          mensaje.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
      return false;
    }
  }
}
