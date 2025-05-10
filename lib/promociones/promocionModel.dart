class Promocion {
  final int idPromocion;
  final String nombrePromocion;
  final String descripcion;
  final int porcentaje;
  final int comprasNecesarias;
  final bool status;

  Promocion({
    required this.idPromocion,
    required this.nombrePromocion,
    required this.descripcion,
    required this.porcentaje,
    required this.comprasNecesarias,
    required this.status,
  });

  factory Promocion.fromMap(Map<String, dynamic> map) {
    return Promocion(
      idPromocion: map['id_promocion'] as int,
      nombrePromocion: map['nombrePromocion'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      porcentaje: map['porcentaje'] as int? ?? 0,
      comprasNecesarias: map['comprasNecesarias'] as int? ?? 0,
      status: map['status'] == true || map['status'] == 1,
    );
  }
}