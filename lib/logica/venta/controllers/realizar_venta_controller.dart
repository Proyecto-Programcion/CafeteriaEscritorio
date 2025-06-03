// En logica/venta/controllers/realizar_venta_controller.dart
import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';
import 'package:intl/intl.dart';

import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/productos/producto_modelos.dart';
import 'package:cafe/logica/promociones/promocionModel.dart';
import 'package:cafe/logica/promociones/promocion_producto_gratis_modelo.dart';
import 'package:get/get.dart';

class RealizarVentaController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;
  RxInt totalVentas = 0.obs;
  RxDouble ventaTotalMes = 0.0.obs;

  // Carrito de compras - Usamos RxList para que sea observable
  final RxList<ProductoCarrito> carrito = <ProductoCarrito>[].obs;

  // Valores calculados
  final Rx<double> totalVenta = 0.0.obs;
  final Rx<double> totalDescuento = 0.0.obs;

  @override
  void onInit() {
    // Este listener se ejecuta cada vez que el carrito cambia
    ever(carrito, (_) {
      calcularTotales();
    });
    super.onInit();
  }

  void cambiarEstadoAcarga() {
    estado.value = Estado.carga;
  }

  // Calcular totales del carrito
  void calcularTotales() {
    double total = 0.0;
    double descuento = 0.0;

    for (var item in carrito) {
      final precioBase = item.producto.precio * item.cantidad;
      final descuentoItem = (item.producto.descuento ?? 0) * item.cantidad;

      total += precioBase;
      descuento += descuentoItem;
    }

    totalVenta.value = total;
    totalDescuento.value = descuento;
  }

  // Añadir producto al carrito
  void agregarProducto(ProductoModelo producto, [int cantidad = 1]) {
    // Verificar si hay suficiente stock
    if (producto.cantidad < cantidad) {
      mensaje.value = 'No hay suficiente stock disponible';
      return;
    }

    // Buscar si el producto ya está en el carrito
    final index = carrito
        .indexWhere((item) => item.producto.idProducto == producto.idProducto);

    if (index >= 0) {
      // Si ya existe, aumentar la cantidad
      final nuevaCantidad = carrito[index].cantidad + cantidad;

      // Verificar si hay suficiente stock para la nueva cantidad
      if (producto.cantidad < nuevaCantidad) {
        mensaje.value = 'No hay suficiente stock disponible';
        return;
      }

      carrito[index].cantidad = nuevaCantidad;
    } else {
      // Si no existe, añadir al carrito
      carrito.add(ProductoCarrito(producto: producto, cantidad: cantidad));
    }

    calcularTotales();
  }

  // Remover producto del carrito
  void removerProducto(int idProducto) {
    carrito.removeWhere((item) => item.producto.idProducto == idProducto);
    calcularTotales();
  }

  // Actualizar cantidad de un producto en el carrito
  void actualizarCantidad(int idProducto, int nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      removerProducto(idProducto);
      return;
    }

    final index =
        carrito.indexWhere((item) => item.producto.idProducto == idProducto);

    if (index >= 0) {
      final producto = carrito[index].producto;

      // Verificar si hay suficiente stock
      if (producto.cantidad < nuevaCantidad) {
        mensaje.value = 'No hay suficiente stock disponible';
        return;
      }

      carrito[index].cantidad = nuevaCantidad;
      calcularTotales();
    }
  }

  // Vaciar carrito
  void vaciarCarrito() {
    carrito.clear();
    calcularTotales();
  }

  // Sincronizar con carrito externo (para integrar con VentaScreen)
  void sincronizarCarrito(List<ProductoCarrito> carritoExterno) {
    carrito.clear();
    carrito.addAll(carritoExterno);
    calcularTotales();
  }

  // Realizar la venta
  Future<bool> realizarVenta({
    int? idCliente,
    int? idPromocion,
    int? idPromocionProductosGratis,
    PromocionProductoGratiConNombreDelProductosModelo? promocionProductoGratis,
    double? descuentoPromocionAplicado, 
  }) async {
    try {
      estado.value = Estado.carga;

      if (carrito.isEmpty) {
        mensaje.value = 'El carrito está vacío';
        estado.value = Estado.error;
        return false;
      }

      // Obtener fecha actual formateada
      final fecha = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final precioTotal = totalVenta.value;
      final precioDescuentoProductos =
          totalDescuento.value; // Descuento de productos individuales
      final descuentoPromocion =
          descuentoPromocionAplicado ?? 0.0; // Descuento de promoción
      final precioDescuentoTotal =
          totalVenta.value - (precioDescuentoProductos + descuentoPromocion);

      // 1. Crear la venta en la base de datos
      final sqlVenta = Sql.named('''
        INSERT INTO ventas (
          id_usuario,
          id_cliente,
          id_promocion,
          id_sucursal,
          id_turno_caja,
          id_promocion_productos_gratis,
          precio_total,
          precio_descuento,
          descuento_aplicado,
          fecha,
          status_compra
        ) VALUES (
          @id_usuario,
          @id_cliente,
          @id_promocion,
          @id_sucursal,
          @id_turno_caja,
          @id_promocion_productos_gratis,
          @precio_total,
          @precio_descuento,
          @descuento_aplicado,
          @fecha,
          @status_compra
        ) RETURNING id_venta;
      ''');

      final result = await Database.conn.execute(sqlVenta, parameters: {
        'id_usuario': SesionActiva().idUsuario,
        'id_cliente': idCliente,
        'id_promocion': idPromocion,
        'id_sucursal': SesionActiva().idSucursal,
        'id_turno_caja': SesionActiva().idTurnoCaja,
        'id_promocion_productos_gratis': idPromocionProductosGratis,
        'precio_total': precioTotal,
        'precio_descuento': precioDescuentoProductos,
        'descuento_aplicado': descuentoPromocion,
        'fecha': fecha,
        'status_compra': true,
      });

      // Obtener el ID de la venta creada
      final sqlGetId = Sql.named('''
        SELECT lastval() as id_venta;
      ''');

      final idResult = await Database.conn.execute(sqlGetId);
      final idVenta = idResult.first[0] as int;

      // 2. Crear tabla si no existe
      final sqlCrearTabla = '''
        CREATE TABLE IF NOT EXISTS detalle_ventas (
          id_detalle SERIAL PRIMARY KEY,
          id_venta INT,
          id_producto INT,
          cantidad DOUBLE PRECISION,
          precio_unitario DOUBLE PRECISION,
          descuento_unitario DOUBLE PRECISION
        );
      ''';

      await Database.conn.execute(sqlCrearTabla);

      // 3. Guardar los detalles de la venta y actualizar el inventario
      for (var item in carrito) {
        final producto = item.producto;
        final cantidad = item.cantidad;

        // Insertar detalle
        final sqlDetalle = Sql.named('''
          INSERT INTO detalle_ventas (
            id_venta,
            id_producto,
            cantidad,
            precio_unitario,
            descuento_unitario
          ) VALUES (
            @id_venta,
            @id_producto,
            @cantidad,
            @precio_unitario,
            @descuento_unitario
          );
        ''');

        await Database.conn.execute(sqlDetalle, parameters: {
          'id_venta': idVenta,
          'id_producto': producto.idProducto,
          'cantidad': cantidad,
          'precio_unitario': producto.precio,
          'descuento_unitario': producto.descuento ?? 0,
        });

        // Actualizar inventario
        final sqlInventario = Sql.named('''
          UPDATE productos 
          SET cantidad = cantidad - @cantidad_vendida 
          WHERE id_producto = @id_producto;
        ''');

        await Database.conn.execute(sqlInventario, parameters: {
          'cantidad_vendida': cantidad,
          'id_producto': producto.idProducto,
        });

        //Registrar movimientos de stock en controlStock
        final sqlControlStock = Sql.named('''
        INSERT INTO controlStock (id_producto, cantidad_antes, cantidad_movimiento, cantidad_despues, unidad_medida, categoria, id_usuario) 
        VALUES (
          @idProducto, 
          @cantidad_antes,
          @cantidad_movimiento, 
          @cantidad_despues,
          (SELECT unidad_medida FROM productos WHERE id_producto = @idProducto),
          @categoria,
          @idUsuario
        );
        ''');

         await Database.conn.execute(sqlControlStock, parameters: {
          'idProducto': producto.idProducto,
          'cantidad_antes': producto.cantidad,
          'cantidad_movimiento': cantidad,
          'cantidad_despues': producto.cantidad - cantidad,
          'categoria': 'vendido',
          'idUsuario': SesionActiva().idUsuario,
        });
      }

      // 4. **NUEVO**: Agregar el producto gratis a los detalles si existe
      if (promocionProductoGratis != null) {
        print(
            '🎁 Agregando producto gratis: ${promocionProductoGratis.nombreProducto}');

        final sqlProductoGratis = Sql.named('''
          INSERT INTO detalle_ventas (
            id_venta,
            id_producto,
            cantidad,
            precio_unitario,
            descuento_unitario
          ) VALUES (
            @id_venta,
            @id_producto,
            @cantidad,
            @precio_unitario,
            @descuento_unitario
          );
        ''');

        await Database.conn.execute(sqlProductoGratis, parameters: {
          'id_venta': idVenta,
          'id_producto': promocionProductoGratis.idProducto,
          'cantidad': promocionProductoGratis.cantidadProducto,
          'precio_unitario': 0.0, // Precio 0 porque es gratis
          'descuento_unitario': 0.0, // Sin descuento adicional
        });

        // También actualizar el inventario del producto gratis
        final sqlInventarioGratis = Sql.named('''
          UPDATE productos 
          SET cantidad = cantidad - @cantidad_vendida 
          WHERE id_producto = @id_producto;
        ''');

        await Database.conn.execute(sqlInventarioGratis, parameters: {
          'cantidad_vendida': promocionProductoGratis.cantidadProducto,
          'id_producto': promocionProductoGratis.idProducto,
        });

        print('✅ Producto gratis agregado correctamente a los detalles');
      }

      // Actualizar la lista de productos después de la venta
      final obtenerProductosController =
          Get.find<ObtenerProductosControllers>();
      await obtenerProductosController.obtenerProductos();

      // Vaciar el carrito después de completar la venta
      vaciarCarrito();

      estado.value = Estado.exito;
      mensaje.value = 'Venta realizada con éxito';
      return true;
    } catch (e) {
      print('Error al realizar la venta: $e');
      mensaje.value = 'Error al realizar la venta: $e';
      estado.value = Estado.error;
      return false;
    }
  }

  Future<void> obtenerTotalVentas() async {
    try {
      final sql = Sql.named('''
        SELECT COUNT(*) AS total_ventas
          FROM ventas
          WHERE status_compra = TRUE;
      ''');
      final resp = await Database.conn.execute(sql);
      if (resp.isNotEmpty) {
        totalVentas.value = resp.first[0] as int;
      } else {
        totalVentas.value = 0;
      }
    } catch (e) {
      print('Error al obtener el total de ventas: $e');
      totalVentas.value = 0;
    }
  }

  Future<void> obtenerIngresoTotalDelMes() async {
    try {
      final sql = Sql.named('''
  SELECT COALESCE(SUM(precio_total), 0) AS ingreso_total
  FROM ventas
  WHERE status_compra = TRUE;
''');

      final resp = await Database.conn.execute(sql);

      final ingresoRaw = resp.first[0];

      if (ingresoRaw is num) {
        ventaTotalMes.value = ingresoRaw.toDouble();
      } else if (ingresoRaw is String) {
        ventaTotalMes.value =
            double.tryParse(ingresoRaw.replaceAll(',', '')) ?? 0.0;
      } else {
        ventaTotalMes.value = 0.0;
      }
    } catch (e) {
      print('❌ Error al obtener ingreso del mes: $e');
      ventaTotalMes.value = 0.0;
    }
  }
}
