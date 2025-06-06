import 'dart:convert';
import 'dart:io';

import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:cafe/logica/administradores/controller/listar_administradores_controller.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ActualizarAdministradorController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  Future<bool> actualizarAdministrador(
    int idAdministrador,
    String nombre,
    String correo,
    String telefono,
    String contrasena,
    int idSucursal,
    String? urlImagen,
  ) async {
    try {
      estado.value = Estado.carga;
      String imagenBase64 = '';

      if (urlImagen != '' && urlImagen != null) {
        File imageFile = File(urlImagen);
        List<int> imageBytes = await imageFile.readAsBytes();
        imagenBase64 = base64Encode(imageBytes);
        print('Imagen convertida a Base64');
      }

      // Si hay imagen nueva se actualiza la imagen
      if (imagenBase64.isNotEmpty) {
        final sql = Sql.named('''
          UPDATE usuarios
          SET nombre = @nombre,
              correo = @correo,
              telefono = @telefono,
              contrasena = @contrasena,
              imagen = @imagen,
              idSucursal = @idSucursal,
              last_modified = NOW()
          WHERE id_usuario = @idusuario;
        ''');



        await Database.conn.execute(sql, parameters: {
          'nombre': nombre,
          'correo': correo,
          'telefono': telefono,
          'contrasena': contrasena,
          'imagen': imagenBase64,
          'idSucursal': idSucursal,
          'idusuario': idAdministrador, // Corregido: usar idAdministrador aquí
        });
      } else {
        final sql = Sql.named('''
          UPDATE usuarios
          SET nombre = @nombre,
              correo = @correo,
              telefono = @telefono,
              contrasena = @contrasena,
              idSucursal = @idSucursal,
              last_modified = NOW()
          WHERE id_usuario = @idusuario;
        ''');


        await Database.conn.execute(sql, parameters: {
          'nombre': nombre,
          'correo': correo,
          'telefono': telefono,
          'contrasena': contrasena,
          'idSucursal': idSucursal,
          'idusuario': idAdministrador, // Corregido: usar idAdministrador aquí
        });
      }

      estado.value = Estado.exito;
      mensaje.value = 'Administrador actualizado exitosamente';
      final ListarAdministradoresController listarController =
          Get.put(ListarAdministradoresController());
      listarController.obtenerAdministradores();
      return true;
    } catch (e) {
      print('Error al actualizar administrador: $e');
      estado.value = Estado.error;
      mensaje.value = 'Error al actualizar el administrador: $e';
      return false;
    }
  }
}
