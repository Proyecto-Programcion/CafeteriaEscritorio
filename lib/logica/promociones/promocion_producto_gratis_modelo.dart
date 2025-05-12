class PromocionProductoGratisModelo {
  int idPromocionProductoGratis;
  String nombrePromocion;
  String descripcion;
  int idProducto;
  int comprasNecesarias;
  double dineroNecesario;
  bool status;
  double cantidadProducto;

  PromocionProductoGratisModelo({
    required this.idPromocionProductoGratis,
    required this.nombrePromocion,
    required this.descripcion,
    required this.idProducto,
    required this.comprasNecesarias,
    required this.dineroNecesario,
    required this.status,
    required this.cantidadProducto,
  });

  factory PromocionProductoGratisModelo.fromMap(Map<String, dynamic> map) {
    return PromocionProductoGratisModelo(
      idPromocionProductoGratis: map['id_promocion_productos_gratis'], // plural
      nombrePromocion: map['nombre_promocion']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      idProducto: map['id_producto'] ?? 0,
      comprasNecesarias: map['compras_necesarias'] ?? 0,
      dineroNecesario: (map['dinero_necesario'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] == true || map['status'] == 1,
      cantidadProducto: (map['cantidad_producto'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PromocionProductoGratiConNombreDelProductosModelo {
  int idPromocionProductoGratis;
  String nombrePromocion;
  String descripcion;
  int idProducto;
  String nombreProducto;
  String unidadDeMedidaProducto;
  int comprasNecesarias;
  double dineroNecesario;
  bool status;
  double cantidadProducto;
  

  PromocionProductoGratiConNombreDelProductosModelo({
    required this.idPromocionProductoGratis,
    required this.nombrePromocion,
    required this.descripcion,
    required this.idProducto,
    required this.nombreProducto,
    required this.unidadDeMedidaProducto,
    required this.comprasNecesarias,
    required this.dineroNecesario,
    required this.status,
    required this.cantidadProducto,
  });

  factory PromocionProductoGratiConNombreDelProductosModelo.fromMap(
      Map<String, dynamic> map) {
    return PromocionProductoGratiConNombreDelProductosModelo(
      idPromocionProductoGratis: map['id_promocion_productos_gratis'], // plural
      nombrePromocion: map['nombre_promocion']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      idProducto: map['id_producto'] ?? 0,
      nombreProducto: map['nombre_producto']?.toString() ?? '',
      unidadDeMedidaProducto: map['unidad_de_medida_producto']?.toString() ?? '',
      comprasNecesarias: map['compras_necesarias'] ?? 0,
      dineroNecesario: (map['dinero_necesario'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] == true || map['status'] == 1,
      cantidadProducto: (map['cantidad_producto'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
