import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:cafe/common/admin_db.dart';
import 'package:cafe/common/enums.dart';
import 'package:cafe/logica/productos/controllers/obtener_productos_controllers.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:postgres/postgres.dart';

class AgregarProductoController extends GetxController {
  Rx<Estado> estado = Estado.inicio.obs;
  Rx<String> mensaje = ''.obs;

  Future<void> agregarProducto(
    String nombre,
    String descripcion,
    String codigoDeBarras,
    String categoria,
    double costo,
    double precio,
    double cantidad,
    String unidadMedida,
    String urlImagen,
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
        INSERT INTO productos (
          id_categoria,
          id_usuario,
          nombre,
          cantidad,
          precio,
          costo,
          codigo_de_barras,
          url_imagen,
          eliminado,
          descripcion,
          unidad_medida,
          descuento
        ) VALUES (
          @id_categoria,
          @id_usuario,
          @nombre,
          @cantidad,
          @precio,
          @costo,
          @codigo_de_barras,
          @url_imagen,
          @eliminado,
          @descripcion,
          @unidad_medida,
          0
        );
      ''');

      await Database.conn.execute(sql, parameters: {
        'id_categoria': 1,
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
      });

      estado.value = Estado.exito;
      final ObtenerProductosControllers obtenerProductosControllers =
          Get.find<ObtenerProductosControllers>();
      await obtenerProductosControllers.obtenerProductos();
    } catch (e) {
      print('Error al agregar producto: $e');
      estado.value = Estado.error;
      mensaje.value = 'Error al agregar producto: $e';
    }
  }
}
