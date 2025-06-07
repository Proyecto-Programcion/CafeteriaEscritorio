import 'dart:convert';
import 'dart:io';

import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/common/sesion_activa.dart';
import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ActualizarProductoController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> actualizarProducto(
    int idProducto,
    String nombre,
    String descripcion,
    String codigoDeBarras,
    String categoria,
    double costo,
    double precio,
    double cantidad,
    double cantidad_anterior,
    String unidadMedida,
    String urlImagen,
    int idCategoria,
    double descuento,
  ) async {
    try {
      estado.value = Estado.carga;
      String imagenBase64 = '';
      //pasar la imagen a base 64
      if (urlImagen != '') {
        File imageFile = File(urlImagen);
        List<int> imageBytes = await imageFile.readAsBytes();
        imagenBase64 = base64Encode(imageBytes);
        print('Imagen convertida a Base64');
      }

      final sql = Sql.named('''
        UPDATE productos
        SET
          id_categoria = @id_categoria,
          id_usuario = @id_usuario,
          nombre = @nombre,
          cantidad = @cantidad,
          precio = @precio,
          costo = @costo,
          codigo_de_barras = @codigo_de_barras,
          url_imagen = CASE WHEN @url_imagen = '' THEN url_imagen ELSE @url_imagen END,
          eliminado = @eliminado,
          descripcion = @descripcion,
          unidad_medida = @unidad_medida,
          descuento = @descuento
        WHERE id_producto = @id_producto;
      ''');


      await Database.conn.execute(sql, parameters: {
        'id_producto': idProducto,
        'id_categoria': idCategoria,
        'id_usuario': 1,
        'nombre': nombre,
        'cantidad': cantidad,
        'precio': precio,
        'costo': costo,
        'codigo_de_barras': codigoDeBarras,
        'url_imagen': imagenBase64,
        'eliminado': false,
        'descripcion': descripcion,
        'unidad_medida': unidadMedida,
        'descuento': descuento
      });

      if (cantidad != cantidad_anterior) {
        final cantidadMovimiento = cantidad - cantidad_anterior;
        final sqlControlStock = Sql.named('''
        INSERT INTO controlStock (id_producto, cantidad_antes, cantidad_movimiento, cantidad_despues, unidad_medida, categoria, id_usuario, fecha) 
        VALUES (
          @idProducto, 
          @cantidad_antes,
          @cantidad_movimiento, 
          @cantidad_despues,
          (SELECT unidad_medida FROM productos WHERE id_producto = @idProducto),
          @categoria,
          @idUsuario,
          @fecha
        );
        ''');

        await Database.conn.execute(sqlControlStock, parameters: {
          'idProducto': idProducto,
          'cantidad_antes': cantidad_anterior,
          'cantidad_movimiento': cantidadMovimiento,
          'cantidad_despues': cantidad,
          'categoria': 'actualizado',
          'idUsuario': SesionActiva().idUsuario,
          'fecha': DateTime.now().toIso8601String(),
        });
        
      }

      estado.value = Estado.exito;
      final ObtenerProductosControllers obtenerProductosControllers =
          Get.find<ObtenerProductosControllers>();
      await obtenerProductosControllers.obtenerProductos();
      return true;
    } catch (e) {
      print('Error al actualizar el producto: $e');
      if (e.toString().contains('23505:')) {
        mensaje.value = 'Codigo de barras duplicado';
        return false;
      } else {
        mensaje.value = 'A ocurrido un error inesperado: $e';
        return false;
      }
    }
  }
}
