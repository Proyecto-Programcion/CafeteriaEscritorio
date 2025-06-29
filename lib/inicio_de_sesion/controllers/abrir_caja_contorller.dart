import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class AgregarTurnoCajaController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensajeError = ''.obs;

  Future<bool> agregarTurnoCaja({
    required int idUsuario,
    required DateTime fechaInicio,
    required double montoInicial,
  }) async {
    try {
      estado.value = Estado.carga;

      final sql = Sql.named('''
    INSERT INTO turnos_caja (
      id_usuario,
      fecha_inicio,
      monto_inicial,
      activo
    ) VALUES (
      @id_usuario,
      @fecha_inicio,
      @monto_inicial,
      @activo
    ) RETURNING id
  ''');

      final resp = await Database.conn.execute(sql, parameters: {
        'id_usuario': idUsuario,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'monto_inicial': montoInicial,
        'activo': true,
      });

      estado.value = Estado.exito;
      SesionActiva().idTurnoCaja = int.parse(resp.first[0].toString());
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensajeError.value = 'Error al agregar turno de caja: $e';
      return false;
    }
  }

  Future<bool> cerrarTurno({
    required int idTurno,
    required double montoFinal,
  }) async {
    try {
      estado.value = Estado.carga;

      final sql = Sql.named('''
  UPDATE turnos_caja 
  SET monto_final = @monto_final,
      fecha_fin = @fecha_fin,
      activo = FALSE
  WHERE id = @id_turno
''');

      await Database.conn.execute(sql, parameters: {
        'monto_final': montoFinal,
        'fecha_fin': DateTime.now().toIso8601String(),
        'id_turno': idTurno,
      });

      estado.value = Estado.exito;
      return true;
    } catch (e) {
      print('Error al cerrar turno de caja: $e');
      estado.value = Estado.error;
      mensajeError.value = 'Error al cerrar turno de caja: $e';
      return false;
    }
  }
}
