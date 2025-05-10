import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class RegistrarPromocionController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  /// Registra una nueva promoción en la base de datos
  Future<void> registrarPromocion({
    required String nombrePromocion,
    required String descripcion,
    required int porcentaje,
    required int comprasNecesarias,
    required bool status,
  }) async {
    try {
      estado.value = Estado.carga;
      mensaje.value = ''; // Limpia mensaje previo

      final sql = Sql.named('''
        INSERT INTO promocion 
        (nombrePromocion, descripcion, porcentaje, comprasNecesarias, status)
        VALUES (@nombrePromocion, @descripcion, @porcentaje, @comprasNecesarias, @status)
      ''');

      await Database.conn.execute(sql, parameters: {
        'nombrePromocion': nombrePromocion,
        'descripcion': descripcion,
        'porcentaje': porcentaje,
        'comprasNecesarias': comprasNecesarias,
        'status': status,
      });

      estado.value = Estado.exito;
      mensaje.value = 'Promoción registrada correctamente';
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al registrar promoción: ${e.toString()}';
      rethrow; // Lanza la excepción original, el mensaje lo manejas en la UI
    }
  }
}