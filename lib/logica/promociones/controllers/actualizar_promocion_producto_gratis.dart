import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ActualizarPromocionProductoGratisController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> editarPromocion({
    required int idPromocion,
    required String nombre,
    required String descripcion,
    required int idProductoGratis,
    required double cantidadProducto,
    required int comprasNecesarias,
    required double dineroNecesario,
    required bool status,
  }) async {
    try {
      estado.value = Estado.carga;
      final sql = Sql.named('''
        UPDATE promocion_producto_gratis
        SET nombre_promocion = @nombre,
            descripcion = @descripcion,
            id_producto = @idProducto,
            compras_necesarias = @comprasNecesarias,
            dinero_necesario = @dineroNecesario,
            status = @status,
            cantidad_producto = @cantidadProducto
        WHERE id_promocion_productos_gratis = @idPromocion
      ''');


      await Database.conn.execute(sql, parameters: {
        'nombre': nombre,
        'descripcion': descripcion,
        'idProducto': idProductoGratis,
        'cantidadProducto': cantidadProducto,
        'comprasNecesarias': comprasNecesarias,
        'dineroNecesario': dineroNecesario,
        'status': status,
        'idPromocion': idPromocion
      });

      estado.value = Estado.exito;
      mensaje.value = 'Promoción actualizada correctamente.';
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al actualizar la promoción: $e';
      return false;
    }
  }
}
