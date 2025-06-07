import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ActualizarPromocion extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> editarPromocion({
    required int idPromocion,
    required String nombre,
    required String descripcion,
    required double porcentaje,
    required int comprasNecesarias,
    required double dineroNecesario,
    required double topeDescuento,
    required bool status,
  }) async {
    try {
      estado.value = Estado.carga;
      final sql = Sql.named('''
        UPDATE promocion
        SET nombrePromocion = @nombre,
            descripcion = @descripcion,
            porcentaje = @porcentaje,
            comprasNecesarias = @comprasNecesarias,
            dineroNecesario = @dineroNecesario,
            topeDescuento = @topeDescuento,
            status = @status
        WHERE id_promocion = @idPromocion
      ''');


      await Database.conn.execute(sql, parameters: {
        'nombre': nombre,
        'descripcion': descripcion,
        'porcentaje': porcentaje,
        'comprasNecesarias': comprasNecesarias,
        'dineroNecesario': dineroNecesario,
        'topeDescuento': topeDescuento,
        'status': status,
        'idPromocion': idPromocion,
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
