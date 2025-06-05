class VentaModeloListar {
  final int idVenta;
  final int? idPromocion;
  final int? idPromocionProductosGratis;
  final double precioTotal;
  final double precioDescuento;
  final DateTime fecha;
  final bool statusCompra;
  final double? descuentoAplicado;
  final String? nombreUsuario; // NUEVO CAMPO
  final String? promocionDescuentoNombre;
  final double? promocionDescuentoPorcentaje;
  final String? promocionGratisNombre;
  final int? promocionGratisIdProducto;
  final String? promocionGratisNombreProducto;
  final int? promocionGratisCantidad;

  VentaModeloListar({
    required this.idVenta,
    this.idPromocion,
    this.idPromocionProductosGratis,
    required this.precioTotal,
    required this.precioDescuento,
    required this.fecha,
    required this.statusCompra,
    this.descuentoAplicado,
    this.nombreUsuario, // NUEVO CAMPO
    this.promocionDescuentoNombre,
    this.promocionDescuentoPorcentaje,
    this.promocionGratisNombre,
    this.promocionGratisIdProducto,
    this.promocionGratisNombreProducto,
    this.promocionGratisCantidad,
  });

  factory VentaModeloListar.fromMap(Map<String, dynamic> map) {
    return VentaModeloListar(
      idVenta: _toInt(map['id_venta']),
      idPromocion: _toIntNullable(map['id_promocion']),
      idPromocionProductosGratis: _toIntNullable(map['id_promocion_productos_gratis']),
      precioTotal: _toDouble(map['precio_total']),
      precioDescuento: _toDouble(map['precio_descuento']),
      fecha: DateTime.parse(map['fecha'].toString()),
      statusCompra: map['status_compra'] as bool,
      descuentoAplicado: _toDoubleNullable(map['descuento_aplicado']),
      nombreUsuario: map['nombre_usuario'] as String?, // NUEVO CAMPO
      promocionDescuentoNombre: map['promocion_descuento_nombre'] as String?,
      promocionDescuentoPorcentaje: _toDoubleNullable(map['promocion_descuento_porcentaje']),
      promocionGratisNombre: map['promocion_gratis_nombre'] as String?,
      promocionGratisIdProducto: _toIntNullable(map['promocion_gratis_id_producto']),
      promocionGratisNombreProducto: map['promocion_gratis_nombre_producto'] as String?,
      promocionGratisCantidad: _toIntNullable(map['promocion_gratis_cantidad']),
    );
  }

  // Métodos auxiliares para conversión de tipos
  static int _toInt(dynamic value) {
    if (value == null) throw ArgumentError('Value cannot be null for required int');
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.parse(value);
    throw ArgumentError('Cannot convert $value to int');
  }

  static int? _toIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double _toDouble(dynamic value) {
    if (value == null) throw ArgumentError('Value cannot be null for required double');
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    throw ArgumentError('Cannot convert $value to double');
  }

  static double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id_venta': idVenta,
      'id_promocion': idPromocion,
      'id_promocion_productos_gratis': idPromocionProductosGratis,
      'precio_total': precioTotal,
      'precio_descuento': precioDescuento,
      'fecha': fecha.toIso8601String(),
      'status_compra': statusCompra,
      'descuento_aplicado': descuentoAplicado,
      'nombre_usuario': nombreUsuario, // NUEVO CAMPO
      'promocion_descuento_nombre': promocionDescuentoNombre,
      'promocion_descuento_porcentaje': promocionDescuentoPorcentaje,
      'promocion_gratis_nombre': promocionGratisNombre,
      'promocion_gratis_id_producto': promocionGratisIdProducto,
      'promocion_gratis_nombre_producto': promocionGratisNombreProducto,
      'promocion_gratis_cantidad': promocionGratisCantidad,
    };
  }

  @override
  String toString() {
    return 'VentaTurnoModel(idVenta: $idVenta, precioTotal: $precioTotal, statusCompra: $statusCompra)';
  }
}