

import 'dart:convert';
import 'dart:io';

import 'package:cafe/common/enums.dart';
import 'package:get/get.dart';

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


      estado.value = Estado.exito;
      return true;
    } catch (e) {
      estado.value = Estado.error;
      mensaje.value = 'Error al actualizar el producto: $e';
      return false;
    }
  }
  
}