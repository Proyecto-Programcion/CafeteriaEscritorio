import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class EliminarSucursalController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  Future<bool> eliminarSucursal(int idSucursal) async {
    try {
      estado.value = Estado.carga;

      // Verificar si la sucursal está siendo usada por algún administrador
      final sqlVerificar = Sql.named('''
        SELECT COUNT(*) as total
        FROM usuarios 
        WHERE idSucursal = @idSucursal 
        AND statusDespedido = FALSE 
        AND rol = 'Admin'
      ''');

      final resultVerificar = await Database.conn
          .execute(sqlVerificar, parameters: {'idSucursal': idSucursal});

      final cantidadAdministradores =
          resultVerificar.first.toColumnMap()['total'] as int;

      // Si hay administradores usando la sucursal, no se puede eliminar
      if (cantidadAdministradores > 0) {
        estado.value = Estado.error;
        mensaje.value =
            'No se puede eliminar la sucursal porque tiene $cantidadAdministradores administrador(es) asignado(s)';
        return false;
      }

      // Si no hay administradores, marcar la sucursal como eliminada
      final sqlEliminar = Sql.named('''
        UPDATE sucursales 
        SET eliminado = TRUE 
        WHERE id_sucursal = @idSucursal
      ''');

      await Database.conn
          .execute(sqlEliminar, parameters: {'idSucursal': idSucursal});

      estado.value = Estado.exito;
      mensaje.value = 'Sucursal eliminada exitosamente';
      return true;
    } catch (e) {
      print('Error al eliminar sucursal: $e');
      estado.value = Estado.error;
      mensaje.value = 'Error al eliminar la sucursal: $e';
      return false;
    }
  }
}
