
class CategoriaControlGastosModelo {
  final int idCategoria;
  final String nombre;
  final String? descripcion;

  CategoriaControlGastosModelo({
    required this.idCategoria,
    required this.nombre,
    this.descripcion,
  });

  factory CategoriaControlGastosModelo.fromMap(Map<String, dynamic> map) =>
      CategoriaControlGastosModelo(
        idCategoria: map['idCategoria'] as int,
        nombre: map['nombre'] as String,
        descripcion: map['descripcion'] as String?,
      );
}