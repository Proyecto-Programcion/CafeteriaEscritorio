import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:postgres/postgres.dart';

class ObtenerCategoriasController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;
  RxList<dynamic> categorias = <dynamic>[].obs;

  Future<bool> obtenerCategorias() async {
    try {
      estado.value = Estado.carga;
      final sql = Sql.named('''
        SELECT id_categoria, nombre FROM categorias WHERE eliminado = false;
      ''');
      final result = await Database.conn.execute(sql);
      categorias.value = result.toList();
      estado.value = Estado.exito;
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al obtener las categorías: $e';
      return false;
    }
  }
}
