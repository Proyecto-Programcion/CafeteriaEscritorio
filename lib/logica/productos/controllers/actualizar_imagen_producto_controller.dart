import 'dart:convert';
import 'dart:io';

import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:get/get.dart';
import 'package:postgres/postgres.dart';

class ActualizarImagenProductoController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<bool> actualizarImagenProducto(
      int idProducto, String urlImagen) async {
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
        SET url_imagen = @url_imagen,
            last_modified = NOW()
        WHERE id_producto = @id_producto;
      ''');


      await Database.conn.execute(sql, parameters: {
        'url_imagen': imagenBase64,
        'id_producto': idProducto,
      });

      estado.value = Estado.exito;
      final ObtenerProductosControllers obtenerProductosControllers =
          Get.find<ObtenerProductosControllers>();
      await obtenerProductosControllers.obtenerProductos();
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al actualizar la imagen del producto: $e';
      return false;
    }
  }
}
