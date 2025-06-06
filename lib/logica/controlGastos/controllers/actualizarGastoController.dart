import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/controlGastos/controllers/obtenerGastosContoller.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ActualizarGastoController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> actualizarGasto({
    required int idGasto,
    required int idCategoria,
    required String descripcion,
    required double monto,
    required DateTime fechaGasto,
    required String metodoPago,
    String? notas,
    String? ubicacion,
  }) async {
    try {
      estado.value = Estado.carga;

      final sql = Sql.named('''
        UPDATE controlGastos
        SET
          idcategoria = @idCategoria,
          descripcion = @descripcion,
          monto = @monto,
          fechagasto = @fechaGasto,
          metodopago = @metodoPago,
          notas = @notas,
          ubicacion = @ubicacion,
          last_modified = NOW()
        WHERE idgasto = @idGasto;
      ''');


      await Database.conn.execute(sql, parameters: {
        'idGasto': idGasto,
        'idCategoria': idCategoria,
        'descripcion': descripcion,
        'monto': monto,
        'fechaGasto': fechaGasto.toIso8601String().substring(0, 10),
        'metodoPago': metodoPago,
        'notas': (notas == null || notas.isEmpty) ? null : notas,
        'ubicacion': (ubicacion == null || ubicacion.isEmpty) ? null : ubicacion,
      });

      estado.value = Estado.exito;
      // actualiza la lista de gastos después de editar
      final ObtenerGastosController gastos = Get.find<ObtenerGastosController>();
      await gastos.obtenerGastos();
      return true;
    } catch (e) {
      print('Error al actualizar el gasto: $e');
      mensaje.value = 'Ocurrió un error al actualizar el gasto: $e';
      estado.value = Estado.error;
      return false;
    }
  }
}