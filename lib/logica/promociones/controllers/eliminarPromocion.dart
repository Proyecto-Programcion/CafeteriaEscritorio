import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart'; // <-- ¡IMPORTANTE!

class EliminarPromocionController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  Future<void> eliminarPromocion(int idPromocion) async {
    try {
      estado.value = Estado.carga;
      mensaje.value = '';

      // Usa Sql.named para soportar parámetros nombrados
      final sql = Sql.named('''
        DELETE FROM promocion
        WHERE id_promocion = @idPromocion
      ''');

      await Database.conn.execute(
        sql,
        parameters: {'idPromocion': idPromocion},
      );

      estado.value = Estado.exito;
      mensaje.value = 'Promoción eliminada correctamente';
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al eliminar la promoción: ${e.toString()}';
      print('[ERROR] $e');
    }
  }
}