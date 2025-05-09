import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/categorias/controllers/obtener_categorias_controller.dart';
import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/instance_manager.dart';
import 'package:postgres/postgres.dart';

class AgregarCategoriaController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> agregarCategoria(int idUsuario, String nombre) async {
    try {
      estado.value = Estado.carga;

      final sql = Sql.named('''
        INSERT INTO categorias (id_usuario, nombre)
        VALUES (@id_usuario, @nombre);
      ''');

      await Database.conn.execute(sql, parameters: {
        'id_usuario': idUsuario,
        'nombre': nombre,
      });

      estado.value = Estado.exito;
     final ObtenerCategoriasController obtenerCategoriasController =
          Get.put(ObtenerCategoriasController());
    obtenerCategoriasController.obtenerCategorias();
      return true;
    } catch (e) {
      print('Error al agregar la categoría: $e');
      estado.value = Estado.error;
      mensaje.value = 'Error al agregar la categoría: $e';
      return false;
    }
  }
}
