import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/turnoCaja/turno_caja_modelo.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ObtenerTurnosCajaController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxList<TurnoCajaModelo> turnosCaja = <TurnoCajaModelo>[].obs;
  RxString mensajeError = ''.obs;

  Future<void> obtenerTurnosCaja() async {
    try {
      // Reiniciar el estado y la lista de turnos
      turnosCaja.clear();
      estado.value = Estado.carga;

      final sql = Sql.named('''
      SELECT 
        tc.id,
        tc.id_usuario,
        u.nombre AS nombre_usuario,
        tc.fecha_inicio,
        tc.fecha_fin,
        tc.monto_inicial,
        tc.monto_final,
        tc.activo,
        COALESCE(COUNT(v.id_venta), 0) AS total_ventas,
        COALESCE(SUM(v.precio_total), 0) AS total_ingresos,
        COALESCE(SUM(v.precio_descuento + v.descuento_aplicado), 0) AS total_descuentos_completos,
        COALESCE(SUM(v.precio_total) - SUM(v.precio_descuento + v.descuento_aplicado), 0) AS total_con_descuento
        FROM turnos_caja tc
        INNER JOIN usuarios u ON tc.id_usuario = u.id_usuario
        LEFT JOIN ventas v ON tc.id = v.id_turno_caja AND v.status_compra = TRUE
        GROUP BY 
            tc.id, 
            tc.id_usuario, 
            u.nombre, 
            tc.fecha_inicio, 
            tc.fecha_fin, 
            tc.monto_inicial, 
            tc.monto_final, 
            tc.activo
        ORDER BY tc.fecha_inicio DESC;
      ''');

      // Aquí deberías reemplazar con la lógica real para obtener los datos
      final resp = await Database.conn.execute(sql);
      resp
          .map((item) => {

            print(item),
                turnosCaja.add(TurnoCajaModelo(
                  idTurnoCaja: item[0] as int,
                  idUsuario: item[1] as int,
                  nombreUsuario: item[2].toString(),
                  fechaInicio: item[3].toString(),
                  fechaFin: item[4]?.toString(),
                  montoApertura: double.parse(item[5].toString()),
                   montoCierre: item[6] != null ? double.parse(item[6].toString()) : 0.0,
                  estado: item[7] as bool ? 'Activo' : 'Inactivo',
                  numeroVentas: int.parse(item[8].toString()) ,
                  totalVentas: double.parse(item[9].toString()),
                  descuentoAplicado: double.parse(item[10].toString()),
                  totalVentasConDescuento: double.parse(item[11].toString()),
                ))
              })
          .toList();

      estado.value = Estado.exito;
    } catch (e) {
      print('Error al obtener los turnos de caja: $e');
      mensajeError.value = 'Error al obtener los turnos de caja: $e';
      estado.value = Estado.error;
    }
  }
}
