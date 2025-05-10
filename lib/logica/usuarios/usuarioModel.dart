class usuariMmodel {
  final String nombre;
  final String numeroTelefono;

  const usuariMmodel({
    required this.nombre,
    required this.numeroTelefono,
  });

    factory usuariMmodel.fromMap(Map<String, dynamic> map) => usuariMmodel(
        nombre: map['nombre'] as String,
        numeroTelefono: map['numero_telefono'] as String,
      );
}