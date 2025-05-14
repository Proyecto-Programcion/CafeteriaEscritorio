// En venta_modelo.dart
class VentaModelo {
  final int? idVenta;
  final int? idUsuario;
  final int? idCliente;
  final int? idPromocion;
  final int? idPromocionProductosGratis;
  final double precioTotal;
  final double precioDescuento;
  final String fecha;
  final bool statusCompra;
  
  // Lista de productos en la venta (esto no está en tu tabla pero será útil)
  final List<ProductoVenta>? detalles;

  VentaModelo({
    this.idVenta,
    this.idUsuario,
    this.idCliente,
    this.idPromocion,
    this.idPromocionProductosGratis,
    required this.precioTotal,
    required this.precioDescuento,
    required this.fecha,
    required this.statusCompra,
    this.detalles,
  });

  factory VentaModelo.fromMap(Map<String, dynamic> map) => VentaModelo(
    idVenta: map['id_venta'] as int,
    idUsuario: map['id_usuario'] as int?,
    idCliente: map['id_cliente'] as int?,
    idPromocion: map['id_promocion'] as int?,
    idPromocionProductosGratis: map['id_promocion_productos_gratis'] as int?,
    precioTotal: map['precio_total'] as double,
    precioDescuento: map['precio_descuento'] as double,
    fecha: map['fecha'] as String,
    statusCompra: map['status_compra'] as bool,
  );

  Map<String, dynamic> toMap() => {
    'id_venta': idVenta,
    'id_usuario': idUsuario,
    'id_cliente': idCliente,
    'id_promocion': idPromocion,
    'id_promocion_productos_gratis': idPromocionProductosGratis,
    'precio_total': precioTotal,
    'precio_descuento': precioDescuento,
    'fecha': fecha,
    'status_compra': statusCompra,
  };
}

// Modelo para detalles de venta (productos en la venta)
class ProductoVenta {
  final int idProducto;
  final double cantidad;
  final double precioUnitario;
  final double descuentoUnitario;
  
  ProductoVenta({
    required this.idProducto,
    required this.cantidad, 
    required this.precioUnitario,
    required this.descuentoUnitario,
  });
  
  double get subtotal => (precioUnitario - descuentoUnitario) * cantidad;
  
  Map<String, dynamic> toMap() => {
    'id_producto': idProducto,
    'cantidad': cantidad,
    'precio_unitario': precioUnitario,
    'descuento_unitario': descuentoUnitario,
  };
}