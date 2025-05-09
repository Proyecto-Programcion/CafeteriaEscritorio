class CategoriaModelo {
  final int idCategoria;
  final int idUsuario;
  final String nombre;
  final String? descripcion;

  CategoriaModelo(
      {required this.idCategoria,
      required this.idUsuario,
      required this.nombre,
      required this.descripcion});
}
