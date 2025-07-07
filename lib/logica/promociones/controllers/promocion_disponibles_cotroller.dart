import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/promociones/promocionModel.dart';
import 'package:cafe/logica/promociones/promocion_producto_gratis_modelo.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class PromocionesDisponiblesController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  RxString mensaje = ''.obs;

  /// Retorna un mapa con dos listas: 'descuento' y 'productos_gratis'
  Future<Map<String, List>> obtenerPromocionesDisponibles({
    required int idCliente,
    required double totalVenta,
    required int cantidadComprasUsuario,
    required List<int> idsProductosCarrito,
  }) async {
    try {
      estado.value = Estado.carga;

      // 1. Promociones de descuento
      final sqlPromosDescuento = Sql.named('''
        SELECT p.*
        FROM promocion p
        LEFT JOIN clientes_promociones_canjeadas cpc
          ON cpc.id_cliente = @id_cliente
          AND cpc.id_promocion = p.id_promocion
        WHERE p.status = TRUE
          AND p.eliminado = FALSE
          AND p.dineronecesario <= @total_venta
          AND p.comprasnecesarias <= @cantidad_compras_usuario
          AND cpc.id IS NULL
        ORDER BY p.id_promocion DESC
      ''');

      final respDescuento = await Database.conn.execute(
        sqlPromosDescuento,
        parameters: {
          'id_cliente': idCliente,
          'total_venta': totalVenta,
          'cantidad_compras_usuario': cantidadComprasUsuario,
        },
      );

      final columnsDescuento =
          respDescuento.schema?.columns.map((c) => c).toList() ?? [];
      final promocionesDescuento = respDescuento.map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < columnsDescuento.length; i++) {
          map[columnsDescuento[i].columnName ?? ''] = row[i];
        }
        return Promocion.fromMap(map);
      }).toList();

      // 2. Promociones de productos gratis
      final sqlPromosGratis = Sql.named('''
        SELECT ppg.*, productos.nombre AS nombre_producto, productos.unidad_medida AS unidad_de_medida_producto
        FROM promocion_producto_gratis ppg
        LEFT JOIN clientes_promociones_productos_gratis_canjeadas cpgc
          ON cpgc.id_cliente = @id_cliente
          AND cpgc.id_promocion_productos_gratis = ppg.id_promocion_productos_gratis
        LEFT JOIN productos ON ppg.id_producto = productos.id_producto
        WHERE ppg.status = TRUE
          AND ppg.eliminado = FALSE
          AND ppg.dinero_necesario <= @total_venta
          AND ppg.compras_necesarias <= @cantidad_compras_usuario
          AND ppg.id_producto = ANY(@ids_productos_carrito)
          AND cpgc.id IS NULL
        ORDER BY ppg.id_promocion_productos_gratis DESC
      ''');

      final respGratis = await Database.conn.execute(
        sqlPromosGratis,
        parameters: {
          'id_cliente': idCliente,
          'total_venta': totalVenta,
          'cantidad_compras_usuario': cantidadComprasUsuario,
          'ids_productos_carrito': idsProductosCarrito,
        },
      );

      final columnsGratis =
          respGratis.schema?.columns.map((c) => c).toList() ?? [];
      final promocionesProductosGratis = respGratis.map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < columnsGratis.length; i++) {
          map[columnsGratis[i].columnName ?? ''] = row[i];
        }
        return PromocionProductoGratiConNombreDelProductosModelo.fromMap(map);
      }).toList();

      estado.value = Estado.exito;
      return {
        'descuento': promocionesDescuento,
        'productos_gratis': promocionesProductosGratis,
      };
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al obtener promociones disponibles: $e';
      return {
        'descuento': <Promocion>[],
        'productos_gratis':
            <PromocionProductoGratiConNombreDelProductosModelo>[],
      };
    }
  }
}
