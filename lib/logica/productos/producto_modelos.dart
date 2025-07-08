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
  final bool esMayoreo; // Nuevo campo
  final double? precioMayoreo; // Nuevo campo
  final double? cantidadMinimaMayoreo; // Nuevo campo

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
    required this.esMayoreo, // Nuevo campo
    this.precioMayoreo, // Nuevo campo
    this.cantidadMinimaMayoreo, // Nuevo campo
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
        esMayoreo: map['es_mayoreo'] as bool? ?? false, // Nuevo campo con default
        precioMayoreo: map['precio_mayoreo'] as double?, // Nuevo campo
        cantidadMinimaMayoreo: map['cantidad_minima_mayoreo'] as double?, // Nuevo campo
      );
}

class ProductoCarrito {
  final ProductoModelo producto;
  double cantidad;

  ProductoCarrito({required this.producto, this.cantidad = 1});

  double get total {
    final precio = producto.precio ?? 0;
    final descuento = producto.descuento ?? 0;
    return (precio - descuento) * cantidad;
  }

  // Getter para saber si aplica precio de mayoreo
  bool get aplicaPrecioMayoreo {
    return producto.esMayoreo &&
        producto.cantidadMinimaMayoreo != null &&
        producto.precioMayoreo != null &&
        cantidad >= producto.cantidadMinimaMayoreo!;
  }

  // Método para obtener el precio según si aplica mayoreo o no
  double get precioFinal {
    // Si el producto tiene mayoreo y la cantidad es suficiente
    if (producto.esMayoreo &&
        producto.cantidadMinimaMayoreo != null &&
        producto.precioMayoreo != null &&
        cantidad >= producto.cantidadMinimaMayoreo!) {
      return producto.precioMayoreo!;
    }
    return producto.precio;
  }

  // Total calculado con precio de mayoreo si aplica
  double get totalConMayoreo {
    final precio = precioFinal;
    final descuento = producto.descuento ?? 0;
    return (precio - descuento) * cantidad;
  }
}
