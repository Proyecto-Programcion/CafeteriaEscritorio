import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/promociones/controllers/obtener_promociones_productos_gratis.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class EliminarPromocionProductosGratisController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  Future<bool> eliminarPromocionProductosGratis(int idPromocion) async {
    try {
      estado.value = Estado.carga;
      final sql = Sql.named('''
        UPDATE promocion_producto_gratis 
        SET eliminado = TRUE
        WHERE id_promocion_productos_gratis = @idPromocion
      ''');

      await Database.conn.execute(
        sql,
        parameters: {'idPromocion': idPromocion},
      );
      estado.value = Estado.exito;
      final ObtenerPromocionesProductosGratisController
          obtenerPromocionesProductosGratisController =
          Get.find<ObtenerPromocionesProductosGratisController>();
      await obtenerPromocionesProductosGratisController.obtenerPromociones();
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al eliminar la promoción: $e';
      return false;
    }
  }
}
