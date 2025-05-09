import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:postgres/postgres.dart';

class AgregarCategoriaController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> agregarCategoria(String nombre) async {
    try {
      estado.value = Estado.carga;

      final sql = Sql.named('''
        INSERT INTO categorias (idUsuario, nombre)
        VALUES (@idUsuario, @nombre);
      ''');

      await Database.conn.execute(sql, parameters: {
        'nombre': nombre,
      });

      estado.value = Estado.exito;
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al agregar la categoría: $e';
      return false;
    }
  }
}
