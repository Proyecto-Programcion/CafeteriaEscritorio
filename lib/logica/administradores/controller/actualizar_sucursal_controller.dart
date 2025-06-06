

import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ActualizarSucursalController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  Future<bool> actualizarSucursal(int idSucursal, String nombre, String direccion) async {
    try {
      estado.value = Estado.carga;
      final sql = Sql.named('''
        UPDATE sucursales
        SET nombre = @nombre,
            direccion = @direccion,
            last_modified = NOW()
        WHERE id_sucursal = @idSucursal;
      ''');


      await Database.conn.execute(sql, parameters: {
        'idSucursal': idSucursal,
        'nombre': nombre,
        'direccion': direccion,
      });

      estado.value = Estado.exito;
      mensaje.value = 'Sucursal actualizada exitosamente';
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al actualizar la sucursal: $e';
      return false;
    }
  }
}