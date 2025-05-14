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
    final index = carrito.indexWhere((item) => item.producto.idProducto == producto.idProducto);
    
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
    
    final index = carrito.indexWhere((item) => item.producto.idProducto == idProducto);
    
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
      final precioDescuento = totalDescuento.value;
      
      // 1. Crear la venta en la base de datos
      final sqlVenta = Sql.named('''
        INSERT INTO ventas (
          id_usuario,
          id_cliente,
          id_promocion,
          id_promocion_productos_gratis,
          precio_total,
          precio_descuento,
          fecha,
          status_compra
        ) VALUES (
          @id_usuario,
          @id_cliente,
          @id_promocion,
          @id_promocion_productos_gratis,
          @precio_total,
          @precio_descuento,
          @fecha,
          @status_compra
        ) RETURNING id_venta;
      ''');
      
      final result = await Database.conn.execute(
        sqlVenta, 
        parameters: {
          'id_usuario': SesionActiva().idUsuario,
          'id_cliente': idCliente,
          'id_promocion': idPromocion,
          'id_promocion_productos_gratis': idPromocionProductosGratis,
          'precio_total': precioTotal,
          'precio_descuento': precioDescuento,
          'fecha': fecha,
          'status_compra': true,
        }
      );
      
      // Obtener el ID de la venta creada usando la misma conexión
      final sqlGetId = Sql.named('''
        SELECT lastval() as id_venta;
      ''');
      
      final idResult = await Database.conn.execute(sqlGetId);
      final idVenta = idResult.first[0] as int;
      
      // 2. Crear una tabla detalle_ventas si no existe
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
        
        await Database.conn.execute(
          sqlDetalle,
          parameters: {
            'id_venta': idVenta,
            'id_producto': producto.idProducto,
            'cantidad': cantidad,
            'precio_unitario': producto.precio,
            'descuento_unitario': producto.descuento ?? 0,
          }
        );
        
        // Actualizar inventario
        final sqlInventario = Sql.named('''
          UPDATE productos 
          SET cantidad = cantidad - @cantidad_vendida 
          WHERE id_producto = @id_producto;
        ''');
        
        await Database.conn.execute(
          sqlInventario,
          parameters: {
            'cantidad_vendida': cantidad,
            'id_producto': producto.idProducto,
          }
        );
      }
      
      // Actualizar la lista de productos después de la venta
      final obtenerProductosController = Get.find<ObtenerProductosControllers>();
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
}

class PromocionesVentaController extends GetxController {
  // Estado de las promociones seleccionadas
  Rx<Promocion?> promocionDescuentoSeleccionada = Rx<Promocion?>(null);
  Rx<PromocionProductoGratiConNombreDelProductosModelo?> promocionProductoGratisSeleccionada = 
      Rx<PromocionProductoGratiConNombreDelProductosModelo?>(null);
  
  // Lista filtrada de promociones aplicables (basada en productos en carrito)
  RxList<Promocion> promocionesDescuentoAplicables = <Promocion>[].obs;
  RxList<PromocionProductoGratiConNombreDelProductosModelo> promocionesProductosGratisAplicables = 
      <PromocionProductoGratiConNombreDelProductosModelo>[].obs;
  
  // Total de descuentos aplicados
  RxDouble descuentoAplicado = 0.0.obs;
  RxBool productosGratisAplicados = false.obs;
  
  // Valores de la venta para validar promociones
  RxDouble totalVenta = 0.0.obs;
  RxInt totalProductos = 0.obs;
  
