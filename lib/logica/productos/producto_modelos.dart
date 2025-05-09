// En producto_modelos.dart
class ProductoModelo {
  final int idProducto;
  final int idCategoria;
  final int idUsuario;
  final String nombre;
  final double cantidad;
  final double precio;
  final double? costo;
  final double? descuento;
  final String? codigoDeBarras;
  final String? urlImagen;
  final bool eliminado;
  final String? descripcion;
  final String? unidadMedida;
  final String nombreCategoria;

  ProductoModelo({
    required this.idProducto,
    required this.idCategoria,
    required this.idUsuario,
    required this.nombre,
    required this.cantidad,
    required this.precio,
    this.costo,
    this.descuento,
    this.codigoDeBarras,
    this.urlImagen,
    required this.eliminado,
    this.descripcion,
    this.unidadMedida,
    required this.nombreCategoria,
  });

  factory ProductoModelo.fromMap(Map<String, dynamic> map) => ProductoModelo(
        idProducto: map['id_producto'] as int,
        idCategoria: map['id_categoria'] as int,
        idUsuario: map['id_usuario'] as int,
        nombre: map['nombre'] as String,
        cantidad: map['cantidad'] as double,
        precio: map['precio'] as double,
        costo: map['costo'] as double?,
        descuento: map['descuento'] as double?,
        codigoDeBarras: map['codigo_de_barras'] as String?,
        urlImagen: map['url_imagen'] as String?,
        eliminado: map['eliminado'] as bool,
        descripcion: map['descripcion'] as String?,
        unidadMedida: map['unidad_medida'] as String?,
        nombreCategoria: map['nombre_categoria'] as String,
      );
}
