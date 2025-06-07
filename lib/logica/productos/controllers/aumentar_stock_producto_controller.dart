import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class AumentarStockProductoController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  Future<bool> aumentarStockProducto(int idProducto, double cantidad, double cantidadAnterior, String unidad_medida) async {
    try {
      estado.value = Estado.carga;
      mensaje.value = '';

      final sql = Sql.named('''
        UPDATE productos SET 
          cantidad = cantidad + @cantidad
        WHERE id_producto = @idProducto
        RETURNING cantidad;
      ''');


      await Database.conn.execute(sql, parameters: {
        'cantidad': cantidad,
        'idProducto': idProducto,
      });

      final sqlControlStock = Sql.named('''
         INSERT INTO controlStock (id_producto, cantidad_antes, cantidad_movimiento, cantidad_despues, unidad_medida, categoria, id_usuario, fecha) 
        VALUES (
          @idProducto, 
          @cantidad_antes,
          @cantidad_movimiento, 
          @cantidad_despues,
          (SELECT unidad_medida FROM productos WHERE id_producto = @idProducto),
          @categoria,
          @idUsuario,
          @fecha
        );
      ''');

      await Database.conn.execute(sqlControlStock, parameters: {
        'idProducto': idProducto,
        'cantidad_antes': cantidadAnterior,
        'cantidad_movimiento': cantidad,
        'cantidad_despues': cantidad + cantidadAnterior,
        'categoria': 'agregado',
        'idUsuario': SesionActiva().idUsuario,
        'fecha': DateTime.now().toIso8601String(),
      });
      final ObtenerProductosControllers obtenerProductosController =
          Get.find<ObtenerProductosControllers>();

      mensaje.value = 'Stock aumentado correctamente';
      obtenerProductosController.obtenerProductos();
      estado.value = Estado.exito;
      return true;
    } catch (e) {
      print('Error al aumentar stock: $e');
      estado.value = Estado.error;
      mensaje.value = 'Error al aumentar el stock: ${e.toString()}';
      return false;
    }
  }
}
