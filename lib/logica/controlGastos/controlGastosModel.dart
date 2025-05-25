class GastoModelo {
  final int idGasto;
  final int idCategoria;
  final String descripcion;
  final double monto;
  final DateTime fechaGasto;
  final String metodoPago;
  final String? notas;
  final String? ubicacion;
  final String nombreCategoria;

  GastoModelo({
    required this.idGasto,
    required this.idCategoria,
    required this.descripcion,
    required this.monto,
    required this.fechaGasto,
    required this.metodoPago,
    this.notas,
    this.ubicacion,
    required this.nombreCategoria,
  });

  factory GastoModelo.fromMap(Map<String, dynamic> map) {
    print("DEBUG map gasto: $map");
    print("DEBUG monto runtimeType: ${map['monto']?.runtimeType}");
    return GastoModelo(
      idGasto: map['idGasto'] is int
          ? map['idGasto'] as int
          : int.parse(map['idGasto'].toString()),
      idCategoria: map['idCategoria'] is int
          ? map['idCategoria'] as int
          : int.parse(map['idCategoria'].toString()),
      descripcion: map['descripcion'] as String,
      monto: (map['monto'] == null)
          ? 0.0
          : (map['monto'] is num
              ? (map['monto'] as num).toDouble()
              : double.tryParse(map['monto'].toString()) ?? 0.0),
      fechaGasto: map['fechaGasto'] is DateTime
          ? map['fechaGasto'] as DateTime
          : DateTime.parse(map['fechaGasto'].toString()),
      metodoPago: map['metodoPago'] as String,
      notas: map['notas'] as String?,
      ubicacion: map['ubicacion'] as String?,
      nombreCategoria: map['nombreCategoria'] as String,
    );
  }
}