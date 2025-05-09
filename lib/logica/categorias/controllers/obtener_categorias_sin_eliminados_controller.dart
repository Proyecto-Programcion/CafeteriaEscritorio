import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/categorias/categoria_modelo.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:postgres/postgres.dart';

class ObtenerCategoriasControllerSinEliminar extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;
  RxList<dynamic> categorias = <dynamic>[].obs;

  Future<bool> obtenerCategorias() async {
    try {
      estado.value = Estado.carga;
      // Limpiar la lista de categorías antes de obtener nuevas
      categorias.clear();
      final sql = Sql.named('''
        SELECT * FROM categorias;
      ''');
      final resp = await Database.conn.execute(sql);
      print('resp: $resp');
      resp.forEach((element) {
        categorias.add(CategoriaModelo(
          idCategoria: element[0] as int,
          idUsuario: element[1] as int,
          nombre: element[2] as String,
        ));
      });
      estado.value = Estado.exito;
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al obtener las categorías: $e';
      return false;
    }
  }
}
