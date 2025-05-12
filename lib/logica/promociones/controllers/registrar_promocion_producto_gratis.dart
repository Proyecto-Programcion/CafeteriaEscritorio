import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class RegistrarPromocionProductoGratis extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  /// Registra una nueva promoción en la base de datos
  Future<bool> registrarPromocion({
    required String nombrePromocion,
    required String descripcion,
    required int idProducto,
    required int comprasNecesarias,
    required double dineroNecesario,
    required bool status,
    required double cantidad_producto,
  }) async {
    try {
      estado.value = Estado.carga;
      mensaje.value = ''; // Limpia mensaje previo

      final sql = Sql.named('''
       INSERT INTO promocion_producto_gratis (nombre_promocion, descripcion, id_producto, compras_necesarias, dinero_necesario, status, cantidad_producto)
       VALUES (@nombrePromocion, @descripcion, @idProducto, @comprasNecesarias, @dineroNecesario, @status, @cantidad_producto)
      ''');

      await Database.conn.execute(sql, parameters: {
        'nombrePromocion': nombrePromocion,
        'descripcion': descripcion,
        'comprasNecesarias': comprasNecesarias,
        'dineroNecesario': dineroNecesario,
        'idProducto': idProducto,
        'status': status,
        'cantidad_producto': cantidad_producto,
      });

      estado.value = Estado.exito;
      mensaje.value = 'Promoción registrada correctamente';
      return true;
    } catch (e) {
      print('Error al registrar promoción: $e');
      estado.value = Estado.error;
      mensaje.value = 'Error al registrar promoción: ${e.toString()}';
      return false;
    }
  }
}