  // Método para filtrar promociones según el carrito actual
  void filtrarPromocionesAplicables(
    List<ProductoCarrito> carrito,
    List<Promocion> todasLasPromocionesDescuento,
    List<PromocionProductoGratiConNombreDelProductosModelo> todasLasPromocionesProductosGratis
  ) {
    // Resetear selecciones previas
    promocionDescuentoSeleccionada.value = null;
    promocionProductoGratisSeleccionada.value = null;
    descuentoAplicado.value = 0.0;
    productosGratisAplicados.value = false;
    
    // Calcular totales para validación de promociones
    totalVenta.value = carrito.fold<double>(
      0,
      (suma, item) => suma + ((item.producto.precio ?? 0) - (item.producto.descuento ?? 0)) * item.cantidad,
    );
    
    totalProductos.value = carrito.fold<int>(
      0,
      (suma, item) => suma + item.cantidad,
    );
    
    // Filtrar promociones de descuento aplicables
    promocionesDescuentoAplicables.value = todasLasPromocionesDescuento.where((promo) {
      // Verificar si la promoción está activa
      if (!promo.status) return false;
      
      // Verificar requisitos de dinero mínimo
      if (promo.dineroNecesario > 0 && totalVenta.value < promo.dineroNecesario) {
        return false;
      }
      
      // Verificar requisitos de compras necesarias
      if (promo.comprasNecesarias > 0 && totalProductos.value < promo.comprasNecesarias) {
        return false;
      }
      
      return true;
    }).toList();
    
    // Filtrar promociones de productos gratis aplicables
    promocionesProductosGratisAplicables.value = todasLasPromocionesProductosGratis.where((promo) {
      // Verificar si la promoción está activa
      if (!promo.status) return false;
      
      // Verificar requisitos de dinero mínimo
      if (promo.dineroNecesario > 0 && totalVenta.value < promo.dineroNecesario) {
        return false;
      }
      
      // Verificar requisitos de compras necesarias
      if (promo.comprasNecesarias > 0 && totalProductos.value < promo.comprasNecesarias) {
        return false;
      }
      
      // Verificar si el producto gratis está en el carrito
      bool productoEnCarrito = carrito.any((item) => 
        item.producto.idProducto == promo.idProducto);
        
      // Dependiendo de la lógica de negocio, puedes decidir si el producto debe estar o no en el carrito
      // Por ahora, asumo que el producto debe estar en el carrito para aplicar la promoción
      return productoEnCarrito;
    }).toList();
  }
  
  // Seleccionar una promoción de descuento
  void seleccionarPromocionDescuento(Promocion? promocion) {
    if (promocion == null) {
      promocionDescuentoSeleccionada.value = null;
      descuentoAplicado.value = 0.0;
      return;
    }
    
    promocionDescuentoSeleccionada.value = promocion;
    
    // Calcular el descuento aplicado
    double descuento = totalVenta.value * (promocion.porcentaje / 100);
    
    // Aplicar tope de descuento si existe
    if (promocion.topeDescuento > 0 && descuento > promocion.topeDescuento) {
      descuento = promocion.topeDescuento;
    }
    
    descuentoAplicado.value = descuento;
  }
  
  // Seleccionar una promoción de producto gratis
  void seleccionarPromocionProductoGratis(PromocionProductoGratiConNombreDelProductosModelo? promocion) {
    promocionProductoGratisSeleccionada.value = promocion;
    productosGratisAplicados.value = promocion != null;
  }
  
  // Obtener datos para aplicar en la venta
  Map<String, dynamic> obtenerDatosPromocionesPorAplicar() {
    return {
      'promocionDescuento': promocionDescuentoSeleccionada.value?.idPromocion,
      'descuentoAplicado': descuentoAplicado.value,
      'promocionProductoGratis': promocionProductoGratisSeleccionada.value?.idPromocionProductoGratis,
      'productoGratisAplicado': productosGratisAplicados.value,
      'productoGratisId': promocionProductoGratisSeleccionada.value?.idProducto,
      'cantidadProductoGratis': promocionProductoGratisSeleccionada.value?.cantidadProducto,
    };
  }
  
  // Limpiar selecciones
  void limpiarSelecciones() {
    promocionDescuentoSeleccionada.value = null;
    promocionProductoGratisSeleccionada.value = null;
    descuentoAplicado.value = 0.0;
    productosGratisAplicados.value = false;
  }
}