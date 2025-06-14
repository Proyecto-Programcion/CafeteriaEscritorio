import 'dart:convert';
import 'dart:io';

import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/administradores/controller/listar_administradores_controller.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class AgregarAdministradorController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  Future<bool> agregarAdministrador(
      {required String nombre,
      String? correo,
      required String telefono,
      required String urlImagen,
      required int idSucursal,
      required String contrasena,
      required String rol}) async {
    try {
      estado.value = Estado.carga;
      String imagenBase64 = '';

      //pasar la imagen a base 64
      if (urlImagen != '') {
        File imageFile = File(urlImagen);
        List<int> imageBytes = await imageFile.readAsBytes();
        imagenBase64 = base64Encode(imageBytes);
      }

      final sql = Sql.named('''
       INSERT INTO usuarios (nombre, correo, telefono, contrasena, imagen, idSucursal, rol)
      VALUES (@nombre, @correo, @telefono, @contrasena, @imagen, @idsucursal, @rol);
      ''');

      final resp = await Database.conn.execute(sql, parameters: {
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'contrasena': contrasena,
        'imagen': imagenBase64,
        'idsucursal': idSucursal,
        'rol': rol,
      });

      estado.value = Estado.exito;
      final ListarAdministradoresController listarAdministradoresController =
          Get.find<ListarAdministradoresController>();
      listarAdministradoresController.obtenerAdministradores();
      mensaje.value = 'Administrador agregado exitosamente';
      return true;
    } catch (e) {
      print('Error al agregar el administrador: $e');
      estado.value = Estado.error;
      mensaje.value = 'Error al agregar el administrador: $e';
      return false;
    }
  }
}
