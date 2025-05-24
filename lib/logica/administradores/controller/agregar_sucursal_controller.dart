import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:postgres/postgres.dart';

class AgregarSucursalController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  Future<bool> agregarSucursal(String nombre, String direccion) async {
    try {
      estado.value = Estado.carga;
      final sql = Sql.named('''
        INSERT INTO sucursales (nombre, direccion)
        VALUES (@nombre, @sucursal);
        ''');

      final resp = await Database.conn.execute(sql, parameters: {
        'nombre': nombre,
        'sucursal': direccion,
      });

      estado.value = Estado.exito;
      mensaje.value = 'Sucursal agregada exitosamente';
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al agregar la sucursal: $e';
      return false;
    }
  }
}
