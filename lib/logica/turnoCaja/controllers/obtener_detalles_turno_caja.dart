import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/turnoCaja/venta_turno_modelo.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ObtenerDetallesTurnoCajaController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxList<VentaTurnoModel> ventasTurnocaja = <VentaTurnoModel>[].obs;
  RxString mensajeError = ''.obs;

  Future<void> obtenerVentasPorTurno(int idTurnoCaja) async {
    try {
      // Reiniciar el estado y la lista de ventas
      ventasTurnocaja.clear();
      mensajeError.value = '';
      estado.value = Estado.carga;
      final sql = Sql.named('''
        SELECT 
            v.id_venta, 
            v.id_promocion, 	
            v.id_promocion_productos_gratis, 
            v.precio_total, 
            v.precio_descuento, 
            v.fecha, 
            v.status_compra, 
            v.descuento_aplicado,
            
            -- Datos de promoción de descuento
            pd.nombrepromocion AS promocion_descuento_nombre,
            pd.porcentaje AS promocion_descuento_porcentaje,
            
            -- Datos de promoción de producto gratis
            ppg.nombre_promocion AS promocion_gratis_nombre,
            ppg.id_producto AS promocion_gratis_id_producto,
            p.nombre AS promocion_gratis_nombre_producto,
            ppg.cantidad_producto AS promocion_gratis_cantidad
            
        FROM ventas v 
        LEFT JOIN promocion pd ON v.id_promocion = pd.id_promocion
        LEFT JOIN promocion_producto_gratis ppg ON v.id_promocion_productos_gratis = ppg.id_promocion_productos_gratis
        LEFT JOIN productos p ON ppg.id_producto = p.id_producto
        WHERE v.id_turno_caja = @idTurnoCaja
        ORDER BY v.fecha DESC;
      ''');

      final resp = await Database.conn.execute(sql, parameters: {
        'idTurnoCaja': idTurnoCaja,
      });

      final ventas = resp
          .map((row) => {
                'id_venta': row[0],
                'id_promocion': row[1],
                'id_promocion_productos_gratis': row[2],
                'precio_total': row[3],
                'precio_descuento': row[4],
                'fecha': row[5],
                'status_compra': row[6],
                'descuento_aplicado': row[7],
                'promocion_descuento_nombre': row[8],
                'promocion_descuento_porcentaje': row[9],
                'promocion_gratis_nombre': row[10],
                'promocion_gratis_id_producto': row[11],
                'promocion_gratis_nombre_producto': row[12],
                'promocion_gratis_cantidad': row[13],
              })
          .map((map) => VentaTurnoModel.fromMap(map))
          .toList();

      ventasTurnocaja.value = ventas;
      estado.value = Estado.exito;
    } catch (e) {
      print('Error al obtener ventas por turno: $e');
      mensajeError.value = 'Error al obtener ventas por turno: $e';
      estado.value = Estado.error;
      ventasTurnocaja.clear();
    }
  }
}
