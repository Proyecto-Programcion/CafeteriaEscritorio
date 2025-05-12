class Promocion {
  final int idPromocion;
  final String nombrePromocion;
  final String descripcion;
  final double porcentaje;
  final int comprasNecesarias;
  final double dineroNecesario;
  final double topeDescuento;
  final bool status;

  Promocion({
    required this.idPromocion,
    required this.nombrePromocion,
    required this.descripcion,
    required this.porcentaje,
    required this.comprasNecesarias,
    required this.dineroNecesario,
    required this.topeDescuento,
    required this.status,
  });

  factory Promocion.fromMap(Map<String, dynamic> map) {
    return Promocion(
      idPromocion: map['id_promocion'],
      nombrePromocion: map['nombrepromocion'],
      descripcion: map['descripcion'],
      porcentaje: (map['porcentaje'] as num?)?.toDouble() ?? 0.0,
      comprasNecesarias: map['comprasnecesarias'] ?? 0,
      dineroNecesario: (map['dineronecesario'] as num?)?.toDouble() ?? 0.0,
      topeDescuento: (map['topedescuento'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] == true || map['status'] == 1,
    );
  }
}