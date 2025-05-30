import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class RegistrarPromocionController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  /// Registra una nueva promoción en la base de datos
  Future<bool> registrarPromocion({
    required String nombrePromocion,
    required String descripcion,
    required double porcentaje,
    required int comprasNecesarias,
    required double dineroNecesario,
    required double topeDescuento,
    required bool status,
  }) async {
    try {
      estado.value = Estado.carga;
      mensaje.value = ''; // Limpia mensaje previo

      final sql = Sql.named('''
        INSERT INTO promocion 
        (nombrePromocion, descripcion, porcentaje, comprasNecesarias, dineroNecesario, topeDescuento, status)
        VALUES (@nombrePromocion, @descripcion, @porcentaje, @comprasNecesarias, @dineroNecesario, @topeDescuento,  @status)
      ''');

      await Database.conn.execute(sql, parameters: {
        'nombrePromocion': nombrePromocion,
        'descripcion': descripcion,
        'porcentaje': porcentaje,
        'comprasNecesarias': comprasNecesarias,
        'dineroNecesario': dineroNecesario,
        'topeDescuento': topeDescuento,
        'status': status,
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
