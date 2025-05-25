import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class AgregarGastoController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> agregarGasto({
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
        INSERT INTO controlGastos (
          idCategoria,
          descripcion,
          monto,
          fechaGasto,
          metodoPago,
          notas,
          ubicacion
        ) VALUES (
          @idCategoria,
          @descripcion,
          @monto,
          @fechaGasto,
          @metodoPago,
          @notas,
          @ubicacion
        );
      ''');

      await Database.conn.execute(sql, parameters: {
        'idCategoria': idCategoria,
        'descripcion': descripcion,
        'monto': monto,
        'fechaGasto': fechaGasto.toIso8601String().substring(0, 10), // 'YYYY-MM-DD'
        'metodoPago': metodoPago,
        'notas': (notas == null || notas.isEmpty) ? null : notas,
        'ubicacion': (ubicacion == null || ubicacion.isEmpty) ? null : ubicacion,
      });

      estado.value = Estado.exito;
      mensaje.value = 'Gasto agregado exitosamente';
      return true;
    } catch (e) {
      print('Error al agregar gasto: $e');
      mensaje.value = 'Error al agregar el gasto: $e';
      estado.value = Estado.error;
      return false;
    }
  }
}