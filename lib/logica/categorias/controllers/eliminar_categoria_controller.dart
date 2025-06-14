import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/categorias/controllers/obtener_categorias_controller.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/instance_manager.dart';
import 'package:postgres/postgres.dart';

class EliminarCategoriaController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> eliminarCategoria(int idCategoria) async {
    try {
      estado.value = Estado.carga;
      final sql = Sql.named('''
        UPDATE categorias 
        SET eliminado = TRUE
        WHERE id_categoria = @idCategoria;
      ''');


      await Database.conn.execute(sql, parameters: {
        'idCategoria': idCategoria,
      });

      estado.value = Estado.exito;
      final ObtenerCategoriasController obtenerCategoriasController =
          Get.put(ObtenerCategoriasController());
      obtenerCategoriasController.obtenerCategorias();
      return true;
    } catch (e) {
      print('Error al eliminar la categoría: $e');
      estado.value = Estado.error;
      mensaje.value = 'Error al eliminar la categoría: $e';
      return false;
    }
  }

  
}
