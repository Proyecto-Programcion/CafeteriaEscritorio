import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/controlGastos/controllers/obtenerGastosContoller.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class EliminarGastoController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> eliminarGasto(int idGasto) async {
    try {
      estado.value = Estado.carga;

      final sql = Sql.named('''
        DELETE FROM controlGastos
        WHERE idgasto = @id_gasto;
      ''');

      await Database.conn.execute(sql, parameters: {
        'id_gasto': idGasto,
      });

      estado.value = Estado.exito;
      // Refresca la lista de gastos después de eliminar
      final ObtenerGastosController gastosController = Get.find<ObtenerGastosController>();
      await gastosController.obtenerGastos();
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al eliminar el gasto: $e';
      return false;
    }
  }
}