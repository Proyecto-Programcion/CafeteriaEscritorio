

import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ActualizarAdministradorController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  Future<bool> actualizarAdministrador(
    int idAdministrador,
    String nombre,
    String apellido,
    String correo,
    String telefono,
    String contrasena,
    int idSucursal,
  ) async {
    try {
      estado.value = Estado.carga;
      final sql = Sql.named('''
        UPDATE administradores
        SET nombre = @nombre, apellido = @apellido, correo = @correo, telefono = @telefono, contrasena = @contrasena, idSucursal = @idSucursal
        WHERE id_administrador = @idAdministrador;
      ''');

      await Database.conn.execute(sql, parameters: {
        'idAdministrador': idAdministrador,
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'telefono': telefono,
        'contrasena': contrasena,
        'idSucursal': idSucursal,
      });

      estado.value = Estado.exito;
      mensaje.value = 'Administrador actualizado exitosamente';
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al actualizar el administrador: $e';
      return false;
    }
  }
  
}