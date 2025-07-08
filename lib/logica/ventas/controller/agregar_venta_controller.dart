import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AgregarVentaController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> agregarVenta(
    List<ProductoCarrito> carrito,
    double total,
    double descuento,
  ) async {
    try {
      estado.value = Estado.carga;

      // 1. Insertar la venta principal
      final ventaResult = await Database.conn.execute(
        'INSERT INTO ventas (id_usuario, id_cliente, precio_total, precio_descuento, fecha, status_compra) VALUES (@usuario, @cliente, @total, @descuento, @fecha, @status) RETURNING id_venta;',
        parameters: {
          'usuario': SesionActiva().idUsuario,
          'cliente': 1,
          'total': total,
          'descuento': descuento,
          'fecha': DateTime.now().toIso8601String(),
          'status': true,
        },
      );
      final idVenta = ventaResult.first[0]; // El id generado

// 2. Insertar cada producto vendido
      for (final item in carrito) {
        await Database.conn.execute(
          'INSERT INTO detallesventa (id_venta, id_producto, precio, cantidad, precio_total, precio_descuento) VALUES (@id_venta, @id_producto, @precio, @cantidad, @precio_total, @precio_descuento);',
          parameters: {
            'id_venta': idVenta,
            'id_producto': item.producto.idProducto,
            'precio': item.precioFinal, // Usar precio con mayoreo si aplica
            'cantidad': item.cantidad,
            'precio_total': item.totalConMayoreo,
            'precio_descuento': item.totalConMayoreo - ((item.producto.descuento ?? 0) * item.cantidad),
          },
        );
      }

      estado.value = Estado.exito;
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al agregar la venta: $e';
      return false;
    }
  }
}
