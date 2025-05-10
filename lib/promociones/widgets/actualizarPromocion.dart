import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class EditarPromocionController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<void> editarPromocion({
    required int idPromocion,
    required String nombre,
    required String descripcion,
    required int porcentaje,
    required int comprasNecesarias,
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
            status = @status
        WHERE id_promocion = @idPromocion
      ''');

      await Database.conn.execute(sql, parameters: {
        'nombre': nombre,
        'descripcion': descripcion,
        'porcentaje': porcentaje,
        'comprasNecesarias': comprasNecesarias,
        'status': status,
        'idPromocion': idPromocion,
      });

      estado.value = Estado.exito;
      mensaje.value = 'Promoción actualizada correctamente.';
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al actualizar la promoción: $e';
      throw Exception('Error al actualizar la promoción: $e');
    }
  }
}