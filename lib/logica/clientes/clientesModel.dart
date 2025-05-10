class usuariMmodel {
  final int idCliente;
  final String nombre;
  final String numeroTelefono;

  const usuariMmodel({
    required this.idCliente,
    required this.nombre,
    required this.numeroTelefono,
  });

factory usuariMmodel.fromMap(Map<String, dynamic> map) {
  return usuariMmodel(
    idCliente: map['id_cliente'] is int
        ? map['id_cliente'] as int
        : int.tryParse(map['id_cliente']?.toString() ?? '') ?? 0,
    nombre: map['nombre'] as String? ?? '',
    numeroTelefono: map['numero_telefono'] as String? ?? '',
  );
}
}