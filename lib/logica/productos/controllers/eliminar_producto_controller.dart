import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:postgres/postgres.dart';

class EliminarProductoController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> eliminarProducto(int idProducto) async {
    try {
      estado.value = Estado.carga;

      final sql = Sql.named('''
        UPDATE productos
        SET eliminado = true,
            codigo_de_barras = NULL
        WHERE id_producto = @id_producto;
      ''');

      await Database.conn.execute(sql, parameters: {
        'id_producto': idProducto,
      });

      estado.value = Estado.exito;
      final ObtenerProductosControllers obtenerProductosControllers =
          Get.find<ObtenerProductosControllers>();
      await obtenerProductosControllers.obtenerProductos();
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al eliminar el producto: $e';
      return false;
    }
  }
}
