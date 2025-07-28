import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class EvaluarSiHayCajaAbiertaController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensajeError = ''.obs;

  Future<bool> evaluarSiHayCajaAbierta({required int idUsuario}) async {
    try {
      estado.value = Estado.carga;

      final sql = Sql.named('''
  SELECT * FROM turnos_caja 
  WHERE fecha_fin IS NULL
  AND id_usuario = @idUsuario
  ORDER BY id DESC 
  LIMIT 1;
''');

      final resp = await Database.conn.execute(sql, parameters: {
        'idUsuario': idUsuario, // <-- Debe coincidir con @idUsuario
      });

      final existeCajaAbierta = resp.isNotEmpty && resp.first[6] as bool;

      if (!existeCajaAbierta) {
        estado.value = Estado.error;
        mensajeError.value = 'No hay caja abierta';
        return false;
      }

      // SI EXISTE CAJA ABIERTA, OBTENER USUARIO PARA DARLE VALORES A SESION_ACTIVA
      final sesionSql = Sql.named('''
      SELECT * FROM usuarios WHERE id_usuario = @idUser;
      ''');

      final sesionResp = await Database.conn.execute(sesionSql, parameters: {
        'idUser': idUsuario,
      });

      SesionActiva().idUsuario = sesionResp.first[0] as int;
      SesionActiva().nombreUsuario = sesionResp.first[1] as String;
      SesionActiva().rolUsuario = sesionResp.first[8] as String;
      SesionActiva().idTurnoCaja = resp.first[0] as int;

      estado.value = Estado.exito;
      return true;
    } catch (e) {
      print('Error al evaluar si hay caja abierta: $e');
      estado.value = Estado.error;
      mensajeError.value = 'Error al evaluar si hay caja abierta: $e';
      return false;
    }
  }
}
