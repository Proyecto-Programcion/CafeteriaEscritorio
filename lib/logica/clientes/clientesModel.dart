class usuariMmodel {
  final int idCliente;
  final String nombre;
  final String numeroTelefono;
  final int cantidadCompras;

  const usuariMmodel({
    required this.idCliente,
    required this.nombre,
    required this.numeroTelefono,
    required this.cantidadCompras,
  });

  factory usuariMmodel.fromMap(Map<String, dynamic> map) {
    return usuariMmodel(
      idCliente: map['id_cliente'] is int
          ? map['id_cliente'] as int
          : int.tryParse(map['id_cliente']?.toString() ?? '') ?? 0,
      nombre: map['nombre'] as String? ?? '',
      numeroTelefono: map['numero_telefono'] as String? ?? '',
      cantidadCompras: map['cantidad_compras'] is int
          ? map['cantidad_compras'] as int
          : int.tryParse(map['cantidad_compras']?.toString() ?? '') ?? 0,
    );
  }
}
